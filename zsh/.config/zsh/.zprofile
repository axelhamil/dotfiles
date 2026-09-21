# Login shells only. Runs after /etc/zprofile (path_helper).

typeset -U path
path=("$HOME/.local/bin" $path)

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

[[ -d "$PNPM_HOME" ]] && path=("$PNPM_HOME" $path)
[[ -d "$BUN_INSTALL/bin" ]] && path=("$BUN_INSTALL/bin" $path)
[[ -d "$CARGO_HOME/bin" ]] && path=("$CARGO_HOME/bin" $path)
[[ -d "$GOPATH/bin" ]] && path=("$GOPATH/bin" $path)
[[ -d "$MISE_DATA_DIR/shims" ]] && path=("$MISE_DATA_DIR/shims" $path)

export PATH
