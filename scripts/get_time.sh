#!/bin/bash

STATE_FILE="/tmp/toggle_time_format"

DEFAULT_FORMAT="+%H:%M"
FULL_FORMAT="+%Y-%m-%d %H:%M %a"

# 根据状态决定显示格式
if [ -f "$STATE_FILE" ]; then
    date "$FULL_FORMAT"
else
    date "$DEFAULT_FORMAT"
fi
