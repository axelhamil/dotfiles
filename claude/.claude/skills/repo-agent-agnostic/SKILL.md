---
name: repo-agent-agnostic
description: "Use when converting a repository so every coding agent reads the same instructions and skills instead of one file per tool — consolidating CLAUDE.md, .cursorrules, copilot-instructions.md, GEMINI.md into an AGENTS.md pivot with pointers. Triggers: 'repo agent-agnostic', 'AGENTS.md', 'un seul fichier pour tous les agents', 'migrer CLAUDE.md', 'setup multi-agent', 'mon repo marche qu'avec Claude Code', 'Cursor voit pas mes règles', 'dédupliquer les instructions agents', 'onboarder un repo pour les agents'."
---

# Rendre un repo agent-agnostic

## Principe

Un repo n'est pas agent-agnostic parce qu'il contient un fichier par outil — c'est l'inverse, c'est la définition de la dérive. Il l'est quand **chaque information a une seule source**, et que les fichiers spécifiques à un outil ne contiennent que ce qui est *irréductiblement* propre à cet outil.

Trois natures d'information, trois traitements :

| Nature | Source unique | Traitement des autres outils |
|---|---|---|
| Instructions permanentes | `AGENTS.md` | pointeur (stub `@AGENTS.md`) |
| Procédures occasionnelles | `.agents/skills/<nom>/SKILL.md` | symlink versionné |
| Permissions, MCP, hooks | aucune — syntaxes incompatibles | duplication assumée et documentée |

**La forme est dictée par le maillon le plus strict.** Aujourd'hui c'est Claude Code : il ne lit ni `AGENTS.md` ni `.agents/skills/` (vérifié doc officielle, v2.1.258). Tous les autres outils du périmètre lisent `AGENTS.md` nativement, et le CLI Cursor scanne `.agents/skills/` en priorité n°1. D'où : source aux emplacements standards, pointeurs pour Claude Code.

**Corollaire important** : ce tableau de compatibilité périme. Ne jamais le croire sur parole — phase 7, mesurer.

## Topologie cible

```
AGENTS.md                          source des instructions — tout le monde la lit
CLAUDE.md                          stub: @AGENTS.md + interdiction d'écrire
GEMINI.md                          stub (seulement si Gemini CLI mesuré défaillant)
.agents/skills/<nom>/SKILL.md      source des procédures
.claude/skills -> ../.agents/skills    symlink versionné (mode 120000) — ou rien, voir phase 4
.mcp.json                          source MCP
.cursor/mcp.json -> ../.mcp.json   symlink — même schéma `mcpServers`
.claude/settings.json              permissions Claude Code (+ hooks)
.cursor/cli.json                   permissions Cursor — duplication irréductible
packages/*/AGENTS.md               surcharges locales en monorepo
```

Pas de générateur, pas de dépendance npm, pas de hook de copie : un fichier généré dérive en silence dès qu'on corrige la copie au lieu de la source. Le symlink versionné n'a pas ce défaut.

## Workflow

### 1. Inventaire

```bash
fd -H -d 3 '^(AGENTS|CLAUDE|GEMINI|CONVENTIONS|\.cursorrules|\.windsurfrules|\.clinerules)' . 2>/dev/null
fd -H -d 4 . .claude .cursor .github .agents .gemini .junie .windsurf 2>/dev/null
git ls-files -s | awk '$1==120000'      # symlinks déjà versionnés
```

Lire **tout** ce qui sort avant d'écrire quoi que ce soit. Repérer en particulier : les instructions contradictoires entre deux fichiers (il faut trancher, pas fusionner), et ce qui est déjà obsolète.

### 2. Consolider vers AGENTS.md

Fusionner l'existant dans un seul `AGENTS.md`, dans la langue du repo (anglais si public).

Règles de fusion :
- **Deux fichiers se contredisent** → trancher explicitement, demander à l'utilisateur si l'arbitrage engage le projet.
- **Une instruction n'est vraie que pour un outil** → elle ne va pas dans `AGENTS.md` (ex. « utilise le sous-agent Explore »).
- **Une instruction est une procédure en étapes, rarement utilisée** → elle devient un skill (phase 4), pas une section.
- **Une instruction décrit ce que le code dit déjà** → supprimer.

Cible : **moins de 200 lignes**. Ce n'est pas cosmétique — Vercel mesure que le contexte passif d'un `AGENTS.md` compact bat le chargement à la demande de skills (100 % vs 79 % de réussite sur leurs evals), et que le mode d'échec n°1 d'un `AGENTS.md` est le vague, pas l'incomplétude. Ce qui dépasse part en `AGENTS.md` imbriqué (`packages/api/AGENTS.md`) ou en skill.

Chaque règle utile porte trois choses : ce qu'il faut faire, *pourquoi*, et comment savoir qu'on l'a violée. Une règle sans critère de vérification ne survit pas.

Structure éprouvée (voir `references/gabarits.md`) : bootstrap de session · commandes exactes (build, test, lint) · architecture en 5 lignes · règles transverses numérotées · discipline de scope · fin de session.

### 3. Poser les pointeurs

`CLAUDE.md` — **stub, pas symlink** :

```markdown
@AGENTS.md

<!-- Ce fichier est un pointeur, pas une source. -->

**Ne rien écrire ici.** Toute instruction projet appartient à `AGENTS.md`, que tous les
agents lisent. Ce qui est ajouté sous l'import n'est vu que par Claude Code et dérive
sans que rien ne le signale.

Vaut aussi pour ce que Claude Code écrit seul : auto-memory, raccourci `#`, « note ça ».
Destination : `AGENTS.md`.
```

Le symlink `CLAUDE.md -> AGENTS.md` marche aussi mais ne laisse aucun endroit où écrire l'interdiction — et casse sous Windows sans `core.symlinks=true`. Le stub coûte 8 lignes et se défend tout seul.

Pour les skills, voir phase 4 — c'est un arbitrage, pas un geste mécanique.

### 4. Extraire les skills

Un skill, pas une section d'`AGENTS.md`, quand les trois sont vraies :
- procédure en plusieurs étapes avec un ordre qui compte ;
- rarement déclenchée (sinon elle mérite le contexte permanent) ;
- coûteuse à redécouvrir (elle a déjà fait perdre une session).

Un skill est un dossier `.agents/skills/<nom>/SKILL.md`, frontmatter `name` + `description`. La `description` est le seul texte que l'agent lit pour décider de charger le skill : y mettre les déclencheurs littéraux, pas un résumé du contenu.

Le format `SKILL.md` est un standard ouvert (Agent Skills, décembre 2025) — le même fichier sert Claude Code, le CLI Cursor, Codex, Copilot, Zed, Gemini CLI, Junie, Kiro. **Mais la spec ne définit aucun emplacement canonique** : chaque outil impose le sien. `.agents/skills/` est lu par Cursor, Codex, Zed et Copilot ; Claude Code ne scanne que `.claude/skills/`, et la demande de support de `.agents/skills/` a été fermée « not planned » côté Anthropic. Ce n'est donc pas un manque transitoire à contourner en attendant : c'est une contrainte durable, à trancher.

**Deux montages tiennent, choisir selon qui écrit dans le repo :**

*A — Symlink versionné.* Les skills se chargent automatiquement dans Claude Code, comme partout ailleurs.

```bash
mkdir -p .agents/skills .claude
ln -s ../.agents/skills .claude/skills
git add .claude/skills && git ls-files -s .claude/skills   # doit afficher 120000
```

Un mode `100644` signifie que le lien a été committé comme fichier texte : cassé au prochain clone. Écrire toujours dans `.agents/skills/`, jamais à travers `.claude/skills/`. C'est le montage de `nvidia/skills`.

Coût : deux chemins pour un seul contenu, que chaque nouveau venu doit comprendre, et un clone Windows sans `core.symlinks=true` qui le casse.

*B — Emplacement unique, renvoi explicite.* Pas de symlink, pas de `.claude/skills/`. `CLAUDE.md` porte alors la seule chose dont Claude Code a besoin et qu'aucun autre agent ne réclame : où sont les skills, et l'ordre de les ouvrir.

```markdown
**Skills are not auto-loaded here.** Claude Code scans `.claude/skills/` only, and that
directory deliberately does not exist: the skills live once, in `.agents/skills/<name>/SKILL.md`.
The table in `AGENTS.md` § Skills maps each one to its trigger — when a trigger matches,
open the file with Read before starting. Nothing will surface it for you.
```

Le renvoi n'a de valeur que si la table des skills d'`AGENTS.md` donne un déclencheur par skill : sans elle, l'agent ne sait pas lequel ouvrir et n'ouvrira rien.

Coût : dans Claude Code le chargement devient un acte volontaire — un skill dont le déclencheur est mal formulé ne sera jamais lu. Ailleurs, rien ne change.

**Le montage B est le défaut** dès que le repo est partagé, tourne sous Windows, ou que la présence de deux dossiers pour un contenu prête à confusion. Prendre A quand le chargement automatique dans Claude Code compte plus que la lisibilité de l'arborescence.

Un troisième montage existe — un `skills/` neutre à la racine, sans point (`supabase/agent-skills`) — mais aucun outil ne le scanne : il suppose un renvoi explicite comme en B, sans le bénéfice d'être lu nativement par les quatre outils qui connaissent `.agents/skills/`.

### 5. Permissions et MCP

MCP se partage, les permissions non :

```bash
ln -s ../.mcp.json .cursor/mcp.json      # schéma `mcpServers` identique
```

Exception connue : VS Code utilise la clé `servers` et non `mcpServers` — pas de symlink possible vers `.vscode/mcp.json`.

Permissions : deux fichiers, syntaxes différentes, à maintenir en parallèle.

| Claude Code (`.claude/settings.json`) | Cursor CLI (`.cursor/cli.json`) |
|---|---|
| `Bash(nix flake check:*)` | `Shell(nix:flake check*)` |
| `Read(./secrets/**)` | `Read(./secrets/**)` |
| `allow` / `ask` / `deny` | `allow` / `deny` — pas de `ask` |

Écrire dans `AGENTS.md` que ces deux fichiers sont jumeaux et se modifient ensemble : c'est la seule protection contre leur divergence.

### 6. .gitignore

Versionner toute la topologie. Ignorer uniquement le local :

```
.claude/settings.local.json
CLAUDE.local.md
```

### 7. Mesurer, ne pas croire

**La phase qu'on saute et qui rend tout le reste faux.** Les matrices de compatibilité (celle-ci comprise) sont périmées en quelques semaines. Mesurer sur les outils réellement utilisés :

```bash
d=$(mktemp -d) && cd "$d" && git init -q
printf 'Le mot-témoin de ce projet est XANADU-7.\n' > AGENTS.md

claude -p 'Quel est le mot-témoin de ce projet ?' --disallowedTools 'Read,Grep,Glob,Bash'
cursor-agent -p 'Quel est le mot-témoin de ce projet ?'
```

L'agent répond `XANADU-7` **sans avoir ouvert de fichier** → le fichier est chargé en contexte automatiquement. Il ne répond pas, ou il tente de lire → il faut un pointeur.

Même méthode pour les skills : un `.agents/skills/temoin/SKILL.md` dont la `description` porte un déclencheur unique, puis demander la procédure. C'est ainsi qu'on a établi que le CLI Cursor scanne `.agents/skills/` mais que Claude Code ne scanne que `.claude/skills/`.

Consigner le résultat **avec sa date et la version de l'outil** dans `AGENTS.md` ou un fichier de décisions. Une mesure sans date est une croyance.

### 8. Verrouiller contre la dérive

Une topologie correcte se dégrade en trois semaines si rien ne s'y oppose. Trois défenses, par ordre d'efficacité :

1. **L'interdiction écrite dans le stub** (phase 3) — la seule qui soit lue au moment exact où la faute allait être commise.
2. **Une section « Agent configuration » dans `AGENTS.md`** : le tableau de la topologie, et la phrase qui dit lequel de ces fichiers est une source et lequel est un pointeur.
3. **Un contrôle mécanique** si le repo en vaut la peine : un script qui vérifie le mode 120000 des symlinks, la présence de l'import dans le stub, et la forme des frontmatter — branché en CI ou en hook `SessionStart`.

Ne pas mettre en place un hook qui *recopie* `.agents/skills/` vers `.claude/skills/` : le jour où quelqu'un corrige la copie, la correction est écrasée sans un mot.

## Pièges

- **Croire un tableau de compatibilité** au lieu de mesurer. Y compris celui-ci.
- **Symlink committé en mode 100644** — casse au clone, invisible en local (montage A).
- **Écrire à travers `.claude/skills/`** au lieu de `.agents/skills/` (montage A).
- **Retirer le symlink sans rien mettre à la place** : les skills deviennent invisibles pour Claude Code, silencieusement. Le renvoi dans `CLAUDE.md` n'est pas une politesse, c'est ce qui remplace le mécanisme.
- **Attendre qu'Anthropic supporte `.agents/skills/`** : la demande est fermée « not planned ».
- **`AGENTS.md` qui gonfle** : au-delà de ~200 lignes il perd en efficacité. Découper, ne pas tolérer.
- **Instructions vagues** (« écris du code propre ») : mode d'échec n°1, coûte plus que l'absence de règle.
- **Traiter les permissions comme partageables** : les syntaxes divergent, la duplication est le design, pas un bug.
- **Consolider sans trancher** : deux règles contradictoires fusionnées donnent un `AGENTS.md` qui autorise tout.
- **Windows** : les symlinks exigent `core.symlinks=true`. Si le repo doit y tourner, préférer des stubs partout.

## Références

- `references/matrice.md` — qui lit quoi, par outil, avec les chemins exacts et les dates de mesure.
- `references/gabarits.md` — squelettes prêts à copier : `AGENTS.md`, stubs, `settings.json`, `cli.json`, `.mcp.json`, script de contrôle.
