#!/usr/bin/env bash
set -euo pipefail

outputs=$(niri msg -j outputs)

menu=$(
    echo "$outputs" | jq -r '
    to_entries[] |
    .key as $name |
    .value as $v |
    (
      $v.make // "Unknown"
    ) as $make |
    (
      $v.model // "Unknown"
    ) as $model |
    (
      if $v.logical then "on" else "off" end
    ) as $state |
    "\($name)|\($state)|\($make) \($model)"
  '
)

selected=$(echo "$menu" | wofi --dmenu --prompt "Toggle output")
[ -z "$selected" ] && exit 0

output=$(echo "$selected" | cut -d'|' -f1 | xargs)
state=$(echo "$selected" | awk -F'|' '{print $2}' | xargs)

if [ "$state" = "on" ]; then
    niri msg output "$output" off
else
    niri msg output "$output" on
fi
