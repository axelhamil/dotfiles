# Git

- `"commit"` / `"commit tout"` → commit ALL + **push immédiat**, sans confirmation. Exception : `"ne push pas"` / `"commit only"`.
- Nouveau commit > amend. Jamais `--no-verify` sauf demande.
- Jamais `push --force` sur main/master ; avertir si demandé.
- Stage par nom de fichier (jamais `-A`/`.` — risque secrets).
- Messages via HEREDOC pour préserver le formatting.
