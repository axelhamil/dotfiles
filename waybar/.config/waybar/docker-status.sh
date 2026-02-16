#!/bin/bash
# docker-status.sh — Docker container status for waybar

if ! docker info &>/dev/null; then
    jq -cn '{text: "", tooltip: "Docker non demarre", class: "off"}'
    exit 0
fi

RUNNING=$(docker ps --format '{{.Names}}' 2>/dev/null)
COUNT=$(echo "$RUNNING" | grep -c '[^ ]')

if [ "$COUNT" -eq 0 ]; then
    jq -cn '{text: "", tooltip: "Docker actif, aucun container", class: "idle"}'
    exit 0
fi

TT="${COUNT} container(s) actif(s)"$'\n'"---"
while IFS= read -r name; do
    [ -z "$name" ] && continue
    STATUS=$(docker ps --filter "name=${name}" --format '{{.Status}}' 2>/dev/null)
    IMAGE=$(docker ps --filter "name=${name}" --format '{{.Image}}' 2>/dev/null | sed 's|.*/||; s|:.*||')
    TT+=$'\n'"  ${name} (${IMAGE}) - ${STATUS}"
done <<< "$RUNNING"
TT+=$'\n'$'\n'"Clic pour lazydocker"

jq -cn --arg text "$COUNT" --arg tooltip "$TT" --arg class "active" \
    '{text: $text, tooltip: $tooltip, class: $class}'
