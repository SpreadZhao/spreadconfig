#!/bin/bash

# Get microphone volume and mute status, return volume% + icon
get_mic_volume() {
    local volume_output
    volume_output=$(wpctl get-volume @DEFAULT_SOURCE@)
    local volume_raw
    volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')
    local volume_percent

    if [[ -z "$volume_raw" ]]; then
        echo "Error: Could not extract mic volume."
        return 1  # Return non-zero on error
    fi

    volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

    if echo "$volume_output" | grep -qiE "muted|\(muted\)"; then
        echo "${volume_percent}󰍭"  # Volume percent + muted mic icon
    else
        echo "${volume_percent}󰍬"  # Volume percent + unmuted mic icon
    fi
}

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
            echo "󰂯"  # Bluetooth icon
        fi
        ;;
    headphones)
        if is_sink_muted "$output"; then
            echo "󰟎"
        else
            echo ""  # Headphones icon
        fi
        ;;
    *)
        if is_sink_muted "$output"; then
            echo "󰖁"
        else
            echo "󰕾"  # Default/unknown device icon
        fi
        ;;
    esac
}

# Get sink volume percentage and icon, return combined string
get_sink_volume() {
    local volume_output
    volume_output=$(wpctl get-volume @DEFAULT_SINK@)
    local volume_raw
    volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')
    local volume_percent

    if [[ -z "$volume_raw" ]]; then
        echo "Error: Could not extract sink volume."
        return 1  # Return non-zero on error
    fi

    volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

    echo "${volume_percent}$(get_sink_icon "$volume_output")"
}

# Print sink volume + icon and mic volume + icon, separated by space
echo "$(get_sink_volume)$(get_mic_volume)"
