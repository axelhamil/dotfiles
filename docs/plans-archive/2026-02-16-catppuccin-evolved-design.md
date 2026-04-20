# Catppuccin Evolved — Design Document

**Date**: 2026-02-16
**Scope**: Full rework du setup Hyprland — perf, animations, launcher, plugins, workflow

## Context

Setup Arch Linux + Hyprland 0.53.3 avec Catppuccin Mocha. Dual monitor (DP-5 4K@60 1.5x, HDMI-A-3 ultrawide). RTX 5070 Ti. Le setup est fonctionnel mais générique — on le pousse au next level tout en gardant Catppuccin Mocha comme thème central.

## Approach: "Catppuccin Evolved"

7 phases incrémentales, testables indépendamment, zéro breaking changes.

---

## Phase 1 — Performance & Fondations NVIDIA

### Changements hyprland.conf

```
misc {
    vfr = true           # Variable framerate — GPU repos quand idle
    vrr = 1              # Variable refresh rate
}

decoration {
    blur {
        size = 6
        passes = 2       # 1 → 2, RTX 5070 Ti gère sans problème
        new_optimizations = true
        xray = false
    }
}

env = GBM_BACKEND,nvidia-drm
```

### Rationale

- `vfr = true` réduit drastiquement l'utilisation GPU idle
- `blur passes = 2` améliore la qualité visuelle du blur sans impact mesurable sur 5070 Ti
- `GBM_BACKEND` manquait pour un pipeline NVIDIA complet

---

## Phase 2 — Animations Refondues

### Nouveau set complet

```
bezier = smoothOut, 0.36, 0, 0.66, -0.56
bezier = smoothIn, 0.25, 1, 0.5, 1
bezier = overshot, 0.05, 0.9, 0.1, 1.05
bezier = spring, 0.15, 1.15, 0.4, 1
bezier = softSnap, 0.4, 0, 0.2, 1

animation = windows, 1, 5, spring, popin 80%
animation = windowsOut, 1, 4, smoothOut, popin 80%
animation = windowsMove, 1, 4, overshot
animation = fade, 1, 4, smoothIn
animation = workspaces, 1, 5, overshot, slidefade 30%
animation = specialWorkspace, 1, 4, spring, slidefadevert -30%
animation = border, 1, 10, default
animation = borderangle, 1, 30, smoothIn, loop
```

### Key effects

- `slidefade 30%` : workspaces glissent + fondu simultané
- `borderangle loop` : gradient mauve→bleu tourne en continu
- `spring` : bounce iOS-like sur les fenêtres
- `overshot` : léger dépassement naturel

---

## Phase 3 — Walker (Remplacement wofi)

### Installation

```bash
yay -S walker-bin
```

### Modules activés

- applications, calc, clipboard, finder, websearch, symbols, switcher

### Keybinds

```
bind = $mainMod, Space, exec, walker
bind = $mainMod, C, exec, walker --modules clipboard
```

### Thème

Config `~/.config/walker/config.toml` avec palette Catppuccin Mocha.

---

## Phase 4 — hyprexpo (Workspace Overview)

### Installation

```bash
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
```

### Config

```
plugin {
    hyprexpo {
        columns = 2
        gap_size = 5
        bg_col = rgb(11111b)
        workspace_method = center current
    }
}

bind = $mainMod, grave, hyprexpo:expo, toggle
```

---

## Phase 5 — Blur Layers (Glassmorphism)

```
layerrule = blur, waybar
layerrule = ignorealpha 0.3, waybar
layerrule = blur, walker
layerrule = ignorealpha 0.3, walker
layerrule = blur, notifications
layerrule = ignorealpha 0.3, notifications
```

---

## Phase 6 — Scratchpads Nommés

```
# Terminal scratch (drop-down)
bind = $mainMod, F1, togglespecialworkspace, term
windowrule = float on, match:class ^(scratch-term)$
windowrule = size 80% 60%, match:class ^(scratch-term)$
windowrule = move 10% 5%, match:class ^(scratch-term)$
exec-once = [workspace special:term silent] kitty --class scratch-term

# File manager scratch
bind = $mainMod, F2, togglespecialworkspace, files
windowrule = float on, match:class ^(scratch-files)$
windowrule = size 70% 70%, match:class ^(scratch-files)$
windowrule = center on, match:class ^(scratch-files)$
exec-once = [workspace special:files silent] nautilus --class scratch-files

# Music player scratch
bind = $mainMod, F3, togglespecialworkspace, music
```

---

## Phase 7 — Wallpapers Catppuccin

- Clone collection Catppuccin officielle
- Bind SUPER+SHIFT+W pour wallpaper random
- Timer optionnel pour rotation automatique

---

## Success Criteria

- Animations fluides 60fps sur les deux écrans
- Walker fonctionnel avec calc + clipboard
- hyprexpo accessible en SUPER+²
- Blur visible sur waybar/walker/dunst
- Scratchpads réactifs en < 100ms
- Aucune régression workflow existant
