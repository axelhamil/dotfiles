#!/bin/bash
# popup.sh — Waybar modal popup: toggle + close on focus loss
# Usage: popup.sh <window-class> <command...>

CLASS="$1"; shift

# Toggle: if already open, close it and exit
if hyprctl clients -j | jq -e ".[] | select(.class == \"$CLASS\")" &>/dev/null; then
    hyprctl dispatch closewindow "class:^(${CLASS})$" &>/dev/null
    exit 0
fi

# Launch the app
"$@" &
APP_PID=$!

# Wait for the window to appear (max 3s)
ADDR=""
for _ in $(seq 1 30); do
    ADDR=$(hyprctl clients -j | jq -r ".[] | select(.class == \"$CLASS\") | .address" | head -1)
    [ -n "$ADDR" ] && break
    sleep 0.1
done
[ -z "$ADDR" ] && exit 1

MINE="${ADDR#0x}"

# Poll-based focus watcher (more forgiving than instant IPC)
while true; do
    sleep 0.8

    # Check if our window still exists
    if ! hyprctl clients -j | jq -e ".[] | select(.address == \"$ADDR\")" &>/dev/null; then
        break
    fi

    # Check if our window has focus
    ACTIVE=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
    ACTIVE="${ACTIVE#0x}"

    if [[ -n "$ACTIVE" && "$ACTIVE" != "$MINE" ]]; then
        # Focus is on another window — give a grace period and re-check
        sleep 0.4
        ACTIVE2=$(hyprctl activewindow -j 2>/dev/null | jq -r '.address // empty')
        ACTIVE2="${ACTIVE2#0x}"
        if [[ -n "$ACTIVE2" && "$ACTIVE2" != "$MINE" ]]; then
            hyprctl dispatch closewindow "address:${ADDR}" &>/dev/null
            break
        fi
    fi
done &
WATCH_PID=$!

# When the app exits, kill the watcher too
wait "$APP_PID" 2>/dev/null
kill "$WATCH_PID" 2>/dev/null
