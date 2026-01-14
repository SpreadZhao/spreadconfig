#!/bin/bash

# 你可以根据 sensors 的输出内容调整 grep 的关键字
TEMP_LINE=$(sensors | grep -E "Package id 0|Tctl|CPU Temp" | head -n 1)

# 提取温度值（只保留数字部分）
TEMP=$(echo "$TEMP_LINE" | grep -oP '\+?\d+(\.\d+)?°C' | head -n 1)
TEMP=${TEMP#+}            # 去掉前缀 "+"
TEMP=${TEMP//°C/}         # 去掉 "°C"
echo "$TEMP"
