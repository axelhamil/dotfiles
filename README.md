# Dotfiles · macOS

Personal configuration for my macOS environment.

> Managed using [GNU Stow](https://www.gnu.org/software/stow/) for a clean, modular setup.
> Arch Linux config available on the [`arch`](https://github.com/axelhamil/dotfiles/tree/arch) branch.

---

## Structure

Each directory represents a tool or app and contains the config files to be symlinked into `$HOME`.

```
.
├── zsh/          # ZSH config (powerlevel10k, aliases, NVM)
├── git/          # Git config
├── config/       # .config/ entries (aerospace, etc.)
```

---

## Setup

1. **Clone the repo**
   ```bash
   git clone -b macos https://github.com/axelhamil/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Install stow**
   ```bash
   brew install stow
   ```

3. **Symlink with Stow**
   ```bash
   stow zsh git config
   ```

---

## Requirements

- macOS
- [oh-my-zsh](https://ohmyz.sh/) + [powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [GNU Stow](https://www.gnu.org/software/stow/)
