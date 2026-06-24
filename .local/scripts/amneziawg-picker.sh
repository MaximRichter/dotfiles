#!/usr/bin/env bash

config_dir="${AMNEZIAWG_CONFIG_DIR:-$HOME/amnezia}"
theme="$HOME/.config/rofi/vpn-picker.rasi"
log="/tmp/amneziawg-rofi.log"
disconnect=" Disconnect"
awg_quick="$(command -v awg-quick || true)"

notify() {
    notify-send "VPN" "$1" "${@:2}" 2>/dev/null || true
}

refresh_waybar() {
    pkill -RTMIN+10 waybar 2>/dev/null || true
}

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
        return
    fi

    if sudo -n true 2>/dev/null; then
        sudo "$@"
        return
    fi

    if command -v pkexec >/dev/null 2>&1; then
        pkexec "$@"
        return
    fi

    sudo "$@"
}

run_awg_quick() {
    printf "\n[%s] awg-quick %s\n" "$(date '+%F %T')" "$*" >>"$log"
    run_as_root "$awg_quick" "$@"
}

active_interfaces() {
    find "$config_dir" -maxdepth 1 -type f -name "*.conf" -printf "%f\n" 2>/dev/null |
        sed 's|\.conf$||' |
        while IFS= read -r interface; do
            if [ -e "/sys/class/net/$interface" ]; then
                printf "%s\n" "$interface"
            fi
        done
}

down_active() {
    local failed=0

    while IFS= read -r interface; do
        if ! run_awg_quick down "$config_dir/$interface.conf" >>"$log" 2>&1 &&
            ! run_awg_quick down "$interface" >>"$log" 2>&1; then
            failed=1
        fi
    done < <(active_interfaces)

    return "$failed"
}

configs=$(find "$config_dir" -maxdepth 1 -type f -name "*.conf" -printf "%f\n" 2>/dev/null |
    sort |
    sed 's|\.conf$||')

if [ -z "$awg_quick" ]; then
    notify "awg-quick not found" --urgency=critical -i network-offline
    exit 1
fi

active=$(active_interfaces | paste -sd, - | sed 's/,/, /g')
if [ -n "$active" ]; then
    mesg="Active: $active"
else
    mesg="No active connection"
fi

chosen=$(printf "%s\n%s" "$disconnect" "$configs" | rofi -dmenu -i \
    -p "VPN" \
    -mesg "$mesg" \
    -theme "$theme")

[ -z "$chosen" ] && exit 0

: >"$log"

if [[ "$chosen" == "$disconnect" ]]; then
    if down_active; then
        refresh_waybar
        notify "Disconnected" -i network-vpn
    else
        refresh_waybar
        notify "Disconnect failed" --urgency=critical -i network-offline
        exit 1
    fi
    exit 0
fi

config="$config_dir/$chosen.conf"
if [ ! -f "$config" ]; then
    notify "Config not found: $chosen" --urgency=critical -i network-offline
    exit 1
fi

if ! down_active; then
    refresh_waybar
    notify "Disconnect failed" --urgency=critical -i network-offline
    exit 1
fi
sleep 0.3

notify "Connecting: $chosen..." -i network-vpn

if run_awg_quick up "$config" >>"$log" 2>&1; then
    for _ in $(seq 1 8); do
        if [ -e "/sys/class/net/$chosen" ]; then
            refresh_waybar
            notify "Connected: $chosen" -i network-vpn
            exit 0
        fi
        sleep 1
    done
fi

run_awg_quick down "$config" >>"$log" 2>&1 || true
refresh_waybar
notify "Failed: $chosen" --urgency=critical -i network-offline
exit 1
