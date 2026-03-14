#!/bin/bash

STATE_FILE="$HOME/.cache/wal/mode"
WALLPAPER=$(cat ~/.cache/wal/wal)

# Read current mode, default to dark
if [ -f "$STATE_FILE" ]; then
    MODE=$(cat "$STATE_FILE")
else
    MODE="dark"
fi

# Toggle
if [ "$MODE" = "dark" ]; then
    NEW_MODE="light"
    WAL_FLAGS="-l"
else
    NEW_MODE="dark"
    WAL_FLAGS=""
fi

# Apply
echo "$NEW_MODE" > "$STATE_FILE"

if [ "$NEW_MODE" = "light" ]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

wal --cols16 darken --backend colorz -i "$WALLPAPER" -n $WAL_FLAGS

# Reload everything
themecord -p
pkill -SIGUSR2 waybar 2>/dev/null
pkill -SIGUSR1 nvim 2>/dev/null
pkill -HUP qutebrowser 2>/dev/null
bash ~/.local/share/pywal16-libadwaita/scripts/apply-theme.sh
gradience-cli apply -p ~/.var/app/com.github.GradienceTeam.Gradience/config/presets/user/pywal.json --gtk both
bash ~/.local/share/pywal16-libadwaita/scripts/wal-papirus.sh

notify-send "Theme" "Switched to $NEW_MODE mode" -t 2000
