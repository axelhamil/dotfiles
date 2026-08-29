#!/usr/bin/env bash
# notif-count.sh — compteur de notifications SwayNC pour waybar.
# Remplace l'ancien dunst-count.sh : le démon actif est swaync, pas dunst.

COUNT=$(swaync-client -c 2>/dev/null)
[[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=0

DND=$(swaync-client -D 2>/dev/null)

BELL="󰂚"
BELL_BADGE="󰂞"
BELL_OFF="󰂛"

if [ "$DND" = "true" ]; then
    TEXT="$BELL_OFF"
    CLASS="dnd"
    TT="Ne pas déranger — ${COUNT} en attente"
elif [ "$COUNT" -gt 0 ]; then
    TEXT="$BELL_BADGE $COUNT"
    CLASS="active"
    TT="${COUNT} notification(s)"
else
    TEXT="$BELL"
    CLASS="idle"
    TT="Aucune notification"
fi

TT+=$'\n'"Clic : panneau · Droit : DnD · Milieu : tout effacer"

jq -cn --arg text "$TEXT" --arg tooltip "$TT" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
