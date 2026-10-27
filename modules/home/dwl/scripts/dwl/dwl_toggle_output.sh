#!/usr/bin/env bash
set -euo pipefail

outputs_json=$(wlr-randr --json)

on_count=$(jq '
  [ .[] | select(.enabled == true) ] | length
' <<<"$outputs_json")

menu=$(jq -r '
  .[] |
  "\(.name)|\(if .enabled then "on" else "off" end)|\(.make // "Unknown") \(.model // "Unknown")"
' <<<"$outputs_json")

selected=$(fuzzel --dmenu --prompt "Toggle output: " <<<"$menu")
[[ -z "$selected" ]] && exit 0

IFS="|" read -r output state _ <<<"$selected"

if [[ "$state" == "on" && "$on_count" -le 1 ]]; then
    exit 0
fi

if [[ "$state" == "on" ]]; then
    wlr-randr --output "$output" --off
else
    wlr-randr --output "$output" --on
    host_cfg="${XDG_CONFIG_HOME:-$HOME/.config}/dwl/host.sh"
    if [[ -f "$host_cfg" ]]; then
        bash "$host_cfg" || true
    fi
fi
