alias reload="source ~/.zshrc"

alias c="clear"
alias e="exit"

alias n="nvim"
alias t="tmux"

alias g="git"
alias ga="git add ."
alias gs="git status -s"
alias gp="git push"
alias lg="lazygit"
alias lzd="lazydocker"

alias cc="claude --dangerously-skip-permissions"
alias ccc="claude --dangerously-skip-permissions -c"

# eza (remplace ls)
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias lt="eza -la --icons --tree --level=2"

# bat (remplace cat)
alias cat="bat --paging=never"

# fd (remplace find)
alias find="fd"

# ripgrep
alias grep="rg"

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
