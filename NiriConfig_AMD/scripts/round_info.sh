#!/bin/bash

# 状态文件
STATE_FILE="/tmp/i3blocks_info_index"

# 所有要轮播的脚本（按顺序写）
SCRIPTS=(
    "$HOME/scripts/get_brightness.sh"
    "$HOME/scripts/get_temperature.sh"
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
