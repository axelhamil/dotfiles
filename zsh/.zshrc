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
  fzf
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
source ~/.config/zsh/ollama.zsh

# zoxide (smart cd)
eval "$(zoxide init zsh)"

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
