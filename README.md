# Dotfiles · Arch Linux

Personal configuration for my Arch Linux + Hyprland environment.

> Managed using [GNU Stow](https://www.gnu.org/software/stow/) for a clean, modular setup.
> macOS config available on the [`macos`](https://github.com/axelhamil/dotfiles/tree/macos) branch.

---

## Structure

| Package | Description |
|---------|-------------|
| `zsh` | ZSH config (powerlevel10k, aliases, PATH, NVM) |
| `git` | Git config (SSH signing, pull rebase) |
| `tmux` | Tmux config (Catppuccin Mocha, vim-style nav) |
| `p10k` | Powerlevel10k theme config |
| `kitty` | Kitty terminal (FiraCode Nerd Font) |
| `hypr` | Hyprland, hypridle, hyprlock, hyprpaper |
| `waybar` | Status bar config + scripts |
| `dunst` | Notification daemon |
| `wofi` | App launcher |
| `wlogout` | Logout screen + icons |
| `fastfetch` | System info display |

---

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/axelhamil/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Install stow**
   ```bash
   sudo pacman -S stow
   ```

3. **Symlink all packages**
   ```bash
   stow */
   ```
   Or pick individual packages:
   ```bash
   stow zsh git tmux kitty hypr waybar
   ```

---

## Requirements

- Arch Linux
- [Hyprland](https://hypr.land/) (Wayland compositor)
- [oh-my-zsh](https://ohmyz.sh/) + [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [kitty](https://sw.kovidgoyal.net/kitty/) terminal
- [FiraCode Nerd Font](https://www.nerdfonts.com/)
- [GNU Stow](https://www.gnu.org/software/stow/)
