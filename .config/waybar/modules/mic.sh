#!/bin/bash
volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
if echo "$volume" | grep -q "MUTED"; then
    echo '{"text": "󰍭", "class": "muted"}'
else
    echo '{"text": "", "class": "active"}'
fi
