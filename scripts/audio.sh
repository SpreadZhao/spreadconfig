#!/bin/bash

change_audio_sink() {
    /usr/bin/python ~/scripts/change_audio_sink.py
}

change_audio_source() {
    /usr/bin/python ~/scripts/change_audio_source.py
}

case "$BLOCK_BUTTON" in
    1)
        change_audio_sink
        ;;
    3)
        change_audio_source
        ;;
esac

# 获取麦克风音量
get_mic_volume() {
    local volume_output=$(wpctl get-volume @DEFAULT_SOURCE@)
    local volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')
    local volume_percent

    if [[ -z "$volume_raw" ]]; then
        echo "Error: Could not extract mic volume."
        return 1 # 返回非零值表示错误
    fi

    volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

    if echo "$volume_output" | grep -qiE "MUTED|\(muted\)"; then
        echo "${volume_percent}󰍭" # 百分比 + 静音图标
    else
        echo "${volume_percent}󰍬" # 百分比 + 非静音图标
    fi
}

# 获取音频输出 (Sink) 音量
get_sink_volume() {
    local volume_output=$(wpctl get-volume @DEFAULT_SINK@)
    local volume_raw=$(echo "$volume_output" | grep -oP '\d+\.?\d*')
    local volume_percent

    if [[ -z "$volume_raw" ]]; then
        echo "Error: Could not extract sink volume."
        return 1 # 返回非零值表示错误
    fi

    volume_percent=$(awk -v vol="$volume_raw" 'BEGIN { printf "%.0f", vol * 100 }')

    if echo "$volume_output" | grep -qiE "MUTED|\(muted\)"; then
        echo "${volume_percent}󰖁" # 百分比 + 静音图标 (通常用于扬声器)
    else
        echo "${volume_percent}󰕾" # 百分比 + 非静音图标 (通常用于扬声器)
    fi
}

echo "$(get_sink_volume) $(get_mic_volume)"
