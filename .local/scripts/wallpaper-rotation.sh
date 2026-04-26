#!/bin/bash

INTERVAL_FILE="$HOME/.cache/wallpaper-rotation-interval"
INTERVAL=$(cat "$INTERVAL_FILE" 2>/dev/null || echo 3600)

while true; do
    sleep "$INTERVAL"
    waypaper --random
done
