#!/usr/bin/bash
# 关闭显示器输出
niri msg action power-off-monitors

# 等待一段时间（例如 10 秒）
sleep 10

# 再次开启显示器输出
niri msg action power-on-monitors
