#!/usr/bin/env bash

set -euo pipefail

suffix="${WAYBAR_OUTPUT_NAME:-default}"
file="/tmp/time_format-${suffix}"

if [[ -e "$file" ]]; then
    rm "$file"
else
    touch "$file"
fi

pkill -RTMIN+9 waybar
