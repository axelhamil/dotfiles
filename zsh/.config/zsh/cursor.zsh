# Cursor Agent shell integration.
# Cached: `agent shell-integration` forks a binary on every shell start.
# Lazy chat: upstream runs `agent create-chat` before the first prompt;
# it is stripped here and deferred to first use of agent / please-fix.
_cursor_int="${XDG_CACHE_HOME:-$HOME/.cache}/cursor-agent-shell-integration.zsh"
_cursor_bin="$HOME/.local/bin/agent"

if [[ -o interactive && -t 0 && -x "$_cursor_bin" ]]; then
  if [[ ! -s "$_cursor_int" || "$_cursor_int" -ot "$_cursor_bin" ]] \
    || ! zsh -n "$_cursor_int" 2>/dev/null; then
    _cursor_tmp="${_cursor_int}.tmp.$$"
    "$_cursor_bin" shell-integration zsh \
      | sed '/^# Create a new chat session at the start of each shell session$/,/^fi$/d' \
      > "$_cursor_tmp"
    cat >> "$_cursor_tmp" <<'CURSOR_LAZY_CHAT'

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
    if zsh -n "$_cursor_tmp" 2>/dev/null; then
      mv -f "$_cursor_tmp" "$_cursor_int"
    else
      rm -f "$_cursor_tmp"
    fi
  fi
  [[ -s "$_cursor_int" ]] && source "$_cursor_int"
fi

unset _cursor_int _cursor_bin _cursor_tmp
