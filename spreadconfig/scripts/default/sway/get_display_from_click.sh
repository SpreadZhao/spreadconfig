#!/bin/bash

# 获取指针坐标
pointer_x="$BLOCK_X"
pointer_y="$BLOCK_Y"

# 获取所有显示器的信息
outputs=$(swaymsg -t get_outputs)

# 遍历每个输出，找出包含鼠标坐标的那个
# echo "$outputs" | jq -c '.[] | select(.active == true)' | while read -r output; do
#     name=$(echo "$output" | jq -r '.name')
#     rect_x=$(echo "$output" | jq -r '.rect.x')
#     rect_y=$(echo "$output" | jq -r '.rect.y')
#     rect_w=$(echo "$output" | jq -r '.rect.width')
#     rect_h=$(echo "$output" | jq -r '.rect.height')
#
#     if [ "$pointer_x" -ge "$rect_x" ] && [ "$pointer_x" -lt $((rect_x + rect_w)) ] &&
#        [ "$pointer_y" -ge "$rect_y" ] && [ "$pointer_y" -lt $((rect_y + rect_h)) ]; then
#         echo "$name"
#         exit 0
#     fi
# done
#
echo "1$output_x"
