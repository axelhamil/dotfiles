#!/bin/bash
# gpu-info.sh — Rich GPU info for waybar tooltip

DATA=$(nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,utilization.memory,memory.used,memory.total,fan.speed,power.draw,power.limit,clocks.gr,clocks.mem,driver_version --format=csv,noheader,nounits 2>/dev/null)

[ -z "$DATA" ] && jq -cn '{text: "GPU ?", tooltip: "NVIDIA unavailable"}' && exit 0

IFS=',' read -r NAME TEMP GPU_UTIL MEM_UTIL MEM_USED MEM_TOTAL FAN POWER POWER_LIM CLK_GR CLK_MEM DRIVER <<< "$DATA"

for var in NAME TEMP GPU_UTIL MEM_UTIL MEM_USED MEM_TOTAL FAN POWER POWER_LIM CLK_GR CLK_MEM DRIVER; do
    eval "$var=\$(echo \"\$$var\" | xargs)"
done

CLASS="normal"
[ "$TEMP" -ge 65 ] && CLASS="warning"
[ "$TEMP" -ge 80 ] && CLASS="critical"

TEXT="${TEMP}"
MEM_USED_G=$(awk "BEGIN{printf \"%.1f\", $MEM_USED/1024}")
MEM_TOTAL_G=$(awk "BEGIN{printf \"%.0f\", $MEM_TOTAL/1024}")

TT="${NAME}"$'\n'
TT+="Temp: ${TEMP}C | GPU: ${GPU_UTIL}%"$'\n'
TT+="VRAM: ${MEM_USED_G}G / ${MEM_TOTAL_G}G (${MEM_UTIL}%)"$'\n'
TT+="Fan: ${FAN}% | Power: ${POWER}W / ${POWER_LIM}W"$'\n'
TT+="Clock: GPU ${CLK_GR} MHz | Mem ${CLK_MEM} MHz"$'\n'
TT+="Driver: ${DRIVER}"

jq -cn --arg text "$TEXT" --arg tooltip "$TT" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
