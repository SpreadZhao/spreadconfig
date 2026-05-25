#!/usr/bin/env bash
set -euo pipefail

while read -r _; do
    pkill -RTMIN+8 waybar
done < <(niri msg event-stream)
