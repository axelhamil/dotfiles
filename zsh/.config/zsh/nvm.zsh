export NVM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"

_nvm_init() {
  local candidates=(
    "$NVM_DIR/nvm.sh"
    "$HOME/.nvm/nvm.sh"
    "/opt/homebrew/opt/nvm/nvm.sh"
    "/usr/local/opt/nvm/nvm.sh"
  )

  local file
  for file in $candidates; do
    if [[ -s "$file" ]]; then
      . "$file"
      return 0
    fi
  done

  return 1
}

nvm() {
  unset -f nvm node npm npx pnpm 2>/dev/null
  _nvm_init || return 1
  nvm "$@"
}

node() { unset -f nvm node npm npx pnpm 2>/dev/null; _nvm_init || return 1; node "$@"; }
npm()  { unset -f nvm node npm npx pnpm 2>/dev/null; _nvm_init || return 1; npm "$@"; }
npx()  { unset -f nvm node npm npx pnpm 2>/dev/null; _nvm_init || return 1; npx "$@"; }
pnpm() { unset -f nvm node npm npx pnpm 2>/dev/null; _nvm_init || return 1; pnpm "$@"; }
