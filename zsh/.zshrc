# Cursor Agent shell integration.
# Cached: `agent shell-integration` forks a 1.6s binary on every shell start.
# Lazy chat: upstream runs `agent create-chat` (1.5s, network) before the first
# prompt; it is stripped here and deferred to first use of agent / please-fix /
# agent mode. Cache is rebuilt automatically when the agent binary changes.
_cursor_int="${XDG_CACHE_HOME:-$HOME/.cache}/cursor-agent-shell-integration.zsh"
if [[ ! -s "$_cursor_int" || "$_cursor_int" -ot "$HOME/.local/bin/agent" ]]; then
  ~/.local/bin/agent shell-integration zsh \
    | sed '/^# Create a new chat session at the start of each shell session$/,/^fi$/d' \
    > "$_cursor_int"
  cat >> "$_cursor_int" <<'CURSOR_LAZY_CHAT'

_cursor_chat_ensure() {
  [[ -n "$CURSOR_AGENT_CHAT_ID" ]] && return
  export CURSOR_AGENT_CHAT_ID="$(command agent create-chat)"
}

if [[ -t 0 ]] && (( $+functions[agent] )); then
  functions -c agent _cursor_agent_orig
  agent() { _cursor_chat_ensure; _cursor_agent_orig "$@"; }

  functions -c please-fix _cursor_please_fix_orig
  please-fix() { _cursor_chat_ensure; _cursor_please_fix_orig "$@"; }

  functions -c please-fix-or-accept-line _cursor_accept_orig
  please-fix-or-accept-line() {
    if (( zsh_agent_mode )) || [[ -z "$BUFFER" && $_last_command_failed -eq 1 ]]; then
      _cursor_chat_ensure
    fi
    _cursor_accept_orig "$@"
  }
  zle -N please-fix-or-accept-line
fi
CURSOR_LAZY_CHAT
fi
source "$_cursor_int"
unset _cursor_int
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
  kitty docker postgres
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

# bun completions
[ -s "/home/axel/.bun/_bun" ] && source "/home/axel/.bun/_bun"
