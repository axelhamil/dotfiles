export PATH="$HOME/.local/bin:$PATH"

# JetBrains Toolbox
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Android SDK (XDG location)
export ANDROID_HOME="$HOME/.local/share/android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$HOME/.config/android"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$PATH"

# Go (XDG location)
export GOPATH="$HOME/.local/share/go"
export PATH="$GOPATH/bin:$PATH"

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
export PATH="$HOME/.cargo/bin:$PATH"
