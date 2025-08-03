#!/bin/bash

# i3blocks script for time toggle

# 临时状态文件
STATE_FILE="/tmp/i3blocks_time_format"

# 默认格式
DEFAULT_FORMAT="+%H:%M"
FULL_FORMAT="+%Y-%m-%d %H:%M:%S %a"

# 切换状态（点击触发）
if [ "$BLOCK_BUTTON" == "1" ]; then
    if [ -f "$STATE_FILE" ]; then
        rm "$STATE_FILE"
    else
        touch "$STATE_FILE"
    fi
fi

# 根据状态决定显示格式
if [ -f "$STATE_FILE" ]; then
    date "$FULL_FORMAT"
else
    date "$DEFAULT_FORMAT"
fi
