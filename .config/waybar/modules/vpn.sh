#!/usr/bin/env bash

if pgrep -x openvpn > /dev/null; then
    config=$(ps -p "$(pgrep -x openvpn | head -1)" -o args= 2>/dev/null \
        | sed 's/.*--config //' | sed 's|.*/||; s|\.ovpn$||')
    echo "{\"text\": \"VPN\", \"tooltip\": \"${config:-unknown}\"}"
else
    echo '{"text": ""}'
fi
