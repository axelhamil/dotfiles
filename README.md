# Dotfiles · macOS

Personal configuration for my macOS environment.

Managed with a small bootstrap script (stow-style symlinks).
Arch Linux config lives on the [`arch`](https://github.com/axelhamil/dotfiles/tree/arch) branch.

Home stays clean:

| What | Where |
|------|--------|
| This repo | `~/.dotfiles` |
| Oh My Zsh | `~/.local/share/oh-my-zsh` |
| Zsh config | `~/.config/zsh` (`ZDOTDIR`) |
| Git config | `~/.config/git` |
| Only zsh file in `$HOME` | `~/.zshenv` |

---

## Structure

```
.
├── bootstrap.sh     # install OMZ + plugins, symlink packages
├── zsh/             # .zshenv + XDG zsh modules (aliases, path, nvm, p10k)
├── git/             # XDG git config
├── aerospace/       # optional window manager
└── scripts/         # macos-tweaks.sh
```

---

## Setup

```bash
git clone -b macos https://github.com/axelhamil/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

Optional packages:

```bash
./bootstrap.sh zsh git aerospace
```

Copy `git/.config/git/local.example` to `~/.config/git/local` and fill in email / signing key.

---

## Requirements

- macOS + zsh
- [oh-my-zsh](https://ohmyz.sh/) + [powerlevel10k](https://github.com/romkatv/powerlevel10k) (installed by bootstrap)
- A Nerd Font in the terminal (for p10k icons)
