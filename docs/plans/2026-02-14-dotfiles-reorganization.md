# Dotfiles Reorganization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Nettoyer et versionner la config Arch Linux avec GNU Stow, en éliminant les doublons et en organisant les fichiers proprement.

**Architecture:** Repo git dans `~/.dotfiles` avec un package Stow par outil (zsh, git, tmux, hypr, kitty, waybar, dunst, wofi, wlogout, fastfetch, p10k). Chaque package reproduit la structure de `~` pour que `stow <package>` crée les symlinks automatiquement.

**Tech Stack:** GNU Stow, Git, ZSH, Hyprland

---

### Task 1: Backup de sécurité

**Files:**
- Create: `~/dotfiles-backup-2026-02-14.tar.gz`

**Step 1: Créer le backup complet**

```bash
tar czf ~/dotfiles-backup-$(date +%F).tar.gz \
  ~/.zshrc ~/.config.zsh ~/.alias.zsh ~/.nvm-config.zsh \
  ~/.p10k.zsh ~/.tmux.conf ~/.gitconfig ~/.zshrc.bck \
  ~/.bash_profile ~/.bashrc ~/.profile \
  ~/.config/hypr/ ~/.config/kitty/ ~/.config/waybar/ \
  ~/.config/dunst/ ~/.config/wofi/ ~/.config/wlogout/ \
  ~/.config/fastfetch/ 2>/dev/null
```

**Step 2: Vérifier le backup**

```bash
tar tzf ~/dotfiles-backup-$(date +%F).tar.gz | head -20
```

Expected: Liste des fichiers archivés.

---

### Task 2: Initialiser le repo et installer stow

**Files:**
- Create: `~/.dotfiles/.gitignore`
- Create: `~/.dotfiles/README.md`

**Step 1: Installer stow si absent**

```bash
pacman -Qi stow || sudo pacman -S --noconfirm stow
```

**Step 2: Initialiser le repo git**

```bash
cd ~/.dotfiles && git init
```

**Step 3: Créer le .gitignore**

```
.DS_Store
*.zwc
*.old
*.bak
```

**Step 4: Commit initial**

```bash
git add .gitignore docs/
git commit -m "init: dotfiles repo with plan"
```

---

### Task 3: Package ZSH — Créer les fichiers nettoyés

**Files:**
- Create: `~/.dotfiles/zsh/.zshrc`
- Create: `~/.dotfiles/zsh/.config/zsh/aliases.zsh`
- Create: `~/.dotfiles/zsh/.config/zsh/path.zsh`
- Create: `~/.dotfiles/zsh/.config/zsh/nvm.zsh`

**Step 1: Créer la structure**

```bash
mkdir -p ~/.dotfiles/zsh/.config/zsh
```

**Step 2: Écrire le nouveau .zshrc consolidé**

```zsh
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
CASE_SENSITIVE="true"
zstyle ':omz:update' mode auto

plugins=(
  git gh
  kitty nvm podman postgres
  ssh themes
  tmux vscode
  zsh-autosuggestions zsh-syntax-highlighting alias-finder
)

zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

source $ZSH/oh-my-zsh.sh

# Modules
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/path.zsh
source ~/.config/zsh/nvm.zsh

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

**Step 3: Écrire aliases.zsh**

```zsh
alias reload="source ~/.zshrc"

alias c="clear"
alias e="exit"

alias n="nvim"
alias t="tmux"

alias g="git"
alias ga="git add ."
alias gs="git status -s"
alias gp="git push"

alias cc="claude --dangerously-skip-permissions"
alias ccc="claude --dangerously-skip-permissions -c"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
```

**Step 4: Écrire path.zsh**

```zsh
export PATH="$HOME/.local/bin:$PATH"

# JetBrains Toolbox
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Rust/Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
```

**Step 5: Écrire nvm.zsh**

```zsh
export NVM_DIR="$HOME/.nvm"
[ -s "/usr/share/nvm/init-nvm.sh" ] && \. "/usr/share/nvm/init-nvm.sh"

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Rebasculer sur default (Node $(nvm version default))"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
```

**Step 6: Commit**

```bash
git add zsh/
git commit -m "feat(zsh): add consolidated zsh config"
```

---

### Task 4: Package ZSH — Déployer avec stow

**Step 1: Supprimer les anciens fichiers (remplacés par symlinks)**

```bash
rm ~/.zshrc ~/.config.zsh ~/.alias.zsh ~/.nvm-config.zsh
```

**Step 2: Créer le dossier cible si absent**

```bash
mkdir -p ~/.config/zsh
```

**Step 3: Stow le package**

```bash
cd ~/.dotfiles && stow zsh
```

**Step 4: Vérifier les symlinks**

```bash
ls -la ~/.zshrc ~/.config/zsh/
```

Expected: `.zshrc -> .dotfiles/zsh/.zshrc`, fichiers dans `.config/zsh/` pointant vers `.dotfiles/zsh/.config/zsh/`

**Step 5: Tester le shell**

```bash
zsh -i -c 'echo "ZSH OK — Theme: $ZSH_THEME — Node: $(node -v 2>/dev/null || echo N/A)"'
```

Expected: `ZSH OK — Theme: powerlevel10k/powerlevel10k — Node: v2X.X.X`

---

### Task 5: Package git

**Files:**
- Create: `~/.dotfiles/git/.gitconfig`

**Step 1: Déplacer le fichier**

```bash
mkdir -p ~/.dotfiles/git
mv ~/.gitconfig ~/.dotfiles/git/.gitconfig
cd ~/.dotfiles && stow git
```

**Step 2: Vérifier**

```bash
ls -la ~/.gitconfig
git config user.name
```

Expected: symlink + "axelhamil"

**Step 3: Commit**

```bash
cd ~/.dotfiles && git add git/ && git commit -m "feat(git): add gitconfig"
```

---

### Task 6: Package tmux

**Files:**
- Move: `~/.tmux.conf` → `~/.dotfiles/tmux/.tmux.conf`

**Step 1: Déplacer et stow**

```bash
mkdir -p ~/.dotfiles/tmux
mv ~/.tmux.conf ~/.dotfiles/tmux/.tmux.conf
cd ~/.dotfiles && stow tmux
```

**Step 2: Vérifier**

```bash
ls -la ~/.tmux.conf
```

Expected: symlink

**Step 3: Commit**

```bash
cd ~/.dotfiles && git add tmux/ && git commit -m "feat(tmux): add tmux config"
```

---

### Task 7: Package p10k

**Files:**
- Move: `~/.p10k.zsh` → `~/.dotfiles/p10k/.p10k.zsh`

**Step 1: Déplacer et stow**

```bash
mkdir -p ~/.dotfiles/p10k
mv ~/.p10k.zsh ~/.dotfiles/p10k/.p10k.zsh
cd ~/.dotfiles && stow p10k
```

**Step 2: Vérifier**

```bash
ls -la ~/.p10k.zsh
```

Expected: symlink

**Step 3: Commit**

```bash
cd ~/.dotfiles && git add p10k/ && git commit -m "feat(p10k): add powerlevel10k config"
```

---

### Task 8: Package kitty

**Files:**
- Move: `~/.config/kitty/kitty.conf` + `current-theme.conf`

**Step 1: Déplacer (sans les .bak)**

```bash
mkdir -p ~/.dotfiles/kitty/.config/kitty
mv ~/.config/kitty/kitty.conf ~/.dotfiles/kitty/.config/kitty/
mv ~/.config/kitty/current-theme.conf ~/.dotfiles/kitty/.config/kitty/
rm ~/.config/kitty/*.bak
rmdir ~/.config/kitty 2>/dev/null || rm -r ~/.config/kitty
cd ~/.dotfiles && stow kitty
```

**Step 2: Vérifier**

```bash
ls -la ~/.config/kitty/
```

Expected: symlinks

**Step 3: Commit**

```bash
cd ~/.dotfiles && git add kitty/ && git commit -m "feat(kitty): add kitty terminal config"
```

---

### Task 9: Package hypr

**Files:**
- Move: tout `~/.config/hypr/`

**Step 1: Déplacer**

```bash
mkdir -p ~/.dotfiles/hypr/.config
mv ~/.config/hypr ~/.dotfiles/hypr/.config/hypr
cd ~/.dotfiles && stow hypr
```

**Step 2: Vérifier**

```bash
ls -la ~/.config/hypr/
ls ~/.config/hypr/hyprland.conf
```

Expected: symlink du dossier

**Step 3: Commit**

```bash
cd ~/.dotfiles && git add hypr/ && git commit -m "feat(hypr): add hyprland config"
```

---

### Task 10: Packages waybar, dunst, wofi, wlogout, fastfetch

**Step 1: Déplacer chaque config**

```bash
for pkg in waybar dunst wofi wlogout fastfetch; do
  mkdir -p ~/.dotfiles/$pkg/.config
  mv ~/.config/$pkg ~/.dotfiles/$pkg/.config/$pkg
  cd ~/.dotfiles && stow $pkg
done
```

**Step 2: Vérifier tous les symlinks**

```bash
for pkg in waybar dunst wofi wlogout fastfetch; do
  echo "--- $pkg ---"
  ls -la ~/.config/$pkg
done
```

Expected: tous des symlinks

**Step 3: Commit**

```bash
cd ~/.dotfiles && git add waybar/ dunst/ wofi/ wlogout/ fastfetch/
git commit -m "feat: add waybar, dunst, wofi, wlogout, fastfetch configs"
```

---

### Task 11: Nettoyage des fichiers obsolètes

**Step 1: Supprimer les backups et fichiers morts**

```bash
rm -f ~/.zshrc.bck ~/.bash_profile.bak 2>/dev/null
rm -rf ~/.config/fish 2>/dev/null
```

**Step 2: Vérifier qu'il ne reste pas de fichiers orphelins**

```bash
ls ~/.config.zsh ~/.alias.zsh ~/.nvm-config.zsh 2>&1
```

Expected: "No such file or directory" pour tous

**Step 3: Commit final**

```bash
cd ~/.dotfiles && git status
git commit --allow-empty -m "chore: cleanup complete"
```

---

### Task 12: Validation finale

**Step 1: Vérifier tous les symlinks stow**

```bash
cd ~/.dotfiles && stow --no-folding -nv */ 2>&1
```

Expected: Aucun conflit

**Step 2: Test complet du shell**

```bash
zsh -i -c '
echo "=== Validation ==="
echo "Theme: $ZSH_THEME"
echo "Node: $(node -v 2>/dev/null)"
echo "Git user: $(git config user.name)"
echo "Editor: $EDITOR"
echo "Bun: $(bun -v 2>/dev/null)"
echo "PNPM: $(pnpm -v 2>/dev/null)"
echo "=== OK ==="
'
```

**Step 3: Vérifier le repo**

```bash
cd ~/.dotfiles && git log --oneline
```
