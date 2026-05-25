#!/usr/bin/env bash

# https://github.com/Alexays/Waybar/issues/2821
SUFFIX="default"
STATE_FILE="/tmp/time_format-$SUFFIX"

DEFAULT_FORMAT="+%H:%M"
FULL_FORMAT="+%Y-%m-%d %H:%M %a"

# 根据状态决定显示格式
if [ -f "$STATE_FILE" ]; then
    date "$FULL_FORMAT"
else
    date "$DEFAULT_FORMAT"
fi
