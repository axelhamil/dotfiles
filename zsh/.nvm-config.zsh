export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

autoload -U add-zsh-hook

load-nvmrc() {
  if ! command -v nvm > /dev/null 2>&1; then
    echo "\033[31m❌ NVM is not installed. Please install it first: 🌐 https://github.com/nvm-sh/nvm\033[0m"
    return
  fi

  if [ -f .nvmrc ]; then
    local nvm_version
    nvm_version=$(cat .nvmrc)

    # Check if the current Node.js version matches the one in .nvmrc
    if [ "$(nvm current)" != "v$nvm_version" ]; then
      echo "\033[34m🔄 Switching to Node.js version $nvm_version...\033[0m"
      if nvm use "$nvm_version" > /dev/null 2>&1; then
        echo "\033[32m✅ Successfully switched to Node.js $(nvm current) 🚀\033[0m"
      else
        echo "\033[33m⚠️  Node.js version $nvm_version is not installed. Installing... ⏳\033[0m"
        if nvm install "$nvm_version" > /dev/null 2>&1; then
          echo "\033[32m✅ Installed and switched to Node.js $(nvm current) 🎉\033[0m"
        else
          echo "\033[31m❌ Failed to install Node.js $nvm_version. Please check your setup. 🛠️\033[0m"
        fi
      fi
    else
      echo "\033[36mℹ️  Node.js $(nvm current) is already active. No action needed. 👍\033[0m"
    fi
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc