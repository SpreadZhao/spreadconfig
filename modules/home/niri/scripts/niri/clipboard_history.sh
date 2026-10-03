#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
tmp_decode=""

notify() {
    notify-send \
        --app-name "clipboard-history" \
        -u normal \
        "$1" \
        "$2"
}

cleanup() {
    if [[ -n "$tmp_decode" ]]; then
        rm -f -- "$tmp_decode"
    fi
}
trap cleanup EXIT

if ! selection=$(cliphist list | fm --dmenu); then
    exit 0
fi

[[ -n "$selection" ]] || exit 0

tmp_decode=$(mktemp --suffix=.cliphist-decode)
if ! printf '%s\n' "$selection" | cliphist decode >"$tmp_decode"; then
    notify "Failed to decode clipboard entry ❌" ""
    exit 1
fi

mime_type=$(file -b --mime-type -- "$tmp_decode" 2>/dev/null || true)
if [[ "$mime_type" == image/* ]]; then
    "$script_dir/image_action_menu.sh" "$tmp_decode" "Clipboard"
elif ! wl-copy <"$tmp_decode"; then
    notify "Failed to copy clipboard entry ❌" ""
    exit 1
fi
