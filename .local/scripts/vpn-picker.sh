#!/usr/bin/env bash

dir="/etc/openvpn/other os"
theme="$HOME/.config/rofi/vpn-picker.rasi"

disconnect=" Disconnect"

if pgrep -x openvpn > /dev/null; then
    active=$(ps -p "$(pgrep -x openvpn | head -1)" -o args= 2>/dev/null \
        | sed 's/.*--config //' | sed 's|.*/||; s|\.ovpn$||')
    mesg="Active: ${active:-unknown}"
else
    mesg="No active connection"
fi

configs=$(find "$dir" -name "*.ovpn" | sort | sed 's|.*/||; s|\.ovpn$||')

chosen=$(printf "%s\n%s" "$disconnect" "$configs" | rofi -dmenu -i \
    -p "VPN" \
    -mesg "$mesg" \
    -theme "$theme")

[ -z "$chosen" ] && exit 0

if [[ "$chosen" == "$disconnect" ]]; then
    sudo pkill -x openvpn
    notify-send "VPN" "Disconnected" -i network-vpn
    pkill -RTMIN+10 waybar
else
    sudo pkill -x openvpn 2>/dev/null
    sleep 0.5
    sudo openvpn --config "$dir/$chosen.ovpn" &>/tmp/openvpn-rofi.log &
    notify-send "VPN" "Connecting: $chosen..." -i network-vpn
    (
        # Wait for tun interface
        tun_up=false
        for i in $(seq 1 8); do
            sleep 1
            if ip link show tun0 &>/dev/null; then
                tun_up=true
                break
            fi
        done

        if ! $tun_up; then
            sudo pkill -x openvpn 2>/dev/null
            notify-send "VPN" "Failed: $chosen" --urgency=critical -i network-offline
            exit 1
        fi

        # tun0 is up — verify actual traffic with ping
        if ping -c 3 -W 3 8.8.8.8 &>/dev/null; then
            notify-send "VPN" "Connected: $chosen" -i network-vpn
            pkill -RTMIN+10 waybar
        else
            sudo pkill -x openvpn 2>/dev/null
            pkill -RTMIN+10 waybar
            notify-send "VPN" "No traffic through VPN: $chosen" --urgency=critical -i network-offline
        fi
    ) &
fi
