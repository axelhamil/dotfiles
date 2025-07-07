# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

CASE_SENSITIVE="true"

zstyle ':omz:update' mode auto
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

plugins=(git gh kitty nvm podman postgres rust ssh thefuck themes tmux vscode zsh-autosuggestions alias-finder)

source $ZSH/oh-my-zsh.sh

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

## alias
alias c="clear"
alias e="exit"

alias docker=podman

alias n="nvim"
alias t="tmux"
alias g="git"
alias ga="git add ."
alias gs="git status -s"
alias gp="git push"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

##--- nvm config
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
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
##--- end nvm config

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh



# pnpm
export PNPM_HOME="/Users/axelhamilcaro/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
