#!/bin/bash

ROFI_THEME="$HOME/.config/rofi/launchers/type-4/style-9.rasi"
FG=$(grep "^foreground=" ~/.cache/wal/colors.sh 2>/dev/null | cut -d"'" -f2)
DIM=$(grep "^color7=" ~/.cache/wal/colors.sh 2>/dev/null | cut -d"'" -f2)
[ -z "$FG" ]  && FG="#ffffff"
[ -z "$DIM" ] && DIM="#666666"

grep "^bindd" ~/.config/hypr/config/keybinds.conf | \
    awk -F', ' -v fg="$FG" -v dim="$DIM" '{
        mods=$1; key=$2; desc=$3
        sub(/^bindd = /, "", mods)
        gsub(/\$mainMod/, "Super", mods)
        hotkey = mods " + " key
        printf "<span foreground=\"%s\" weight=\"bold\">%-33s</span>  <span foreground=\"%s\">%s</span>\n", fg, hotkey, dim, desc
    }' | \
    rofi -dmenu -p " Keybinds" -theme "$ROFI_THEME" -no-custom -i -markup-rows \
         -theme-str 'window {width: 85%; height: 75%;} listview {columns: 3; lines: 20;}'
