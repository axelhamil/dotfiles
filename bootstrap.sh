#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH="${ZSH:-$XDG_DATA_HOME/oh-my-zsh}"

PACKAGES=(zsh git npm mise agents)
BACKUP_DIR="$XDG_STATE_HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

info()  { printf '\033[34m→\033[0m %s\n' "$*"; }
ok()    { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m!\033[0m %s\n' "$*"; }

usage() {
  cat <<EOF
Usage: ./bootstrap.sh [packages...]

Default: zsh git npm mise agents
Optional: aerospace

Oh My Zsh → \$XDG_DATA_HOME/oh-my-zsh
Configs   → XDG dirs via stow-style symlinks
Backups   → \$XDG_STATE_HOME/dotfiles-backup-*
EOF
}

backup() {
  local target="$1"
  mkdir -p "$BACKUP_DIR/$(dirname "${target#"$HOME"/}")"
  mv "$target" "$BACKUP_DIR/${target#"$HOME"/}"
  warn "backed up $target → $BACKUP_DIR"
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
  mkdir -p \
    "$XDG_STATE_HOME/zsh" \
    "$XDG_STATE_HOME/less" \
    "$XDG_STATE_HOME/python" \
    "$XDG_STATE_HOME/sqlite" \
    "$XDG_STATE_HOME/npm/logs" \
    "$XDG_STATE_HOME/wget" \
    "$XDG_CACHE_HOME/zsh" \
    "$XDG_CACHE_HOME/npm" \
    "$XDG_CACHE_HOME/python" \
    "$XDG_DATA_HOME/gnupg" \
    "$XDG_CONFIG_HOME/git" \
    "$XDG_CONFIG_HOME/wget"

  chmod 700 "$XDG_DATA_HOME/gnupg" 2>/dev/null || true

  if [[ ! -f "$XDG_CONFIG_HOME/git/local" ]]; then
    cp "$DOTFILES/git/.config/git/local.example" "$XDG_CONFIG_HOME/git/local"
    warn "created ~/.config/git/local — fill in your email"
  fi

  if [[ ! -f "$XDG_CONFIG_HOME/wget/wgetrc" ]]; then
    printf 'hsts-file = %s\n' "$XDG_STATE_HOME/wget/hsts" > "$XDG_CONFIG_HOME/wget/wgetrc"
  fi
}

link_agent_adapters() {
  mkdir -p "$HOME/.agents/skills" "$HOME/.codex" "$HOME/.claude"

  local canonical="$HOME/.agents/AGENTS.md"
  if [[ ! -e "$canonical" ]]; then
    warn "missing $canonical — link the agents package first"
    return 0
  fi

  local dest
  for dest in "$HOME/.codex/AGENTS.md" "$HOME/.claude/CLAUDE.md"; do
    if [[ -L "$dest" ]]; then
      [[ "$(readlink "$dest")" == "$canonical" ]] && continue
      rm "$dest"
    elif [[ -e "$dest" ]]; then
      warn "keep existing $dest"
      continue
    fi
    ln -s "$canonical" "$dest"
    ok "adapter $(basename "$(dirname "$dest")")/$(basename "$dest")"
  done
}

cleanup_home() {
  local leftover
  for leftover in \
    "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zlogin" "$HOME/.zlogout" \
    "$HOME/.p10k.zsh" "$HOME/.gitconfig" "$HOME/.npmrc"
  do
    [[ -e "$leftover" && ! -L "$leftover" ]] || continue
    backup "$leftover"
  done

  if [[ -d "$HOME/.oh-my-zsh" && ! -L "$HOME/.oh-my-zsh" ]]; then
    warn "found ~/.oh-my-zsh — leave it, but this setup uses $ZSH"
  fi
}

install_hooks() {
  chmod +x "$DOTFILES/.githooks/"* "$DOTFILES/scripts/check-leaks.py"
  git -C "$DOTFILES" config --local core.hooksPath .githooks
  ok "secret-scan hooks (pre-commit + pre-push)"
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

  link_agent_adapters
  install_hooks

  cleanup_home
  ok "done — open a new terminal (or run: exec zsh)"
}

main "$@"
