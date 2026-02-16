#!/bin/bash
# updates-info.sh — Rich updates info for waybar

UPDATES=$(checkupdates 2>/dev/null)
COUNT=$(echo "$UPDATES" | grep -c '[^ ]')

[ "$COUNT" -eq 0 ] && exit 0

TEXT="${COUNT}"

TT="${COUNT} mises a jour"$'\n'"---"
SHOWN=0
while IFS= read -r line; do
    [ -z "$line" ] && continue
    PKG=$(echo "$line" | awk '{print $1}')
    OLD=$(echo "$line" | awk '{print $2}')
    NEW=$(echo "$line" | awk '{print $4}')
    TT+=$'\n'"${PKG}: ${OLD} -> ${NEW}"
    SHOWN=$((SHOWN + 1))
    [ "$SHOWN" -ge 15 ] && break
done <<< "$UPDATES"

[ "$COUNT" -gt 15 ] && TT+=$'\n'"... et $((COUNT - 15)) autres"
TT+=$'\n'$'\n'"Clic pour mettre a jour (yay -Syu)"

jq -cn --arg text "$TEXT" --arg tooltip "$TT" \
    '{text: $text, tooltip: $tooltip}'
