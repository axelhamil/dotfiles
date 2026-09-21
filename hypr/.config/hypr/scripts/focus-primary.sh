#!/usr/bin/env bash
# focus-primary.sh — ramène curseur + focus clavier sur l'écran principal.
# cursor.default_monitor pose le curseur au boot ; ce script rattrape le
# vol de focus des apps autostart (keepassxc, cider, scratchpads).
#
# Hyprland 0.56 configProvider=lua : `hyprctl dispatch focusmonitor`
# n'est plus valide. Passer par `hyprctl eval` + le dispatcher Lua.

PRIMARY="${1:-DP-2}"

sleep 2
hyprctl eval "hl.dispatch(hl.dsp.focus({ monitor = \"${PRIMARY}\", workspace = 1 }))"
