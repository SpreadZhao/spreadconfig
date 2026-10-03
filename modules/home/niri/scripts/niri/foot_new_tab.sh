#!/usr/bin/env bash

cnt=0

niri msg action set-column-display tabbed
(
    niri msg event-stream | while read -r line; do
        if [[ "$line" == *"Window opened"* && "$line" == *"foot"* ]]; then
            niri msg action consume-or-expel-window-left
            break
        fi
        let cnt++
        if ((cnt >= 10)); then
            break
        fi
    done
) &

niri msg action spawn -- footclient
