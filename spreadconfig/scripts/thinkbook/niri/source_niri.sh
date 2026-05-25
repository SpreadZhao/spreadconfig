#!/usr/bin/env bash

volume_output=$(wpctl get-volume @DEFAULT_SOURCE@)
volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')

if [[ -z "$volume_raw" ]]; then
    echo "-"
    return 1 # Return non-zero on error
fi

volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

if echo "$volume_output" | grep -qiE "muted|\(muted\)"; then
    echo "${volume_percent}󰍭" # Volume percent + muted mic icon
else
    echo "${volume_percent}󰍬" # Volume percent + unmuted mic icon
fi
