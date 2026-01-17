#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="$HOME/.local/share/niri-restart.log"

echo "[$(date '+%F %T')] starting niri event-stream" >>"$LOG_FILE"

# 使用进程替换，避免 pipe 产生第二个 bash
while read -r _; do
    pkill -RTMIN+8 waybar
done < <(niri msg event-stream)

echo "[$(date '+%F %T')] niri event-stream exited" >>"$LOG_FILE"
