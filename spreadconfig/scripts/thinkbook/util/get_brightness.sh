#!/usr/bin/env bash

percent=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')
if [[ "$percent" =~ ^[0-9]+$ ]]; then
    echo "${percent}󱩎"
fi
