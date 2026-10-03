#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    notify-send \
        --urgency=critical \
        "expect 1 param but got $#"
    exit 1
fi

exec kitty \
    --class "lick-kitty" \
    -T "$1" \
    -- zsh -lc "$1"
