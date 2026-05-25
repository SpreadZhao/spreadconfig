#!/usr/bin/env bash
# fzf preview script for cliphist
line="$1"
id=$(echo "$line" | awk '{print $1}')

if echo "$line" | grep -q "binary"; then
    tmp_img=$(mktemp --suffix=.png)
    cliphist decode "$id" > "$tmp_img"

    dim=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}
    kitten icat --clear --transfer-mode=memory --unicode-placeholder --stdin=no --place="$dim@0x0" "$tmp_img" | sed '$d' | sed $'$s/$/\e[m/'

    rm -f "$tmp_img"
else
    cliphist decode "$id"
fi
