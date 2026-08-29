#!/usr/bin/env bash
# focus-primary.sh — ramène le focus sur l'écran principal après le démarrage.
# Nécessaire parce que les exec_cmd suivants (scratchpads, keepassxc, cider)
# volent le focus en s'ouvrant. Appelé en dernier depuis hyprland.lua.
#
# Hyprland 0.56 en configProvider=lua : `hyprctl dispatch focusmonitor DP-2`
# n'est plus valide, l'argument est évalué comme du Lua.

PRIMARY="${1:-DP-2}"

sleep 5
hyprctl dispatch "hl.dsp.focus({ monitor = \"${PRIMARY}\" })"
