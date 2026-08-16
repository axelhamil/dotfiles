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

**Kill après bilan (obligatoire)** : dès qu'un agent a rendu son rapport et que je n'ai plus de question pour lui → `TaskStop(task_id: <id>)`. Un agent terminé reste résumable et occupe un slot tant qu'il n'est pas arrêté. Ne garder ouvert QUE si un `SendMessage` de relance est réellement prévu dans la foulée. En fin de tâche, balayer les agents restants et tout arrêter.

**Models par agent** : `websearch`/`explore-docs`=haiku · `Explore`/`Plan`/`general-purpose`=sonnet · tmux teammates=opus.

**Comment appliquer** : les agents custom portent leur `model:` en frontmatter (`~/.claude/agents/*.md`) — ne rien passer à l'appel, le frontmatter gagne. Les built-in (`Explore`, `Plan`, `general-purpose`) n'ont pas de fichier : **passer `model: "sonnet"` explicitement à chaque appel**, sinon ils héritent d'Opus.

**Ne jamais définir `CLAUDE_CODE_SUBAGENT_MODEL`** — cette env var est prioritaire sur le frontmatter ET sur le paramètre d'appel, donc elle force un modèle unique pour tous les subagents et rend `websearch`=haiku inatteignable. Précédence : env var > paramètre d'appel > frontmatter > modèle principal.
