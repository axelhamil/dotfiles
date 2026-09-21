# Sourced for every zsh (login, interactive, scripts) via ~/.zshenv.
# PATH lives in path.zsh. Login shells apply it from .zprofile, after path_helper.

export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export SQLITE_HISTORY="$XDG_STATE_HOME/sqlite/history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"

export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export BUN_INSTALL="$XDG_DATA_HOME/bun"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

export GOPATH="$XDG_DATA_HOME/go"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"

export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME/docker-machine"

export MISE_DATA_DIR="$XDG_DATA_HOME/mise"
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"
export MISE_CACHE_DIR="$XDG_CACHE_HOME/mise"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"

export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
