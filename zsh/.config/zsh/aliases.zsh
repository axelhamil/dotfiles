alias reload="source $ZDOTDIR/.zshrc"

alias c="clear"
alias e="exit"

alias n="nvim"
alias t="tmux"

alias g="git"
alias ga="git add ."
alias gs="git status -s"
alias gp="git push"
alias lg="lazygit"

if command -v eza >/dev/null; then
  alias ls="eza --icons"
  alias ll="eza -la --icons --git"
  alias lt="eza -la --icons --tree --level=2"
else
  alias ll="ls -la"
fi

command -v bat >/dev/null && alias cat="bat --paging=never"
command -v fd >/dev/null && alias f="fd"
command -v rg >/dev/null && alias grep="rg"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
