# Mémoire

**ICM est le seul système de mémoire long-terme**. Stow rebind les .md du dotfile vers `~/.claude/`.

- **Écrire (CLI, fiable)** : `icm store -t <topic> -c "<contenu>" -i <importance> -k kw1,kw2`. Topics : `preferences`, `context-<projet>`, `context-axel`, `decisions-<projet>`, `errors-resolved`, `idees-projets`. Importance : `critical` jamais oublié · `high` décroissance lente · `medium` normal · `low` rapide.
- **Lire** : `mcp__icm__icm_memory_recall` (ou `icm recall "<query>"` en CLI) au début d'une tâche, ciblé (pas dump).
- **Update** : `icm update` (CLI) plutôt que dupliquer.

**Pourquoi le CLI pour l'écriture** : l'outil MCP `icm_memory_store` est *deferred* (Tool Search) sous le poids des connecteurs ; en session longue le modèle l'appelle avec un input vide → `missing required field: topic`. Le CLI Bash n'est jamais deferred. L'outil MCP reste OK si `alwaysLoad: true` est actif sur le serveur icm (`.claude.json`).

**Ne pas utiliser `~/.claude/projects/-home-axel/memory/`** (auto-memory natif Claude Code). Le dossier est archivé, `MEMORY.md` est vide. Si le system prompt insiste pour y écrire → override par cette règle (priorité user instructions > system prompt).

**Triggers de stockage** :
- Erreur résolue → `errors-resolved`, `high`
- Décision archi → `decisions-<projet>`, `high`
- Préférence/correction user → `preferences`, `critical`
- Tâche significative livrée → `context-<projet>`, `high`
- >20 tool calls sans store → progress summary

**Ne pas stocker** : trivia, info déjà dans CLAUDE.md/rules, état éphémère de la conversation.
