#!/bin/bash
DEV=$(v4l2-ctl --list-devices 2>/dev/null | awk '/OBSBOT/{getline; print $1; exit}')
[ -z "$DEV" ] && exit 0
sleep 1
v4l2-ctl -d "$DEV" \
  --set-ctrl=backlight_compensation=18 \
  --set-ctrl=white_balance_automatic=0 \
  --set-ctrl=white_balance_temperature=4600 \
  --set-ctrl=power_line_frequency=1
