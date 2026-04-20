#!/usr/bin/env bash
# Stop hook : desktop notification via dunstify when Claude finishes a turn.
# Useful when AFK — don't miss that the turn is done.

set -euo pipefail

INPUT="$(cat)"
SESSION_ID="$(echo "$INPUT" | jq -r '.session_id // "unknown"')"
CWD="$(echo "$INPUT" | jq -r '.cwd // ""')"
PROJECT="$(basename "${CWD:-$PWD}")"

# Fire and forget. Urgency=low so it doesn't steal focus.
# Short timeout (3s) — just an ambient signal.
dunstify \
  -a "Claude Code" \
  -u low \
  -t 3000 \
  -i terminal \
  "Turn complete" \
  "$PROJECT" \
  >/dev/null 2>&1 &

exit 0
