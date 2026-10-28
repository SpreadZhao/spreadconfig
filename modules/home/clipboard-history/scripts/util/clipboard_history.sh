#!/usr/bin/env bash
set -euo pipefail

script_home="${SCRIPT_HOME:-$HOME/scripts}"
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
printf -v preview '%q' "$script_dir/clipboard_preview.sh"
if ! selected=$(cliphist list | fzf-popup --title 'Clipboard history' -- \
	--delimiter=$'\t' --with-nth=2.. --no-sort --with-shell "$BASH -c" --preview "$preview {}"); then
	exit 0
fi
[[ -n "$selected" ]] || exit 0

decoded=$(mktemp --suffix=.clipboard)
trap 'rm -f -- "$decoded"' EXIT
printf '%s\n' "$selected" | cliphist decode >"$decoded"
mime=$(file -b --mime-type -- "$decoded")
if [[ "$mime" == image/* ]]; then
	"$script_home/util/image_action_menu.sh" "$decoded" Clipboard
else
	wl-copy --type 'text/plain;charset=utf-8' <"$decoded"
fi
