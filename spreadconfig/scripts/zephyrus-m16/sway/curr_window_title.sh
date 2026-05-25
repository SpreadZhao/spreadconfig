#!/bin/bash

OUTPUT_FILE="/tmp/current_window_title"

stdbuf -oL swaymsg -t subscribe -m '["window"]' | stdbuf -oL jq -r 'select(.change=="focus") | .container.name' | while read -r title; do
    if [ -n "$title" ]; then
        echo "$title" > "$OUTPUT_FILE"
        pkill -SIGRTMIN +10 i3blocks &
    fi
done
