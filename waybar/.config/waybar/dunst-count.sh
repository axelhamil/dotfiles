#!/bin/bash
# dunst-count.sh — Notification counter for waybar

WAITING=$(dunstctl count waiting 2>/dev/null || echo 0)
DISPLAYED=$(dunstctl count displayed 2>/dev/null || echo 0)
PAUSED=$(dunstctl is-paused 2>/dev/null || echo false)

ACTIVE=$((WAITING + DISPLAYED))

if [ "$PAUSED" = "true" ]; then
    echo "DnD"
elif [ "$ACTIVE" -gt 0 ]; then
    echo "$ACTIVE"
else
    echo "0"
fi
