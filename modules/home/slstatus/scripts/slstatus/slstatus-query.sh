#!/usr/bin/env bash
set -euo pipefail

case "$1" in
sink | source)
    if [[ "$1" == sink ]]; then node=@DEFAULT_AUDIO_SINK@; else node=@DEFAULT_AUDIO_SOURCE@; fi
    if ! volume=$(wpctl get-volume "$node" 2>/dev/null); then
        printf -- '-'
        exit 0
    fi
    if [[ "$1" == source ]]; then
        icon='󰍬'
        muted_icon='󰍭'
    else
        info=$(wpctl inspect "$node" 2>/dev/null || true)
        case "${info,,}" in
        *blue*)
            icon='󰂯'
            muted_icon='󰂲'
            ;;
        *headphone* | *headset*)
            icon=''
            muted_icon='󰟎'
            ;;
        *)
            icon='󰕾'
            muted_icon='󰖁'
            ;;
        esac
    fi
    if [[ "$volume" == *'[MUTED]'* ]]; then icon=$muted_icon; fi
    awk -v icon="$icon" '
      $1 == "Volume:" && $2 ~ /^[0-9]+([.][0-9]+)?$/ {
        printf "%.0f%s", $2 * 100, icon
        found = 1
        exit
      }
      END { if (!found) printf "-" }
    ' <<<"$volume"
    ;;
esac
