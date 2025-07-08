alias reload="source ~/.zshrc"

alias c="clear"
alias e="exit"

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