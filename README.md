# Dotfiles · macOS

Personal configuration for my macOS environment.

> ⚙️ Managed using [GNU Stow](https://www.gnu.org/software/stow/) for a clean, modular setup.

---

## 📁 Structure

Each directory represents a tool or app (e.g. `zsh`, `git`, `config`) and contains the config files to be symlinked into `$HOME`.

Example:
```
.
├── zsh/
│   └── .zshrc
├── git/
│   └── .gitconfig
├── config/
│   └── .config/
```

---

## 🚀 Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/your-username/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Symlink with Stow**
   ```bash
   stow zsh git config  # or any modules you want to enable
   ```

3. ✅ Done — your config is now cleanly symlinked into your home directory.

---

## 🧰 Requirements

- macOS
- oh-my-zsh
- [`stow`](https://www.gnu.org/software/stow/) (install via Homebrew):
  ```bash
  brew install stow
  ```

