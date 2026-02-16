export NVM_DIR="$HOME/.nvm"

# Lazy-load NVM — ne charge que quand on utilise node/npm/nvm/npx
_nvm_lazy_load() {
  unset -f nvm node npm npx pnpm 2>/dev/null
  [ -s "/usr/share/nvm/init-nvm.sh" ] && \. "/usr/share/nvm/init-nvm.sh"

  # Auto-switch .nvmrc après init
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
}

# Stubs qui déclenchent le lazy-load
nvm()  { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm()  { _nvm_lazy_load; npm "$@"; }
npx()  { _nvm_lazy_load; npx "$@"; }
pnpm() { _nvm_lazy_load; pnpm "$@"; }
