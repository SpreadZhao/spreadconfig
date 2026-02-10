#!/usr/bin/env bash

set -euo pipefail

DEFAULT_DIR="$HOME/Pictures/wallpaper"

DIR="${1:-$DEFAULT_DIR}"

if [[ ! -d "$DIR" ]]; then
    echo "Error: directory does not exist: $DIR" >&2
    exit 1
fi

mapfile -t images < <(
    find "$DIR" -type f -print0 |
    while IFS= read -r -d '' file; do
        mime=$(xdg-mime query filetype "$file" 2>/dev/null || true)
        [[ "$mime" == image/* ]] && echo "$file"
    done
)

if [[ "${#images[@]}" -eq 0 ]]; then
    echo "Error: no image files found in $DIR" >&2
    exit 1
fi

random_image="${images[RANDOM % ${#images[@]}]}"

echo "$random_image"
