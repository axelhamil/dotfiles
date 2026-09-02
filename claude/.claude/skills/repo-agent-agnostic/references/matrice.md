# Matrice : qui lit quoi

État au 2 septembre 2026. **Périme vite** — re-mesurer selon la phase 7 du skill avant de s'y fier pour un repo qui compte.

## Instructions

| Outil | Lit `AGENTS.md` | Fichier propre | Pointeur nécessaire |
|---|---|---|---|
| Claude Code (2.1.258) | **non** | `CLAUDE.md`, `.claude/CLAUDE.md` | oui — stub `@AGENTS.md` |
| Cursor (IDE + CLI) | oui | `.cursor/rules/*.mdc`, `.cursorrules` (legacy) | non |
| OpenAI Codex CLI | oui | `~/.codex/AGENTS.md`, `AGENTS.override.md` | non |
| opencode | oui (puis `CLAUDE.md` en fallback) | `opencode.json` | non |
| Gemini CLI | oui | `GEMINI.md`, `~/.gemini/GEMINI.md` | à mesurer |
| GitHub Copilot | oui | `.github/copilot-instructions.md` | non |
| Windsurf | oui | `.windsurf/rules/*.md` | non |
| Zed | oui | — | non |
| Devin / Jules / Amp / Factory | oui | `~/.config/devin/AGENTS.md`, `.AGENT.md` (Amp) | non |
| Antigravity | oui | `.agents/rules/`, `~/.gemini/GEMINI.md` | non |
| Junie (JetBrains) | oui | `.junie/guidelines.md` | non |
| Aider | oui | `CONVENTIONS.md` (chargé via `/read`) | non |
| Cline / Roo | détection auto multi-formats | `.clinerules/` | non |

`AGENTS.md` : format ouvert créé par OpenAI (août 2025), transféré à l'Agentic AI Foundation sous la Linux Foundation (décembre 2025), aux côtés de MCP. ~60 000 repos publics. Pas de schéma imposé — Markdown libre, ajouté au contexte système.

**Claude Code** : pas de support natif, pas de setting pour l'activer. `/import` (depuis 2.1.213) convertit `AGENTS.md`, `.cursorrules`, `copilot-instructions.md` vers `CLAUDE.md` — c'est une migration ponctuelle, pas un lien vivant. Le stub `@AGENTS.md` reste la bonne réponse.

### Imports Claude Code

- Syntaxe `@chemin`, relatif au fichier importeur ou absolu, `~` accepté.
- Profondeur max : 4 sauts.
- Ignoré à l'intérieur d'un bloc de code ou de backticks.
- Symlinks suivis.

### Précédence mémoire Claude Code

```
policy managée (/etc/claude-code/CLAUDE.md)
  → ~/.claude/CLAUDE.md
    → ./CLAUDE.md ou ./.claude/CLAUDE.md
      → ./CLAUDE.local.md (gitignoré)
        → sous-dossiers (à la demande)
```

### Nesting

Codex, Devin, opencode et Cursor remontent l'arborescence depuis le fichier édité et s'arrêtent au premier `AGENTS.md`. En monorepo : racine = règles globales, `packages/<x>/AGENTS.md` = surcharges locales. OpenAI en maintient 88 dans ses propres repos.

## Skills (`SKILL.md`)

Standard ouvert **Agent Skills** publié par Anthropic en décembre 2025 (agentskills.io) ; ~32 outils l'implémentent (Claude Code, VS Code, Copilot, Codex, ChatGPT, Gemini CLI, Junie, Kiro, Amp, Figma, Atlassian…).

Répertoires scannés :

| Outil | Chemins projet | Chemins utilisateur |
|---|---|---|
| Claude Code | `.claude/skills/` **uniquement** | `~/.claude/skills/` |
| Cursor CLI | `.agents/skills/` (1), `.cursor/skills/` (2), `.claude/skills/` + `.codex/skills/` (rétrocompat) | `~/.agents/skills/`, `~/.cursor/skills/`, `~/.claude/skills/` |
| Copilot | `.github/skills/`, `.claude/skills/` | `~/.copilot/skills/`, `~/.agents/skills/` |
| Zed | `.agents/skills/` | `~/.agents/skills/` |
| Antigravity | `.agents/skills/` | — |

**La spec Agent Skills ne définit aucun emplacement canonique** : elle décrit la structure d'un skill, pas où le mettre. Chaque outil impose sa convention, et `.agents/skills/` n'est standard que parce que quatre outils indépendants l'ont choisi.

**Claude Code ne s'y ralliera pas** : la demande de chemins de recherche supplémentaires (issue #56193) est **fermée « not planned »**, et #31005 (~3 000 votes, ouverte depuis août 2025) n'a pas de réponse. À traiter comme une contrainte durable, pas comme un manque transitoire.

**Conclusion opérationnelle** : `.agents/skills/` est le seul emplacement lu nativement par plusieurs outils indépendants — c'est la source. Pour Claude Code, deux montages tiennent (détaillés en phase 4 du skill) : un symlink `.claude/skills` versionné, ou aucun symlink et un renvoi explicite dans `CLAUDE.md`.

Ce qui est observé dans de vrais repos publics : `nvidia/skills` fait le symlink (`ln -sfn ../.agents/skills .claude/skills`) ; `supabase/agent-skills` pose un `skills/` neutre à la racine, qu'aucun outil ne scanne. L'usage de `.agents/skills/` est émergent, pas massif — la plupart des repos ne partagent tout simplement pas leurs skills.

Frontmatter : `name` (facultatif, défaut = nom du dossier), `description` (requis — c'est le seul texte lu pour décider du chargement), `disable-model-invocation` (Claude Code : invocation manuelle seulement, utile pour un brouillon).

## Permissions

Aucune source partageable — syntaxes incompatibles.

**Claude Code**, `.claude/settings.json` : clés `allow` / `ask` / `deny`, formes `Bash(git status:*)`, `Read(./secrets/**)`, `WebFetch(domain:*)`.

**Cursor CLI**, `.cursor/cli.json` (projet, permissions seules) et `~/.cursor/cli-config.json` (global) : clés `allow` / `deny` — **pas de `ask`**. Formes `Shell(nix:flake check*)` (binaire, puis reste de la commande), `Read(glob)`, `Write(glob)`, `WebFetch(domaine)`, `Mcp(serveur:outil)`. `deny` l'emporte sur `allow`.

## MCP

| Outil | Projet | Utilisateur | Clé racine |
|---|---|---|---|
| Claude Code | `.mcp.json` | `~/.claude.json` | `mcpServers` |
| Cursor | `.cursor/mcp.json` | `~/.cursor/mcp.json` | `mcpServers` |
| VS Code | `.vscode/mcp.json` | — | **`servers`** |
| Continue | `.continue/config.yaml` | `~/.continue/config.yaml` | `mcp_servers` |

Claude Code et Cursor partagent le schéma → symlink `.cursor/mcp.json -> ../.mcp.json`. VS Code non.

Interpolation : `${env:VAR}` / `${userHome}` / `${workspaceFolder}` (Cursor), `${VAR}` (Claude Code).

## Hooks et sous-agents

Non portables — à traiter comme spécifiques, documentés comme tels.

**Claude Code** : hooks dans `.claude/settings.json` (`SessionStart`, `PreToolUse`, `PostToolUse`…), sous-agents dans `.claude/agents/*.md` (frontmatter `name`, `description`, `tools`, `model`, `permissionMode`, `skills`, `isolation`, `effort`…).

**Cursor** : hooks dans `.cursor/hooks.json` (`sessionStart`, `preToolUse`, `beforeShellExecution`, `afterFileEdit`…), sous-agents dans `.cursor/agents/` **et** `.claude/agents/` — donc les sous-agents Claude Code sont partiellement réutilisables.

## Outils de synchronisation (écartés)

`rulesync`, `ai-rules-sync`, `agent-rules-sync`, `vibe-rules`, `agent_sync` génèrent les fichiers par outil depuis une source canonique et couvrent 20+ outils. Utiles à grande échelle ; écartés ici parce qu'ils ajoutent une dépendance, produisent des fichiers générés à committer, et réintroduisent le risque exact qu'on cherche à éliminer — une copie qu'on corrige au lieu de la source.

## Sources

- https://agents.md/ · https://github.com/openai/agents.md
- https://agentskills.io/specification
- https://code.claude.com/docs/en/memory.md · `/skills.md` · `/sub-agents.md` · `/mcp.md`
- https://cursor.com/docs/cli/reference/permissions · `/docs/skills` · `/docs/hooks`
- https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals
- https://github.com/vercel/next.js/blob/canary/AGENTS.md
- https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation
