#!/usr/bin/env bash
# PostToolUse hook : run `tsc --noEmit` only if the edited file is inside a TS project.
# Walks up from file_path to find tsconfig.json. If absent → exit 0 silently (no-op).
# If present → run tsc in that project's dir, print first 20 lines of output.

set -euo pipefail

INPUT="$(cat)"
FILE_PATH="$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')"

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Only check TS/TSX/JS/JSX files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.mts|*.cts) ;;
  *) exit 0 ;;
esac

# Walk up to find tsconfig.json
DIR="$(dirname "$FILE_PATH")"
PROJECT_ROOT=""
while [[ "$DIR" != "/" && "$DIR" != "$HOME" ]]; do
  if [[ -f "$DIR/tsconfig.json" ]]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR="$(dirname "$DIR")"
done

if [[ -z "$PROJECT_ROOT" ]]; then
  exit 0
fi

# Skip if no local tsc (avoid `npx tsc` network/install cost)
if [[ ! -x "$PROJECT_ROOT/node_modules/.bin/tsc" ]] && ! command -v tsc >/dev/null 2>&1; then
  exit 0
fi

cd "$PROJECT_ROOT"
if [[ -x "./node_modules/.bin/tsc" ]]; then
  TSC="./node_modules/.bin/tsc"
else
  TSC="tsc"
fi

# Timeout so a slow tsc doesn't stall the turn
timeout 15 "$TSC" --noEmit --pretty 2>&1 | head -20 || true
