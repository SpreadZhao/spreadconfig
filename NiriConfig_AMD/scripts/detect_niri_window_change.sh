#!/usr/bin/bash

niri msg event-stream | while read -r line; do
    pkill -RTMIN+8 waybar
done
