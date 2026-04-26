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

wal -i "$1" -n --cols16 darken --backend wal $WAL_FLAGS
# swww img "$1" -o DP-2 --resize crop
~/.local/scripts/wal-reload.sh
