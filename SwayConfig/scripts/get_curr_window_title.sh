#!/bin/bash

# 最大展示字符数
n=15

TITLE=$(swaymsg -t get_tree | jq -r '
  .. | select(.type?) | select(.focused == true) |
  "\(.name) [\(.app_id // .window_properties.instance // .window_properties.class)]"
  ')

# 特殊情况：匹配 "数字 [null]" 这种形式（允许前后空格）
if [[ "$TITLE" =~ ^[0-9]+\ \[null\]$ ]]; then
    exit 0
fi

# 用正则匹配 "name部分" 和 "[方括号部分]"
if [[ "$TITLE" =~ ^(.*)\ \[(.*)\]$ ]]; then
    NAME_PART="${BASH_REMATCH[1]}"
    BRACKET_PART="${BASH_REMATCH[2]}"

    # 截断 name 部分
    if [ ${#NAME_PART} -gt $n ]; then
        NAME_PART="${NAME_PART:0:n}…"
    fi

    echo " $NAME_PART [$BRACKET_PART]"
else
    # 如果不匹配，直接输出
    echo " $TITLE"
fi
