#!/usr/bin/env bash

config_dir="${AMNEZIAWG_CONFIG_DIR:-$HOME/amnezia}"

active=$(
    find "$config_dir" -maxdepth 1 -type f -name "*.conf" -printf "%f\n" 2>/dev/null |
        sed 's|\.conf$||' |
        while IFS= read -r interface; do
            if ip link show "$interface" &>/dev/null; then
                printf "%s\n" "$interface"
            fi
        done |
        paste -sd, - |
        sed 's/,/, /g'
)

if [ -n "$active" ]; then
    printf '{"text":"VPN","tooltip":"%s"}\n' "$active"
else
    echo '{"text": ""}'
fi
