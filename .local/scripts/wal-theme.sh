#!/bin/bash
echo "$(date) args: $@" >> /tmp/wal-theme.log
echo "$(date) wal path: $(which wal)" >> /tmp/wal-theme.log

MODE=$(cat ~/.cache/wal/mode 2>/dev/null || echo "dark")
if [ "$MODE" = "light" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

[ "$MODE" = "light" ] && WAL_FLAGS="-l" || WAL_FLAGS=""

wal -i "$1" -n --cols16 darken --backend colorz $WAL_FLAGS
themecord -p
pkill -SIGUSR2 waybar 2>/dev/null
pkill -SIGUSR1 nvim 2>/dev/null
pkill -HUP qutebrowser 2>/dev/null
bash ~/.local/share/pywal16-libadwaita/scripts/apply-theme.sh
gradience-cli apply -p ~/.var/app/com.github.GradienceTeam.Gradience/config/presets/user/pywal.json --gtk both
bash ~/.local/share/pywal16-libadwaita/scripts/wal-papirus.sh
