#!/usr/bin/env bash
# updates-cache.sh — sert le compteur de mises à jour à waybar depuis un cache.
#
# Pourquoi un cache : appelé directement en `exec`, updates-info.sh n'est
# jamais rendu par waybar (checkupdates -> pacman/fakeroot ; le module reste
# vide alors que le script sort bien le JSON). Un simple `cat` d'un fichier,
# lui, s'affiche sans problème. On découple donc la collecte du rendu :
# waybar lit le cache, le rafraîchissement tourne détaché en arrière-plan.

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates.json"
MAX_AGE=900

if [ "$1" = "--refresh" ]; then
    tmp="${CACHE}.$$"
    ~/.config/waybar/updates-info.sh > "$tmp" 2>/dev/null </dev/null
    mv -f "$tmp" "$CACHE"
    exit 0
fi

stale=1
if [ -f "$CACHE" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    [ "$age" -lt "$MAX_AGE" ] && stale=0
fi

[ "$stale" -eq 1 ] && setsid -f "$0" --refresh >/dev/null 2>&1 </dev/null

cat "$CACHE" 2>/dev/null
