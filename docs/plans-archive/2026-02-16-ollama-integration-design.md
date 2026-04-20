# Ollama Integration Design

## Contexte

Intégrer Ollama dans le workflow quotidien sur Arch Linux (Hyprland, kitty, RTX 5070 Ti 16GB VRAM, 96GB RAM).

**Motivations** : coût API, confidentialité, offline/latence, curiosité.

**Contraintes** :
- VRAM libérée après chaque utilisation (pas de modèle chargé H24)
- GPU pour la vitesse d'inférence, pas pour le stockage
- Préférence modèles français (Mistral) quand qualité comparable

## Modèles

100% Mistral, ~34 GB disque total.

| Rôle | Modèle | Taille disque |
|------|--------|---------------|
| Daily driver (chat, ortho, mails, titres, résumés, traduction) | `mistral-nemo:12b` | ~7 GB |
| Code | `codestral:22b` | ~13 GB |
| Heavy reasoning | `mistral-small:24b` | ~14 GB |

## Outils

| Use case | Outil | Notes |
|----------|-------|-------|
| CLI one-shots (titres, résumés, ortho) | fabric | Patterns custom + community |
| TUI chat | oterm | Sessions persistantes |
| Git workflow (commit msg, PR) | fabric + aliases ZSH | Patterns dédiés |
| Traduction pages web | Immersive Translate (extension browser) | Pointe vers Ollama API |
| Dictée vocale (STT) | Voxtype | Push-to-talk natif Wayland, whisper-large-v3-turbo |
| Scripting / pipes | API Ollama ou fabric | Intégration dans scripts custom |

## Config Ollama

- `OLLAMA_KEEP_ALIVE=30s` : décharge VRAM 30s après dernière requête
- `OLLAMA_ORIGINS=*` : autorise requêtes browser (Immersive Translate)
- Service systemd existant, modifier l'unit pour ajouter les env vars

## Architecture

```
                    ┌─────────────┐
                    │   Ollama     │
                    │  (systemd)  │
                    │ :11434      │
                    └──────┬──────┘
                           │
         ┌─────────┬───────┼────────┬──────────┐
         │         │       │        │          │
    ┌────▼───┐ ┌───▼──┐ ┌──▼──┐ ┌───▼────┐ ┌───▼──────┐
    │ fabric │ │oterm │ │ ZSH │ │Immersive│ │ Scripts  │
    │  CLI   │ │ TUI  │ │alias│ │Translate│ │  custom  │
    └────────┘ └──────┘ └─────┘ └────────┘ └──────────┘

    ┌───────────┐
    │  Voxtype  │  (indépendant, whisper-large-v3-turbo)
    │   STT     │
    └───────────┘
```

## Approche d'implémentation

1. **Config Ollama** : env vars dans le service systemd
2. **Pull modèles** : mistral-nemo, codestral, mistral-small
3. **Install fabric** : via AUR, config Ollama comme provider
4. **Install oterm** : via uvx
5. **Aliases ZSH** : fonctions wrapper dans ~/.config/zsh/
6. **Immersive Translate** : install extension + config Ollama endpoint
7. **Voxtype** : install AUR + config Hyprland keybind + download whisper model
