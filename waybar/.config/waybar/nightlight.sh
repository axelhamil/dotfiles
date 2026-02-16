#!/bin/bash
# nightlight.sh — Toggle hyprsunset night light for waybar (jq)
# On click: toggle on/off

case "$1" in
    toggle)
        if pgrep -x hyprsunset &>/dev/null; then
            pkill -x hyprsunset
        else
            hyprsunset -t 3500 &
            disown
        fi
        exit 0
        ;;
esac

# Status output for waybar (JSON)
if pgrep -x hyprsunset &>/dev/null; then
    TEMP=$(ps aux | grep 'hyprsunset' | grep -oP '\-t\s*\K\d+' | head -1)
    [ -z "$TEMP" ] && TEMP="3500"
    TT="Veilleuse active (${TEMP}K)"$'\n'"Clic pour desactiver"
    jq -cn --arg text "ON" --arg tooltip "$TT" --arg class "on" \
        '{text: $text, tooltip: $tooltip, class: $class}'
else
    TT="Veilleuse inactive"$'\n'"Clic pour activer (3500K)"
    jq -cn --arg text "" --arg tooltip "$TT" --arg class "off" \
        '{text: $text, tooltip: $tooltip, class: $class}'
fi
