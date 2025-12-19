#!/usr/bin/bash
pactl subscribe | while read -r event; do
    if echo "$event" | grep -q "Event 'change' on server"; then
        pkill -RTMIN+7 waybar
    fi
done
