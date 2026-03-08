#!/bin/bash
WALLPAPER_DIR="$HOME/wallpapers"
ROFI_THEME="$HOME/.config/rofi/launchers/type-4/style-9.rasi"

folder=$(ls -d "$WALLPAPER_DIR"/*/  | xargs -I{} basename {} | rofi -dmenu -p "Category" -theme "$ROFI_THEME")
[ -z "$folder" ] && exit 0

waypaper --folder "$WALLPAPER_DIR/$folder"
