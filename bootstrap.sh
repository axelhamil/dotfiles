#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH="${ZSH:-$XDG_DATA_HOME/oh-my-zsh}"

PACKAGES=(zsh git)
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

info()  { printf '\033[34m→\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m!\033[0m %s\n' "$*"; }

usage() {
  cat <<EOF
Usage: ./bootstrap.sh [packages...]

Default packages: zsh git
Available:        zsh git aerospace

Oh My Zsh is installed to \$XDG_DATA_HOME/oh-my-zsh
Configs are symlinked from ~/.dotfiles into \$HOME (stow-style).
EOF
}

backup() {
  local target="$1"
  mkdir -p "$BACKUP_DIR/$(dirname "${target#"$HOME"/}")"
  mv "$target" "$BACKUP_DIR/${target#"$HOME"/}"
  warn "backed up $target"
}

link_file() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    [[ "$current" == "$src" ]] && return 0
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    backup "$dest"
  fi

  ln -s "$src" "$dest"
}

link_package() {
  local pkg="$1"
  local src="$DOTFILES/$pkg"

  if [[ ! -d "$src" ]]; then
    warn "package '$pkg' not found, skipping"
    return 1
  fi

  info "linking $pkg"
  while IFS= read -r -d '' file; do
    local rel="${file#"$src"/}"
    [[ "$rel" == *.example ]] && continue
    link_file "$file" "$HOME/$rel"
  done < <(find "$src" -type f -print0)
  ok "$pkg"
}

install_omz() {
  if [[ -d "$ZSH" ]]; then
    ok "oh-my-zsh already installed"
    return 0
  fi

  info "installing oh-my-zsh → $ZSH"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes ZSH="$ZSH" \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  ok "oh-my-zsh"
}

clone_if_missing() {
  local repo="$1"
  local dest="$2"

  if [[ -d "$dest" ]]; then
    ok "$(basename "$dest") already installed"
    return 0
  fi

  info "cloning $(basename "$dest")"
  git clone --depth=1 "$repo" "$dest"
  ok "$(basename "$dest")"
}

install_plugins() {
  local custom="${ZSH_CUSTOM:-$ZSH/custom}"

  clone_if_missing https://github.com/romkatv/powerlevel10k.git \
    "$custom/themes/powerlevel10k"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions \
    "$custom/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$custom/plugins/zsh-syntax-highlighting"
}

prepare_dirs() {
  mkdir -p "$XDG_STATE_HOME/zsh" "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME/git"

  if [[ ! -f "$XDG_CONFIG_HOME/git/local" ]]; then
    cp "$DOTFILES/git/.config/git/local.example" "$XDG_CONFIG_HOME/git/local"
    warn "created ~/.config/git/local — fill in your email"
  fi
}

cleanup_home() {
  local leftover
  for leftover in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zlogin" "$HOME/.p10k.zsh"; do
    [[ -e "$leftover" && ! -L "$leftover" ]] || continue
    backup "$leftover"
  done
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  [[ $# -gt 0 ]] && PACKAGES=("$@")

  prepare_dirs
  install_omz
  install_plugins

  local pkg
  for pkg in "${PACKAGES[@]}"; do
    link_package "$pkg"
  done

  cleanup_home
  ok "done — open a new terminal (or run: exec zsh)"
}

main "$@"
