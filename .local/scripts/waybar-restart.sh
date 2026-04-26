#!/usr/bin/env bash
killall waybar 2>/dev/null
for i in $(seq 1 10); do
    pgrep -x waybar > /dev/null || break
    sleep 0.1
done
waybar &
waybar -c ~/.config/waybar/config_dp2 &>/dev/null &
