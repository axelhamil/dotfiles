#!/bin/bash
# sysmon.sh — Smart system monitor for waybar (jq)
# Dynamically shows the most relevant metric + top processes in tooltip

# ── Gather metrics ──
CPU=$(awk '/^cpu /{u=$2+$4; t=$2+$3+$4+$5+$6+$7+$8} END{printf "%.0f", u*100/t}' /proc/stat)
MEM_PCT=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')
MEM_USED=$(free -h | awk '/Mem:/{print $3}')
MEM_TOTAL=$(free -h | awk '/Mem:/{print $2}')
GPU_TEMP=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null || echo "0")
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(awk '{print $1}' /proc/loadavg)

# ── Decide what to highlight ──
if [ "${GPU_TEMP:-0}" -ge 75 ]; then
    TEXT="GPU ${GPU_TEMP}C"
    CLASS="critical"
elif [ "$CPU" -ge 80 ]; then
    TEXT="CPU ${CPU}%"
    CLASS="warning"
elif [ "$MEM_PCT" -ge 85 ]; then
    TEXT="RAM ${MEM_PCT}%"
    CLASS="warning"
elif [ "${GPU_UTIL:-0}" -ge 50 ]; then
    TEXT="GPU ${GPU_UTIL}%"
    CLASS="active"
elif [ "$CPU" -ge 40 ]; then
    TEXT="CPU ${CPU}%"
    CLASS="normal"
else
    TEXT="sys"
    CLASS="idle"
fi

# ── Build tooltip ──
TT="Systeme - ${UPTIME}"$'\n'
TT+="Load: ${LOAD}"$'\n'
TT+="---"$'\n'
TT+="CPU: ${CPU}% | RAM: ${MEM_USED}/${MEM_TOTAL} (${MEM_PCT}%)"$'\n'
TT+="GPU: ${GPU_TEMP}C | ${GPU_UTIL}% util"$'\n'
TT+="---"$'\n'

# Top 5 CPU consumers
TT+="Top CPU:"$'\n'
while IFS= read -r line; do
    [ -z "$line" ] && continue
    TT+="${line}"$'\n'
done <<< "$(ps aux --sort=-%cpu | awk 'NR>1 && NR<=6 {
    cmd=$11; gsub(/.*\//, "", cmd); printf "  %5.1f%%  %s\n", $3, cmd
}')"

TT+="---"$'\n'

# Top 5 RAM consumers
TT+="Top RAM:"$'\n'
while IFS= read -r line; do
    [ -z "$line" ] && continue
    TT+="${line}"$'\n'
done <<< "$(ps aux --sort=-%mem | awk 'NR>1 && NR<=6 {
    cmd=$11; gsub(/.*\//, "", cmd); rss=$6/1024; printf "  %6.0fM  %s\n", rss, cmd
}')"

jq -cn --arg text "$TEXT" --arg tooltip "$TT" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
