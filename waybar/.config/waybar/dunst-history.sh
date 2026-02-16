#!/usr/bin/env bash
# ── Dunst notification history viewer (wofi) ──

history=$(dunstctl history 2>/dev/null)
count=$(echo "$history" | jq '.data[0] | length' 2>/dev/null)

if [[ -z "$count" || "$count" == "0" ]]; then
    dunstify -a "Waybar" "Historique vide" -t 2000
    exit 0
fi

# Format: "app | summary - body" (body tronqué à 80 chars)
echo "$history" | jq -r '
    .data[0][] |
    "\(.appname.data) | \(.summary.data)\(
        if .body.data != "" and .body.data != .summary.data
        then " - " + (.body.data | gsub("\n"; " ") | .[0:80])
        else "" end
    )"
' 2>/dev/null | wofi --show dmenu \
    --prompt "Notifications" \
    --width 650 \
    --height 400 \
    --cache-file /dev/null
