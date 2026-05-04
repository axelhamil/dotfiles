#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
sudo install -m 755 "$DIR/bin/obsbot-tune.sh" /usr/local/bin/obsbot-tune.sh
sudo install -m 644 "$DIR/udev/99-obsbot.rules" /etc/udev/rules.d/99-obsbot.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
echo "OK — obsbot tune installé. Replug la cam ou attends le prochain reboot."
