#!/usr/bin/env bash
# gpu-info.sh — GPU NVIDIA pour waybar : charge + température en un coup d'oeil,
# détail complet (VRAM, conso, clocks) dans le tooltip.

ICON="<span color='#7f849c'>󰢮</span>"

DATA=$(nvidia-smi \
    --query-gpu=name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,fan.speed,power.draw,power.limit,clocks.gr,clocks.mem,driver_version \
    --format=csv,noheader,nounits 2>/dev/null | head -n1)

if [ -z "$DATA" ]; then
    jq -cn --arg text "$ICON --" --arg tooltip "NVIDIA indisponible" \
        '{text: $text, tooltip: $tooltip, class: "unavailable"}'
    exit 0
fi

IFS=',' read -r NAME TEMP GPU_UTIL MEM_UTIL MEM_USED MEM_TOTAL FAN POWER POWER_LIM CLK_GR CLK_MEM DRIVER <<< "$DATA"

trim() { echo "$1" | xargs; }
NAME=$(trim "$NAME");           TEMP=$(trim "$TEMP")
GPU_UTIL=$(trim "$GPU_UTIL");   MEM_UTIL=$(trim "$MEM_UTIL")
MEM_USED=$(trim "$MEM_USED");   MEM_TOTAL=$(trim "$MEM_TOTAL")
FAN=$(trim "$FAN");             POWER=$(trim "$POWER")
POWER_LIM=$(trim "$POWER_LIM"); CLK_GR=$(trim "$CLK_GR")
CLK_MEM=$(trim "$CLK_MEM");     DRIVER=$(trim "$DRIVER")

CLASS="normal"
[ "${TEMP:-0}" -ge 70 ] && CLASS="warning"
[ "${TEMP:-0}" -ge 83 ] && CLASS="critical"

TEXT=$(printf '%s %s%% %s°' "$ICON" "$GPU_UTIL" "$TEMP")

VRAM_USED_G=$(awk "BEGIN{printf \"%.1f\", ${MEM_USED:-0}/1024}")
VRAM_TOTAL_G=$(awk "BEGIN{printf \"%.0f\", ${MEM_TOTAL:-1}/1024}")

TT="${NAME}"$'\n'
TT+="Charge  ${GPU_UTIL}%   Temp  ${TEMP}°C"$'\n'
TT+="VRAM  ${VRAM_USED_G}G / ${VRAM_TOTAL_G}G  (bus ${MEM_UTIL}%)"$'\n'
TT+="Ventilo  ${FAN}%   Conso  ${POWER}W / ${POWER_LIM}W"$'\n'
TT+="Horloges  GPU ${CLK_GR} MHz   Mem ${CLK_MEM} MHz"$'\n'
TT+="Pilote  ${DRIVER}"

jq -cn --arg text "$TEXT" --arg tooltip "$TT" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
