#!/bin/bash
echo "$(date) args: $@" >> /tmp/wal-theme.log
echo "$(date) wal path: $(which wal)" >> /tmp/wal-theme.log
wal -i "$1" -n --cols16 darken --backend colorz
themecord -p
pkill -SIGUSR2 waybar 2>/dev/null
pkill -SIGUSR1 nvim 2>/dev/null
pkill -HUP qutebrowser 2>/dev/null
bash ~/.local/share/pywal16-libadwaita/scripts/apply-theme.sh
gradience-cli apply -p ~/.var/app/com.github.GradienceTeam.Gradience/config/presets/user/pywal.json --gtk both
bash ~/.local/share/pywal16-libadwaita/scripts/wal-papirus.sh
