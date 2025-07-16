source ~/.config.zsh

source $ZSH/oh-my-zsh.sh

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/.alias.zsh

source ~/.nvm-config.zsh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/axelhamilcaro/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/axelhamilcaro/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/axelhamilcaro/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/axelhamilcaro/google-cloud-sdk/completion.zsh.inc'; fi
