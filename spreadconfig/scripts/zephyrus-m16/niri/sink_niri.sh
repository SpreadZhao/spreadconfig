#!/usr/bin/env bash

# Check if the sink is muted, returns 0 (true) if muted, 1 (false) otherwise
is_sink_muted() {
    local output="$1"
    echo "$output" | grep -qiE "muted|\(muted\)"
}

# Return an icon based on the sink device type and mute status
get_sink_icon() {
    local output="$1"
    # Get sink info, convert to lowercase for case-insensitive matching
    local default_sink_info
    default_sink_info=$(wpctl inspect @DEFAULT_SINK@ | tr '[:upper:]' '[:lower:]')

    # Determine device type priority: bluetooth > headphones > speakers > default
    local device_type="default"

    if echo "$default_sink_info" | grep -q "blue"; then
        device_type="bluetooth"
    elif echo "$default_sink_info" | grep -qE "headphone|headset"; then
        device_type="headphones"
    elif echo "$default_sink_info" | grep -qE "speaker|analog"; then
        device_type="speakers"
    fi

    # Use case to select icon based on device type and mute status
    case "$device_type" in
    bluetooth)
        if is_sink_muted "$output"; then
            echo "󰂲"
        else
            echo "󰂯" # Bluetooth icon
        fi
        ;;
    headphones)
        if is_sink_muted "$output"; then
            echo "󰟎"
        else
            echo "" # Headphones icon
        fi
        ;;
    *)
        if is_sink_muted "$output"; then
            echo "󰖁"
        else
            echo "󰕾" # Default/unknown device icon
        fi
        ;;
    esac
}

volume_output=$(wpctl get-volume @DEFAULT_SINK@)
volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')

if [[ -z "$volume_raw" ]]; then
    echo "-"
    return 1 # Return non-zero on error
fi

volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

echo "${volume_percent}$(get_sink_icon "$volume_output")"
