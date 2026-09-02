# Gabarits

À adapter, jamais à copier tel quel : un gabarit rempli de généralités est pire qu'un fichier absent.

## AGENTS.md

Cible < 200 lignes. Chaque règle porte une justification et un critère de vérification.

```markdown
# AGENTS.md

## Bootstrap de session
Lire ce fichier, puis `<le fichier d'état du projet>`. Ne pas explorer le code au hasard.

## Ce qu'est ce projet
<Trois phrases. Ce qu'il fait, pour qui, ce qu'il n'est pas.>

## Stack
<Langages, frameworks, versions épinglées. Pas d'historique.>

## Commandes
| But | Commande |
|---|---|
| Installer | `pnpm install` |
| Dev | `pnpm dev` |
| Test (unitaire) | `pnpm test` |
| Test (un seul) | `pnpm test -- <motif>` |
| Lint | `pnpm lint` |
| Build | `pnpm build` |

## Architecture
<Cinq lignes. Les frontières entre modules et ce qui n'a pas le droit de traverser.>

## Règles transverses

### 1. <Règle impérative>
Pourquoi : <la raison, sinon la règle sera contournée dès qu'elle gêne>
Vérification : <la commande ou l'observation qui prouve qu'elle est tenue>
Piège : <l'erreur déjà commise>

### 2. …

## Ce qu'il ne faut pas faire
- <Interdit concret, pas « écrire du code propre »>
- Ne pas committer de secret, même dans un exemple.
- Ne pas ajouter de mention d'outil dans les messages de commit.

## Discipline de scope
Faire ce qui est demandé. Un problème adjacent se signale, il ne se corrige pas au passage.

## Configuration des agents
| Chemin | Rôle |
|---|---|
| `AGENTS.md` | Les instructions. Source, lue par tous les agents. |
| `CLAUDE.md` | Un import `@AGENTS.md` et rien d'autre. Pointeur. |
| `.agents/skills/<nom>/SKILL.md` | Les procédures. Source. |
| `.claude/skills` | Symlink vers `../.agents/skills`. Claude Code ne scanne pas d'autre chemin. |
| `.mcp.json` | Config MCP. Source. `.cursor/mcp.json` y pointe. |
| `.claude/settings.json`, `.cursor/cli.json` | Permissions. Jumeaux, se modifient ensemble. |

Mesuré le <date> : <outil vX> charge <fichiers>. Re-mesurer avant de s'y fier.

## Fin de session
<Ce qu'il faut mettre à jour avant de rendre la main.>
```

## CLAUDE.md — montage B (emplacement unique, pas de symlink)

```markdown
@AGENTS.md

**Skills are not auto-loaded here.** Claude Code scans `.claude/skills/` only, and that
directory deliberately does not exist: the skills live once, in `.agents/skills/<name>/SKILL.md`,
where every other agent reads them natively. The table in `AGENTS.md` § Skills maps each
one to its trigger — when a trigger matches the task, open the file with Read before
starting. Nothing will surface it for you.

**Write nothing else here.** Every project instruction — rule, workflow, tooling change —
belongs in `AGENTS.md`, which every agent reads. Anything added below is seen by Claude
Code only and drifts without warning.

This also covers what Claude Code writes on its own: auto-memory, the `#` shortcut, any
"note this somewhere" during a session. Destination: `AGENTS.md`.
```

## CLAUDE.md — montage A (symlink `.claude/skills`)

```markdown
@AGENTS.md

<!-- Ce fichier est un pointeur, pas une source. -->

**Ne rien écrire ici.** Toute instruction projet — règle transverse, méthode de travail,
changement d'outillage — appartient à `AGENTS.md`, que tous les agents lisent. Ce qui est
ajouté sous l'import n'est vu que par Claude Code et dérive sans que rien ne le signale.

Vaut aussi pour ce que Claude Code écrit de lui-même : auto-memory, raccourci `#`, tout
« note ça quelque part » en cours de session. Destination : `AGENTS.md`.
```

## GEMINI.md (stub, seulement si mesuré nécessaire)

```markdown
@AGENTS.md

Pointeur. Les instructions sont dans `AGENTS.md`. Ne rien ajouter ici.
```

## .claude/settings.json

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(pnpm test:*)",
      "Bash(pnpm lint:*)",
      "Bash(pnpm build:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)"
    ],
    "ask": [
      "Bash(git push:*)",
      "Bash(pnpm publish:*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Bash(rm -rf:*)"
    ]
  }
}
```

## .cursor/cli.json

Jumeau du précédent. Noter la forme `Shell(binaire:reste*)` et l'absence de `ask` — ce qui est en `ask` côté Claude passe en `deny` ici, ou est laissé hors liste pour déclencher une confirmation.

```json
{
  "permissions": {
    "allow": [
      "Shell(pnpm:test*)",
      "Shell(pnpm:lint*)",
      "Shell(pnpm:build*)",
      "Shell(git:status*)",
      "Shell(git:diff*)",
      "Shell(git:log*)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Shell(rm:*)"
    ]
  }
}
```

## .mcp.json

```json
{
  "mcpServers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "env": { "CONTEXT7_API_KEY": "${CONTEXT7_API_KEY}" }
    }
  }
}
```

```bash
ln -s ../.mcp.json .cursor/mcp.json
```

## .agents/skills/<nom>/SKILL.md

```markdown
---
name: <nom-en-kebab-case>
description: "Use when <situation précise>. Triggers: '<phrase littérale>', '<autre>'."
---

# <Titre>

## Quand
<Le signal qui déclenche, et le cas voisin où ce skill ne s'applique PAS.>

## Procédure
1. …
2. …

## Pièges
- <Erreur déjà commise, avec ce qu'elle coûte.>
```

La `description` est le seul texte lu pour décider du chargement : y mettre les formulations réelles de l'utilisateur, pas un résumé du contenu.

## .gitignore

```
.claude/settings.local.json
CLAUDE.local.md
```

Tout le reste de la topologie est versionné, symlinks compris.

## Script de contrôle (optionnel)

À poser en `scripts/agents-check.sh` seulement si le repo justifie un contrôle mécanique. Vérifie la forme, jamais la véracité du contenu.

```bash
#!/usr/bin/env bash
set -euo pipefail
fail=0
note() { printf '  %s\n' "$1"; fail=1; }

[ -f AGENTS.md ] || note "AGENTS.md manquant"
lines=$(wc -l < AGENTS.md)
[ "$lines" -le 200 ] || note "AGENTS.md fait $lines lignes (cible <= 200) — découper"

grep -q '^@AGENTS\.md' CLAUDE.md 2>/dev/null || note "CLAUDE.md n'importe pas AGENTS.md"
[ "$(wc -l < CLAUDE.md)" -le 20 ] || note "CLAUDE.md n'est plus un pointeur"

# Montage A (symlink) ou B (emplacement unique) — le repo doit tenir l'un des deux.
if [ -e .claude/skills ]; then
  [ -L .claude/skills ] || note ".claude/skills existe sans être un symlink — contenu dupliqué"
  [ "$(git ls-files -s .claude/skills | awk '{print $1}')" = "120000" ] \
    || note ".claude/skills versionné hors mode 120000 — cassé au clone"
else
  grep -q '\.agents/skills' CLAUDE.md \
    || note "pas de .claude/skills et CLAUDE.md ne dit pas où sont les skills — invisibles pour Claude Code"
fi

for s in .agents/skills/*/SKILL.md; do
  [ -e "$s" ] || continue
  head -10 "$s" | grep -q '^description:' || note "$s : frontmatter sans description"
done

[ "$fail" -eq 0 ] && echo "topologie agent-agnostic : OK"
exit "$fail"
```

Branchable en CI, ou en hook `SessionStart` côté Claude Code et `sessionStart` côté Cursor.
