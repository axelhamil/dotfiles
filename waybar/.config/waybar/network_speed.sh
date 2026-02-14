#!/bin/bash

IFACE="eth0"  # ou eth0, ou ton interface: check avec `ip a`

RX_PREV=0
TX_PREV=0

while true; do
    RX_NOW=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    TX_NOW=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

    RX_RATE=$((RX_NOW - RX_PREV))
    TX_RATE=$((TX_NOW - TX_PREV))

    RX_PREV=$RX_NOW
    TX_PREV=$TX_NOW

    RX_KB=$((RX_RATE / 1024))
    TX_KB=$((TX_RATE / 1024))

    echo "{\"text\":\"⬇ ${RX_KB} KB/s ⬆ ${TX_KB} KB/s\"}"

    sleep 1
done
