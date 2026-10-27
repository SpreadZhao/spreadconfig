#!/usr/bin/env bash

is_sink_muted() {
    local output="$1"
    echo "$output" | grep -qiE "muted|\(muted\)"
}

get_sink_icon() {
    local output="$1"
    local default_sink_info
    default_sink_info=$(wpctl inspect @DEFAULT_SINK@ | tr '[:upper:]' '[:lower:]')

    local device_type="default"

    if echo "$default_sink_info" | grep -q "blue"; then
        device_type="bluetooth"
    elif echo "$default_sink_info" | grep -qE "headphone|headset"; then
        device_type="headphones"
    elif echo "$default_sink_info" | grep -qE "speaker|analog"; then
        device_type="speakers"
    fi

    case "$device_type" in
    bluetooth)
        if is_sink_muted "$output"; then
            echo "󰂲"
        else
            echo "󰂯"
        fi
        ;;
    headphones)
        if is_sink_muted "$output"; then
            echo "󰟎"
        else
            echo ""
        fi
        ;;
    *)
        if is_sink_muted "$output"; then
            echo "󰖁"
        else
            echo "󰕾"
        fi
        ;;
    esac
}

volume_output=$(wpctl get-volume @DEFAULT_SINK@)
volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')

if [[ -z "$volume_raw" ]]; then
    echo "-"
    exit 1
fi

volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

echo "${volume_percent}$(get_sink_icon "$volume_output")"
