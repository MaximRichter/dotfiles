#!/bin/bash
IFACE="enp14s0"
STATE="/tmp/network-waybar.state"

curr_rx=$(awk -v i="$IFACE:" '$1==i {print $2}' /proc/net/dev)
curr_tx=$(awk -v i="$IFACE:" '$1==i {print $10}' /proc/net/dev)
curr_time=$(date +%s)

monthly=$(vnstat -i "$IFACE" --oneline 2>/dev/null | cut -d';' -f11)
[ -z "$monthly" ] && monthly="N/A"

if [ -f "$STATE" ]; then
    read prev_rx prev_tx prev_time < "$STATE"
    elapsed=$(( curr_time - prev_time ))
    if [ "$elapsed" -gt 0 ]; then
        down=$(( (curr_rx - prev_rx) / elapsed ))
        up=$(( (curr_tx - prev_tx) / elapsed ))
        down_fmt=$(numfmt --to=iec-i --suffix=B/s "$down" 2>/dev/null || echo "${down}B/s")
        up_fmt=$(numfmt --to=iec-i --suffix=B/s "$up" 2>/dev/null || echo "${up}B/s")
        tooltip="↓ ${down_fmt}   ↑ ${up_fmt}"
    else
        tooltip="Calculating..."
    fi
else
    tooltip="Calculating..."
fi

echo "$curr_rx $curr_tx $curr_time" > "$STATE"

echo "{\"text\": \"${monthly}\", \"tooltip\": \"${tooltip}\"}"
