#!/usr/bin/env bash

LOG_FILE="$HOME/.local/share/niri-restart.log"

while true; do
    {
        date '+[%F %T] Starting event-stream...'
        niri msg event-stream | while read -r line; do
            pkill -RTMIN+8 waybar
        done
        date '+[%F %T] event-stream exited, restarting in 1s...'
    } >>"$LOG_FILE" 2>&1

    sleep 1
done
