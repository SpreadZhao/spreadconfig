#!/usr/bin/env bash
set -euo pipefail

windows_json=$(niri msg -j windows)

selected_index=$(
    echo "$windows_json" |
        jq -r 'map("\(.title // .app_id)\u0000icon\u001f\(.app_id)") | .[]' |
        fuzzel -d --index
)

[[ -z "$selected_index" ]] && exit 0

window_id=$(echo "$windows_json" | jq -r ".[$selected_index].id")

niri msg action focus-window --id "$window_id"
