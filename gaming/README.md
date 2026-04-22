# Gaming dotfiles

Config gaming non-invasive pour Arch + Hyprland + NVIDIA (Blackwell RTX 5070 Ti).

## Paquets Stow liés

| Paquet | Rôle |
|---|---|
| `hypr` | `gaming.conf` source'd dans `hyprland.conf` (shader cache, VRR, cursor) |
| `mangohud` | overlay MangoHud gaming |
| `gaming` | doc + scripts wrappers |

## Hardware actuel

- CPU : voir `lscpu` (boost 5.5 GHz)
- GPU : RTX 5070 Ti, 16 Go VRAM, driver `nvidia-open-dkms 595.x`
- RAM : 93 Go
- Écran principal : LG ULTRAWIDE 2560x1080@60 Hz (limite EDID — **upgrade prévu**)
- Écran secondaire : 4K@60 Hz DP

## Target perf

120-130 fps stables en qualité graphique haute — **nécessite un écran 120/144/165 Hz**.
Aujourd'hui : écran 60 Hz → viser 60 fps rock-solid + qualité max.

## Steam — launch options par jeu

Coller dans Steam → jeu → Propriétés → Options de lancement :

### Minimal (tout jeu)

```
gamemoderun mangohud %command%
```

### Jeu DLSS + Frame Generation (titres NGX)

```
PROTON_ENABLE_NVAPI=1 DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on gamemoderun mangohud %command%
```

### Jeu OpenGL legacy (threading OpenGL)

Attention : `__GL_THREADED_OPTIMIZATIONS=1` casse certaines apps (Electron, Chromium) donc **jamais** en global. Par jeu uniquement :

```
__GL_THREADED_OPTIMIZATIONS=1 gamemoderun mangohud %command%
```

### Gray Zone Warfare (UE5, DLSS, target 120-130 fps)

```
PROTON_ENABLE_NVAPI=1 PROTON_DLSS_UPGRADE=1 DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on DXVK_FRAME_RATE=130 gamemoderun mangohud %command% -USEALLAVAILABLECORES -fullscreen
```

- `PROTON_DLSS_UPGRADE=1` : bump DLSS du jeu vers la dernière DLL (modèle Transformer DLSS 4)
- `DXVK_NVAPI_DRS_NGX_DLSS_FG_OVERRIDE=on` : force Frame Generation même si l'option est grisée
- `DXVK_FRAME_RATE=130` : cap FPS bas-niveau (meilleur pacing qu'un cap in-game)
- `-USEALLAVAILABLECORES` : flag UE — utilise tous les cores CPU
- `-fullscreen` : force fullscreen exclusif UE (**indispensable** pour que le tearing soit effectif sur écran 60 Hz)

**Settings in-game pour 120-130 fps sur 4K@60 Hz (écran actuel) :**
- Mode d'affichage : **Fullscreen** (pas Borderless)
- DLSS : **Performance** (minimum, rendu interne 1080p)
- Frame Generation : **ON**
- Ray Tracing : **OFF** (trop coûteux pour le target)
- Textures / Shadows / Effects : High (pas Ultra)

Logique : DLSS Perf pousse le rendu interne à ~65-80 fps, FG double vers 130-150 fps, cap à 130.

## Jeux hors Steam

Utiliser `game-launch` :

```
game-launch <executable> [args...]
```

Équivalent à `gamemoderun mangohud <cmd>` + env vars NVIDIA NGX.

## Vérifier l'état

```
check-gaming
```

Affiche : driver NVIDIA, kernel, gamemode status, VRR monitor, shader cache.

## Quand le nouvel écran arrive

1. Dans `hyprland.conf`, mettre à jour la ligne `monitor = ...` avec la résolution et le refresh rate natif
2. Décommenter le bloc `misc { vrr = 2 }` dans `~/.dotfiles/hypr/.config/hypr/gaming.conf`
3. Vérifier : `hyprctl monitors | grep vrr` → doit passer à `true`
4. Dans chaque jeu Steam, activer VSync OFF + VRR ON, cap FPS à refresh_rate - 3 via `DXVK_FRAME_RATE` ou MangoHud `fps_limit`

## Pour désactiver toute la config gaming

Commenter dans `~/.dotfiles/hypr/.config/hypr/hyprland.conf` :

```
# source = ~/.config/hypr/gaming.conf
```

Puis logout/login. Rien d'autre à défaire — zéro modif système.

## Ce qui n'est PAS fait (choix conservateur PC de dev)

- Pas de kernel custom (`linux-cachyos-bore`) — gain 5-10 fps mais recompilation DKMS + risques.
  Si voulu un jour : `curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz && tar xvf cachyos-repo.tar.xz && cd cachyos-repo && sudo ./cachyos-repo.sh && sudo pacman -S linux-cachyos-bore linux-cachyos-bore-headers`. Garder `linux` en fallback dans le bootloader.
- Pas de `/etc/modprobe.d/nvidia.conf` — `modeset=1` est déjà default depuis driver 560+.
- Pas d'overclock GPU — ROI marginal, risque thermique.
- Pas de `gamescope` — overhead inutile sous Hyprland natif.
