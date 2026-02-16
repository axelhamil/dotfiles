#!/bin/bash
# scratchpad.sh — Scratchpad window counter for waybar

COUNT=$(hyprctl clients -j 2>/dev/null | jq '[.[] | select(.workspace.name == "special:magic")] | length')

if [ "${COUNT:-0}" -gt 0 ]; then
    WINDOWS=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.workspace.name == "special:magic") | .title' | head -5)
    TT="${COUNT} fenetre(s) dans le scratchpad"$'\n'"---"
    while IFS= read -r title; do
        [ -z "$title" ] && continue
        TT+=$'\n'"  ${title:0:40}"
    done <<< "$WINDOWS"
    TT+=$'\n'"Super+S pour afficher"
    jq -cn --arg text "$COUNT" --arg tooltip "$TT" --arg class "active" \
        '{text: $text, tooltip: $tooltip, class: $class}'
else
    jq -cn --arg text "" --arg tooltip "Scratchpad vide\nSuper+S pour toggle" --arg class "empty" \
        '{text: $text, tooltip: $tooltip, class: $class}'
fi
