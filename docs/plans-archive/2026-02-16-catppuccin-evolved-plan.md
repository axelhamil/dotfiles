# Catppuccin Evolved — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transformer le setup Hyprland en "Catppuccin Evolved" — perf NVIDIA, animations macOS-like, Walker launcher (Raycast-like), hyprexpo, glassmorphism, scratchpads nommés, wallpapers.

**Architecture:** 7 phases incrémentales sur la config Hyprland existante. Chaque phase est indépendante et testable. Les fichiers sont gérés par GNU Stow dans `~/.dotfiles/` — on édite les sources stow, pas les symlinks.

**Tech Stack:** Hyprland 0.53.3, Walker (Go/GTK4), hyprpm, swww, Catppuccin Mocha palette

**Important — Stow:** Tous les fichiers de config sont des symlinks gérés par GNU Stow. Les sources se trouvent dans `~/.dotfiles/<package>/`. Éditer directement les fichiers dans `~/.config/` fonctionne car ce sont des symlinks vers les sources stow.

---

### Task 1: Performance & Fondations NVIDIA

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (sections `misc`, `decoration.blur`, env vars)

**Step 1: Ajouter la section `misc` avec vfr**

Dans `hyprland.conf`, la section `misc` existe déjà (ligne ~229). Ajouter `vfr = true` dedans, et aussi `vrr = 1` :

```
misc {
    force_default_wallpaper = 0
    disable_hyprland_logo = true
    vfr = true
    vrr = 1
}
```

**Step 2: Optimiser le blur**

Modifier la section `decoration.blur` (ligne ~165) :

```
blur {
    enabled = true
    size = 6
    passes = 2
    new_optimizations = true
    xray = false
    vibrancy = 0.1696
}
```

**Step 3: Ajouter l'env var manquante**

Après les env vars NVIDIA existantes (ligne ~98), ajouter :

```
env = GBM_BACKEND,nvidia-drm
```

**Step 4: Vérifier**

```bash
hyprctl reload
```

Vérifier : pas de crash, blur visible sur les fenêtres. Vérifier GPU idle avec `nvidia-smi` — devrait montrer une utilisation plus basse qu'avant.

---

### Task 2: Animations Refondues

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (section `animations`)

**Step 1: Remplacer toute la section animations**

Remplacer le bloc `animations { ... }` complet (lignes ~175-205) par :

```
animations {
    enabled = yes, please :)

    # Custom curves
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = smoothIn, 0.25, 1, 0.5, 1
    bezier = overshot, 0.05, 0.9, 0.1, 1.05
    bezier = spring, 0.15, 1.15, 0.4, 1
    bezier = softSnap, 0.4, 0, 0.2, 1

    # Windows
    animation = windows, 1, 5, spring, popin 80%
    animation = windowsOut, 1, 4, smoothOut, popin 80%
    animation = windowsMove, 1, 4, overshot

    # Fade
    animation = fade, 1, 4, smoothIn
    animation = fadeIn, 1, 3, smoothIn
    animation = fadeOut, 1, 3, smoothOut

    # Layers
    animation = layers, 1, 4, softSnap, fade
    animation = layersIn, 1, 3, smoothIn, fade
    animation = layersOut, 1, 2, smoothOut, fade

    # Workspaces — le game changer
    animation = workspaces, 1, 5, overshot, slidefade 30%
    animation = workspacesIn, 1, 4, overshot, slidefade 30%
    animation = workspacesOut, 1, 4, smoothOut, slidefade 30%

    # Special workspaces (scratchpads)
    animation = specialWorkspace, 1, 4, spring, slidefadevert -30%

    # Border gradient rotation
    animation = border, 1, 10, default
    animation = borderangle, 1, 30, smoothIn, loop
}
```

**Step 2: Vérifier**

```bash
hyprctl reload
```

Vérifier :
- Ouvrir/fermer une fenêtre → popin bounce (spring)
- Switch workspace (SUPER+1/2/3) → slidefade smooth
- Bordure fenêtre active → gradient mauve→bleu qui tourne lentement

---

### Task 3: Installer Walker

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (keybinds)
- Create: `~/.config/walker/config.toml`
- Create: `~/.config/walker/style.css`

**Step 1: Installer Walker**

```bash
yay -S walker-bin
```

**Step 2: Créer la config Walker**

Créer `~/.config/walker/config.toml` :

```toml
[search]
placeholder = "Search..."
delay = 0
history = true
max_entries = 50

[list]
max_entries = 50
show_initial_entries = true

[activation_mode]
labels = "asdfjkl;"

[builtins]

[builtins.applications]
weight = 5
name = "applications"
placeholder = "Applications..."
show_generic = false
actions = true

[builtins.calc]
weight = 3
icon = "accessories-calculator"

[builtins.clipboard]
weight = 4
max_entries = 20
image_height = 100

[builtins.finder]
weight = 2
concurrency = 8
ignore_gitignore = true

[builtins.websearch]
weight = 1
engines = ["google"]

[builtins.symbols]
weight = 1

[builtins.switcher]
weight = 4
```

**Step 3: Créer le thème Catppuccin Mocha pour Walker**

Créer `~/.config/walker/style.css` :

```css
/* Walker — Catppuccin Mocha */

@define-color base    #1e1e2e;
@define-color mantle  #181825;
@define-color crust   #11111b;
@define-color text    #cdd6f4;
@define-color subtext0 #a6adc8;
@define-color surface0 #313244;
@define-color surface1 #45475a;
@define-color mauve   #cba6f7;
@define-color blue    #89b4fa;
@define-color green   #a6e3a1;
@define-color red     #f38ba8;
@define-color lavender #b4befe;

#window {
    background-color: alpha(@base, 0.85);
    border: 2px solid alpha(@mauve, 0.4);
    border-radius: 16px;
}

#box {
    margin: 10px;
}

#search {
    background-color: @surface0;
    border: 1px solid @surface1;
    border-radius: 10px;
    color: @text;
    padding: 10px 16px;
    font-family: "FiraCode Nerd Font";
    font-size: 15px;
    margin-bottom: 8px;
}

#search:focus {
    border-color: @mauve;
}

#list {
    background-color: transparent;
}

#list row {
    padding: 8px 12px;
    border-radius: 8px;
    margin: 2px 0;
    transition: all 200ms ease;
}

#list row:selected {
    background-color: @mauve;
    color: @crust;
}

#list row:hover:not(:selected) {
    background-color: alpha(@surface0, 0.6);
}

#list row label {
    color: @text;
    font-family: "FiraCode Nerd Font";
    font-size: 14px;
}

#list row:selected label {
    color: @crust;
    font-weight: bold;
}

#list row .description {
    color: @subtext0;
    font-size: 12px;
}

#list row:selected .description {
    color: alpha(@crust, 0.8);
}

#list row image {
    margin-right: 8px;
}
```

**Step 4: Mettre à jour les keybinds Hyprland**

Dans `hyprland.conf`, remplacer les binds wofi/cliphist :

Remplacer :
```
$menu = wofi --show drun
```
Par :
```
$menu = walker
```

Remplacer le bind clipboard :
```
bind = $mainMod, C, exec, cliphist list | wofi --dmenu -p "Clipboard" | cliphist decode | wl-copy
```
Par :
```
bind = $mainMod, C, exec, walker --modules clipboard
```

**Step 5: Vérifier**

```bash
hyprctl reload
walker  # test direct dans le terminal d'abord
```

Puis SUPER+Space → Walker s'ouvre, taper un nom d'app. SUPER+C → clipboard intégré.

---

### Task 4: hyprexpo (Workspace Overview)

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (plugin config + keybind)

**Step 1: Installer le plugin**

```bash
hyprpm update
hyprpm add https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
```

**Step 2: Ajouter la config plugin + keybind**

À la fin de `hyprland.conf`, avant les window rules, ajouter :

```
#################
### PLUGINS ###
#################

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

Note : `grave` = la touche ² en layout FR (à vérifier, sinon utiliser le keycode).

**Step 3: Vérifier**

```bash
hyprctl reload
```

SUPER+² → vue overview de tous les workspaces en grille. Clic ou numéro pour naviguer.

Si `grave` ne fonctionne pas en FR, trouver le keycode :

```bash
wev  # ou hyprctl binds pour vérifier
```

Et ajuster le bind avec `code:XX` si nécessaire.

---

### Task 5: Blur Layers (Glassmorphism)

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (layerrules)

**Step 1: Ajouter les layerrules**

Après la section `decoration`, ajouter :

```
#####################
### LAYER RULES ###
#####################

layerrule = blur, waybar
layerrule = ignorealpha 0.3, waybar

layerrule = blur, walker
layerrule = ignorealpha 0.3, walker

layerrule = blur, notifications
layerrule = ignorealpha 0.3, notifications

layerrule = blur, wofi
layerrule = ignorealpha 0.3, wofi
```

**Step 2: Vérifier**

```bash
hyprctl reload
```

Regarder la waybar : le fond doit montrer le wallpaper flou à travers (grâce au `alpha(@crust, 0.85)` du CSS waybar). Ouvrir Walker → même effet glassmorphism.

---

### Task 6: Scratchpads Nommés

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (binds, window rules, exec-once)

**Step 1: Remplacer le scratchpad existant**

Supprimer l'ancien bind scratchpad :
```
bind = $mainMod, S, togglespecialworkspace, magic
```

**Step 2: Ajouter les scratchpads nommés**

Ajouter dans la section keybindings :

```
# ── Scratchpads ──
bind = $mainMod, F1, togglespecialworkspace, term
bind = $mainMod, F2, togglespecialworkspace, files
bind = $mainMod, F3, togglespecialworkspace, music
```

Ajouter dans la section window rules :

```
# ── Scratchpad: Terminal ──
windowrule = float on, match:class ^(scratch-term)$
windowrule = size 80% 60%, match:class ^(scratch-term)$
windowrule = move 10% 5%, match:class ^(scratch-term)$

# ── Scratchpad: File Manager ──
windowrule = float on, match:class ^(scratch-files)$
windowrule = size 70% 70%, match:class ^(scratch-files)$
windowrule = center on, match:class ^(scratch-files)$
```

Ajouter dans la section autostart :

```
# Scratchpads
exec-once = [workspace special:term silent] kitty --class scratch-term
exec-once = [workspace special:files silent] nautilus --class=scratch-files
```

**Step 3: Vérifier**

```bash
hyprctl reload
```

Note : les exec-once ne se relancent pas sur reload, il faut les lancer manuellement pour tester :

```bash
hyprctl dispatch exec "[workspace special:term silent] kitty --class scratch-term"
```

Puis SUPER+F1 → terminal flottant qui slide depuis le haut. SUPER+F1 encore → il disparaît.

---

### Task 7: Wallpapers Catppuccin

**Files:**
- Modify: `~/.config/hypr/hyprland.conf` (keybind)

**Step 1: Télécharger les wallpapers**

```bash
git clone --depth 1 https://github.com/zhichaoh/catppuccin-wallpapers.git ~/Images/wallpapers/catppuccin/
```

Si le repo n'existe pas ou est vide, alternative :

```bash
git clone --depth 1 https://github.com/Gingeh/wallpapers.git ~/Images/wallpapers/catppuccin/
```

(Catppuccin-flavored wallpapers community repo)

**Step 2: Ajouter le keybind wallpaper random**

Dans `hyprland.conf`, section keybindings :

```
# Wallpaper random
bind = $mainMod SHIFT, W, exec, ~/.config/hypr/scripts/wallpaper.sh
```

**Step 3: Vérifier**

```bash
~/.config/hypr/scripts/wallpaper.sh
```

Le wallpaper doit changer avec une transition wipe. Puis tester SUPER+SHIFT+W.

---

## Post-Implementation Checklist

- [ ] `hyprctl reload` sans erreurs
- [ ] Animations fluides 60fps (pas de stutter sur switch workspace)
- [ ] Walker s'ouvre avec SUPER+Space
- [ ] Walker clipboard avec SUPER+C
- [ ] hyprexpo avec SUPER+²
- [ ] Blur visible sur waybar, Walker, notifications
- [ ] Scratchpad terminal avec SUPER+F1
- [ ] Wallpaper change avec SUPER+SHIFT+W
- [ ] Aucun bind existant cassé (vérifier SUPER+Q, SUPER+Return, etc.)
