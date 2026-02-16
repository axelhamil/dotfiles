#!/usr/bin/env bash
# ── Tray item counter for Waybar drawer trigger ──
# Queries D-Bus StatusNotifierWatcher for system tray items

raw=$(busctl --user get-property org.kde.StatusNotifierWatcher \
    /StatusNotifierWatcher org.kde.StatusNotifierWatcher \
    RegisteredStatusNotifierItems 2>/dev/null) || raw=""

# Extract count from busctl output: "as N ..."
count=0
[[ "$raw" =~ ^as\ ([0-9]+) ]] && count="${BASH_REMATCH[1]}"

if (( count == 0 )); then
    jq -cn '{text:"0",tooltip:"Tray vide",class:"empty"}'
    exit 0
fi

# Extract registered item identifiers
mapfile -t items < <(grep -oP '"\K[^"]+' <<< "$raw")

# Build tooltip with human-readable app names
names=()
for item in "${items[@]}"; do
    bus="${item%%/*}"
    path="/${item#*/}"

    # Get app Id (more reliable than Title)
    id=$(busctl --user get-property "$bus" "$path" \
        org.kde.StatusNotifierItem Id 2>/dev/null | \
        sed -n 's/^s "\(.*\)"$/\1/p')

    [[ -n "$id" ]] && names+=("$id")
done

if (( ${#names[@]} > 0 )); then
    list=$(printf '\\n  %s' "${names[@]}")
    tooltip="${count} app(s)${list}"
else
    tooltip="${count} app(s) dans le tray"
fi

jq -cn --arg t "$count" --arg tt "$tooltip" --arg c "active" \
    '{text:$t,tooltip:$tt,class:$c}'
