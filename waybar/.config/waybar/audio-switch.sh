#!/bin/bash
# audio-switch.sh — Cycle through available PipeWire sinks
# Middle-click on volume to switch output device

SINKS=($(pactl list sinks short | awk '{print $2}'))
CURRENT=$(pactl get-default-sink)

# Find current index
IDX=0
for i in "${!SINKS[@]}"; do
    [[ "${SINKS[$i]}" == "$CURRENT" ]] && IDX=$i
done

# Cycle to next
NEXT=$(( (IDX + 1) % ${#SINKS[@]} ))
pactl set-default-sink "${SINKS[$NEXT]}"

# Notify
DESC=$(pactl list sinks 2>/dev/null | grep -A2 "Name: ${SINKS[$NEXT]}" | grep "Description:" | sed 's/.*Description: //')
notify-send -t 2000 -i audio-card "Audio Output" "$DESC"
