# Context + Subagents

**Objectif** : contexte principal lean.

**Direct** : Glob, Grep ciblé, Read 1-2 fichiers connus.

**Subagent (obligatoire)** :
- Exploration >3 fichiers ou recherche ouverte → `Task(Explore)`
- Web search → `Task(websearch)` model=`haiku`
- Grep multi-fichiers volumineux → `Task(Explore)`
- Gros fichier pour extraire info → subagent ou `offset`/`limit`
- Bloqué 2+ fois même approche → `Task(websearch)` AVANT retry

**Parallèle si indépendants**. `/compact` tôt > `/clear` tard.

**Models par agent** : `websearch`=haiku · `Explore`/`Plan`/`general-purpose`=sonnet · tmux teammates=opus.
