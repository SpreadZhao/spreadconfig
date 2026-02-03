#!/usr/bin/env bash
set -euo pipefail

outputs_json=$(niri msg -j outputs)

on_count=$(jq '
  [ .[] | select(.logical != null) ] | length
' <<<"$outputs_json")

menu=$(jq -r '
  to_entries[] |
  .key as $name |
  .value as $v |
  "\($name)|\(if $v.logical != null then "on" else "off" end)|\($v.make // "Unknown") \($v.model // "Unknown")"
' <<<"$outputs_json")

selected=$(fuzzel --dmenu --prompt "Toggle output" <<<"$menu")
[ -z "$selected" ] && exit 0

IFS="|" read -r output state _ <<<"$selected"

if [[ "$state" == "on" && "$on_count" -le 1 ]]; then
    exit 0
fi

if [[ "$state" == "on" ]]; then
    niri msg output "$output" off
else
    niri msg output "$output" on
fi
