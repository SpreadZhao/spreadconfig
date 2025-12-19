#!/bin/bash

# 获取笔记本电池电量
get_battery_status() {
    local battery_path="/sys/class/power_supply/BAT0" # 默认为BAT0，如果你的系统是BAT1或其他，请修改
    local capacity_file="$battery_path/capacity"
    local status_file="$battery_path/status"

    # 检查电池路径是否存在
    if [[ ! -d "$battery_path" ]]; then
        # 尝试查找其他电池设备，例如 BAT1
        battery_path=$(find /sys/class/power_supply/ -maxdepth 1 -type d -name "BAT*" | head -n 1)
        capacity_file="$battery_path/capacity"
        status_file="$battery_path/status"
        if [[ ! -d "$battery_path" ]]; then
            echo "Error: Could not find battery device (e.g., BAT0 or BAT1)."
            return 1
        fi
    fi

    # 读取电量百分比
    local battery_percent=$(cat "$capacity_file" 2>/dev/null)
    if [[ -z "$battery_percent" ]]; then
        echo "Error: Could not read battery capacity from $capacity_file."
        return 1
    fi

    # 读取电池状态 (Charging, Discharging, Full, Unknown)
    local battery_status=$(cat "$status_file" 2>/dev/null)
    if [[ -z "$battery_status" ]]; then
        echo "Error: Could not read battery status from $status_file."
        return 1
    fi

    # 根据状态选择图标
    local icon=""
    case "$battery_status" in
        "Charging")
            icon="󰂄" # 充电图标
            ;;
        "Discharging")
            # 根据电量显示不同图标，可以进一步细化
            if (( battery_percent <= 20 )); then
                icon="󰁺" # 低电量图标
            elif (( battery_percent <= 50 )); then
                icon="󰁽" # 中等电量图标
            else
                icon="󰁹" # 正常电量图标
            fi
            ;;
        "Full")
            icon="󰁹" # 满电图标
            ;;
        "Not charging")
            icon="󰚥"
            ;;
        *)
            icon="󰁶" # 未知状态图标
            ;;
    esac

    echo "${battery_percent}${icon}" # 百分比 + 图标
}


# --- 示例用法 ---
echo $(get_battery_status)

# 结合之前的音量函数，形成一个更完整的系统状态脚本
# get_mic_volume() { ... }
# get_sink_volume() { ... }

# echo "麦克风音量: $(get_mic_volume)"
# echo "音频输出音量: $(get_sink_volume)"
