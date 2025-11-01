#!/bin/bash

# 状态文件
STATE_FILE="/tmp/round_info_index_$WAYBAR_OUTPUT_NAME"

# 所有要轮播的脚本（按顺序写）
SCRIPTS=(
    "$HOME/scripts/get_brightness.sh"
    "$HOME/scripts/get_temperature.sh"
    "$HOME/scripts/get_cpu_usage.sh"
    "$HOME/scripts/get_mem_usage.sh"
    # "$HOME/scripts/get_gpu_usage_amd.sh"
    # "$HOME/scripts/get_gpu_mem_usage_amd.sh"
    # "$HOME/scripts/get_gpu_temperature_amd.sh"
)

# 如果状态文件不存在，初始化为 0
if [ ! -f "$STATE_FILE" ]; then
    echo 0 > "$STATE_FILE"
fi

# 当前索引
INDEX=$(cat "$STATE_FILE")

# 取模，防止数组越界
INDEX=$((INDEX % ${#SCRIPTS[@]}))

# 执行对应脚本
bash "${SCRIPTS[$INDEX]}"

# 更新索引（循环）
NEXT=$(( (INDEX + 1) % ${#SCRIPTS[@]} ))
echo "$NEXT" > "$STATE_FILE"
