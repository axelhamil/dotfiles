#!/bin/bash
# audio-info.sh — Display current PipeWire sink format for waybar
# Returns JSON: {"text": "48kHz/32b", "tooltip": "...", "class": "..."}

SINK=$(pactl get-default-sink 2>/dev/null)
[ -z "$SINK" ] && echo '{"text":"—","tooltip":"No audio device","class":"none"}' && exit 0

# Get full sink info block
INFO=$(pactl list sinks 2>/dev/null)

# Parse from the correct sink block
SPEC=$(echo "$INFO" | grep -A5 "Name: $SINK" | grep "Sample Specification:" | sed 's/.*: //')

# Extract: "s32le 8ch 48000Hz"
BITS=$(echo "$SPEC" | grep -oP 's\K\d+')
CHANNELS=$(echo "$SPEC" | grep -oP '\d+(?=ch)')
RATE=$(echo "$SPEC" | grep -oP '\d+(?=Hz)')

# Human-readable rate
if [ -n "$RATE" ]; then
    if [ "$RATE" -ge 1000 ]; then
        RATE_H="$(awk "BEGIN{printf \"%.1f\", $RATE/1000}")kHz"
    else
        RATE_H="${RATE}Hz"
    fi
else
    RATE_H="?"
fi

TEXT="${RATE_H}/${BITS:-?}b"

# Device info for tooltip
CARD=$(echo "$INFO" | grep -A60 "Name: $SINK" | grep "alsa.card_name" | head -1 | sed 's/.*= "//;s/"//')
DESC=$(echo "$INFO" | grep -A2 "Name: $SINK" | grep "Description:" | sed 's/.*: //')

TOOLTIP="${CARD:-$DESC}\n${BITS:-?}bit / ${CHANNELS:-?}ch / ${RATE:-?}Hz\nPipeWire $(pipewire --version 2>/dev/null | tail -1 | awk '{print $NF}')"

# Class for color coding
CLASS="normal"
[ "${RATE:-0}" -ge 96000 ] && CLASS="hires"
[ "${RATE:-0}" -ge 192000 ] && CLASS="ultra"

echo "{\"text\":\"${TEXT}\",\"tooltip\":\"${TOOLTIP}\",\"class\":\"${CLASS}\"}"
