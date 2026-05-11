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
  kitty podman postgres
  ssh themes
  tmux vscode
  fzf
  zsh-autosuggestions zsh-syntax-highlighting alias-finder
)

zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' longer yes
zstyle ':omz:plugins:alias-finder' exact yes
zstyle ':omz:plugins:alias-finder' cheaper yes

KEYTIMEOUT=1
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

source $ZSH/oh-my-zsh.sh

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# Modules
source ~/.config/zsh/aliases.zsh
source ~/.config/zsh/path.zsh
source ~/.config/zsh/nvm.zsh
# zoxide (smart cd)
eval "$(zoxide init zsh)"

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
