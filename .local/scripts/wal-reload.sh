#!/bin/bash

themecord -p

ACCENT=$(python3 -c "
import re, colorsys
try:
    txt = open('$HOME/.cache/wal/colors.sh').read()
    colors = dict(re.findall(r\"^(color\d+)='(#[0-9a-fA-F]{6})'\", txt, re.M))
    best, best_score = '#ffffff', -1
    for i in range(1, 15):
        h = colors.get(f'color{i}', '').lstrip('#')
        if len(h) != 6: continue
        r, g, b = (int(h[j:j+2], 16)/255 for j in (0, 2, 4))
        _, s, v = colorsys.rgb_to_hsv(r, g, b)
        if s * v > best_score:
            best_score = s * v
            best = colors[f'color{i}']
    print(best)
except: print('#ffffff')
" 2>/dev/null)
if [ -n "$ACCENT" ]; then
    sed -i "s|foreground='#[0-9a-fA-F]\{6\}'|foreground='$ACCENT'|g" \
        ~/.config/waybar/config ~/.config/waybar/config_dp2 2>/dev/null
fi

~/.local/scripts/waybar-restart.sh
pkill -SIGUSR1 nvim 2>/dev/null
pkill -HUP qutebrowser 2>/dev/null
bash ~/.local/share/pywal16-libadwaita/scripts/apply-theme.sh
gradience-cli apply -p ~/.var/app/com.github.GradienceTeam.Gradience/config/presets/user/pywal.json --gtk both
bash ~/.local/share/pywal16-libadwaita/scripts/wal-papirus.sh
