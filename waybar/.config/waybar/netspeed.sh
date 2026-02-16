#!/bin/bash
# netspeed.sh — Live network speed for waybar (jq)

IFACE=$(ip route | awk '/default/{print $5; exit}')
[ -z "$IFACE" ] && jq -cn '{text: "--", tooltip: "Pas de connexion", class: "disconnected"}' && exit 0

# Read current bytes
RX1=$(< /sys/class/net/${IFACE}/statistics/rx_bytes)
TX1=$(< /sys/class/net/${IFACE}/statistics/tx_bytes)
sleep 1
RX2=$(< /sys/class/net/${IFACE}/statistics/rx_bytes)
TX2=$(< /sys/class/net/${IFACE}/statistics/tx_bytes)

# Calculate speed
RX_SPEED=$((RX2 - RX1))
TX_SPEED=$((TX2 - TX1))

# Human readable
format_speed() {
    local bytes=$1
    if [ "$bytes" -ge 1048576 ]; then
        awk "BEGIN{printf \"%.1fM\", $bytes/1048576}"
    elif [ "$bytes" -ge 1024 ]; then
        awk "BEGIN{printf \"%.0fK\", $bytes/1024}"
    else
        echo "0K"
    fi
}

DL=$(format_speed $RX_SPEED)
UL=$(format_speed $TX_SPEED)

# Total since boot
RX_TOT=$(awk "BEGIN{printf \"%.1f\", $RX2/1073741824}")
TX_TOT=$(awk "BEGIN{printf \"%.1f\", $TX2/1073741824}")

# Class
CLASS="idle"
[ "$RX_SPEED" -ge 102400 ] && CLASS="active"
[ "$RX_SPEED" -ge 1048576 ] && CLASS="fast"
[ "$RX_SPEED" -ge 10485760 ] && CLASS="blazing"

TEXT="${DL} ${UL}"

TT="${IFACE}"$'\n'
TT+="---"$'\n'
TT+="Download: ${DL}/s"$'\n'
TT+="Upload: ${UL}/s"$'\n'
TT+="---"$'\n'
TT+="Total depuis boot:"$'\n'
TT+="  DL: ${RX_TOT} Go | UL: ${TX_TOT} Go"

jq -cn --arg text "$TEXT" --arg tooltip "$TT" --arg class "$CLASS" \
    '{text: $text, tooltip: $tooltip, class: $class}'
