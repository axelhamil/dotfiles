#!/usr/bin/env bash
# SessionStart hook : inject git context if cwd is a git repo.
# Emits JSON with additionalContext so Claude sees branch + uncommitted changes + recent commits.

set -euo pipefail

INPUT="$(cat)"
CWD="$(echo "$INPUT" | jq -r '.cwd // empty')"

if [[ -z "$CWD" ]]; then
  CWD="$PWD"
fi

cd "$CWD" 2>/dev/null || exit 0

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

BRANCH="$(git branch --show-current 2>/dev/null || echo 'detached')"
STATUS="$(git status --short 2>/dev/null | head -15)"
COMMITS="$(git log --oneline -5 2>/dev/null)"

# Skip if nothing interesting to report (clean repo, no commits)
if [[ -z "$STATUS" && -z "$COMMITS" ]]; then
  exit 0
fi

# Build markdown context
CONTEXT="## Git context
**Branch**: \`$BRANCH\`"

if [[ -n "$STATUS" ]]; then
  CONTEXT="$CONTEXT

**Uncommitted changes**:
\`\`\`
$STATUS
\`\`\`"
fi

if [[ -n "$COMMITS" ]]; then
  CONTEXT="$CONTEXT

**Recent commits**:
\`\`\`
$COMMITS
\`\`\`"
fi

# Emit JSON per Claude Code hooks spec
jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'
