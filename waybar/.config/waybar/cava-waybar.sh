#!/bin/bash
# cava-waybar.sh — Pipe cava output as unicode bars for waybar
# Requires: cava

# Cava config for waybar (raw output mode)
CAVA_CFG=$(mktemp)
cat > "$CAVA_CFG" <<'EOF'
[general]
bars = 12
framerate = 30
autosens = 1
overshoot = 20

[input]
method = pipewire
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7

[smoothing]
noise_reduction = 77
EOF

# Cleanup on exit
trap "rm -f '$CAVA_CFG'" EXIT

# Run cava and convert numbers to unicode bars
cava -p "$CAVA_CFG" 2>/dev/null | while IFS=';' read -r -a values; do
    BAR=""
    for val in "${values[@]}"; do
        case ${val:-0} in
            0) BAR+="▁" ;;
            1) BAR+="▂" ;;
            2) BAR+="▃" ;;
            3) BAR+="▄" ;;
            4) BAR+="▅" ;;
            5) BAR+="▆" ;;
            6) BAR+="▇" ;;
            7) BAR+="█" ;;
            *) BAR+="▁" ;;
        esac
    done
    echo "$BAR"
done
