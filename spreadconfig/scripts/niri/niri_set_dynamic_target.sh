#!/usr/bin/env bash

set -euo pipefail

# Show main action menu
action="$(
    printf "Window\nMonitor\nClear\n" |
        wofi --dmenu --prompt "Dynamic Cast"
)"

case "$action" in
"Window")
    # Pick a window and set it as dynamic cast target
    niri msg action set-dynamic-cast-window --id "$(
        niri msg --json pick-window | jq -r '.id'
    )"
    ;;

"Monitor")
    # Select a monitor (output) via wofi
    output_name="$(
        niri msg -j outputs |
            jq -r '
          to_entries[]
          | "\(.value.make) \(.value.model) (\(.key))"
        ' |
            wofi --dmenu --prompt "Select monitor" |
            sed -n 's/.*(\(.*\))$/\1/p'
    )"

    # Set selected monitor as dynamic cast target
    if [ -n "$output_name" ]; then
        niri msg action set-dynamic-cast-monitor "$output_name"
    fi
    ;;

"Clear")
    # Clear current dynamic cast target
    niri msg action clear-dynamic-cast-target
    ;;

*)
    # User cancelled or closed wofi
    exit 0
    ;;
esac
