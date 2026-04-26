#!/bin/bash

PID_FILE="$HOME/.cache/wallpaper-rotation.pid"
INTERVAL_FILE="$HOME/.cache/wallpaper-rotation-interval"
ROFI_THEME="$HOME/.config/rofi/launchers/type-4/style-9.rasi"

# Check if already running
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    kill "$(cat "$PID_FILE")"
    rm -f "$PID_FILE"
    notify-send "Wallpaper" "Auto-rotation disabled" -t 2000
    exit 0
fi

# Ask for interval
chosen=$(printf "30 минут\n1 час\n2 часа\n4 часа\n8 часов" | \
    rofi -dmenu -p "Интервал ротации" -theme "$ROFI_THEME")

[ -z "$chosen" ] && exit 0

case "$chosen" in
    "30 минут") seconds=1800 ;;
    "1 час")    seconds=3600 ;;
    "2 часа")   seconds=7200 ;;
    "4 часа")   seconds=14400 ;;
    "8 часов")  seconds=28800 ;;
esac

echo "$seconds" > "$INTERVAL_FILE"

~/.local/scripts/wallpaper-rotation.sh &
echo $! > "$PID_FILE"

notify-send "Wallpaper" "Auto-rotation: $chosen" -t 2000
