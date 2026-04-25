#!/usr/bin/env bash

if pgrep -x openvpn > /dev/null; then
    echo "󰖂 VPN connected"
fi
