#!/bin/bash
# obs-status.sh — OBS streaming/recording indicator for waybar
# Detects OBS process and checks if streaming/recording via obs-cli or process

# Check if OBS is running
if ! pgrep -x "obs" &>/dev/null; then
    echo '{"text":"","tooltip":"","class":"inactive"}'
    exit 0
fi

# Check recording/streaming status via log or socket
# Method: parse OBS status via obs-cli if available, else check file locks
STREAMING=false
RECORDING=false

# Check if obs-websocket is available (obs-cli)
if command -v obs-cli &>/dev/null; then
    STATUS=$(obs-cli streaming status 2>/dev/null)
    [[ "$STATUS" == *"true"* ]] && STREAMING=true
    REC_STATUS=$(obs-cli recording status 2>/dev/null)
    [[ "$REC_STATUS" == *"true"* ]] && RECORDING=true
else
    # Fallback: check OBS log for active output
    LOG_DIR="$HOME/.config/obs-studio/logs"
    if [ -d "$LOG_DIR" ]; then
        LATEST_LOG=$(ls -t "$LOG_DIR"/*.txt 2>/dev/null | head -1)
        if [ -n "$LATEST_LOG" ]; then
            # Check last 50 lines for streaming/recording start without stop
            tail -50 "$LATEST_LOG" 2>/dev/null | grep -q "\\[stream\\].*started" && STREAMING=true
            tail -50 "$LATEST_LOG" 2>/dev/null | grep -q "\\[recording\\].*started" && RECORDING=true
            tail -50 "$LATEST_LOG" 2>/dev/null | grep -q "\\[stream\\].*stopped" && STREAMING=false
            tail -50 "$LATEST_LOG" 2>/dev/null | grep -q "\\[recording\\].*stopped" && RECORDING=false
        fi
    fi

    # Also check for active file locks in recordings dir
    VIDEOS_DIR="$HOME/Videos"
    if ls "$VIDEOS_DIR"/*.mkv.lock 2>/dev/null | grep -q . || \
       lsof +D "$VIDEOS_DIR" 2>/dev/null | grep -q obs; then
        RECORDING=true
    fi
fi

if $STREAMING && $RECORDING; then
    TEXT="󰑋 LIVE+REC"
    CLASS="live-rec"
    TT="<span color='#f38ba8' size='large'><b>󰑋 OBS — LIVE + Recording</b></span>"
elif $STREAMING; then
    TEXT="󰑋 LIVE"
    CLASS="live"
    TT="<span color='#f38ba8' size='large'><b>󰑋 OBS — En direct</b></span>"
elif $RECORDING; then
    TEXT="󰻃 REC"
    CLASS="recording"
    TT="<span color='#fab387' size='large'><b>󰻃 OBS — Enregistrement</b></span>"
else
    TEXT="󰐌"
    CLASS="standby"
    TT="<span color='#a6adc8'>󰐌 OBS ouvert (en veille)</span>"
fi

TT_ESC=$(echo -e "$TT" | sed 's/"/\\"/g')
echo "{\"text\":\"${TEXT}\",\"tooltip\":\"${TT_ESC}\",\"class\":\"${CLASS}\"}"
