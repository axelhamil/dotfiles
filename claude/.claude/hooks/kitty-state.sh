#!/usr/bin/env bash
set -u

cat >/dev/null

[[ -n "${KITTY_WINDOW_ID:-}" && -n "${KITTY_LISTEN_ON:-}" ]] || exit 0

if [[ "${1:-}" == "clear" ]]; then
  assignment="claude"
else
  assignment="claude=${1:?state required}"
fi

kitten @ set-user-vars --match "id:${KITTY_WINDOW_ID}" "$assignment" >/dev/null 2>&1 &
exit 0
