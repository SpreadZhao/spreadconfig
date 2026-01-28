#!/usr/bin/env bash

set -euo pipefail

# Show main action menu
action="$(
    printf "Window\nMonitor\nClear\n" |
        fuzzel --dmenu --prompt "Dynamic Cast"
)"

case "$action" in
"Window")
    # Pick a window and set it as dynamic cast target
    niri msg action set-dynamic-cast-window --id "$(
        niri msg --json pick-window | jq -r '.id'
    )"
    ;;

"Monitor")
    output_name="$(
        niri msg -j outputs |
            jq -r '
          to_entries[]
          | "\(.value.make) \(.value.model) (\(.key))"
        ' |
            fuzzel --dmenu --prompt "Select monitor" |
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
    exit 0
    ;;
esac
