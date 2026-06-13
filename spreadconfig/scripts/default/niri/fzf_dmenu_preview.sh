#!/usr/bin/env bash
set -euo pipefail

line="${1:-}"
id=$(printf "%s\n" "$line" | awk '{print $1}')
width="${FZF_PREVIEW_COLUMNS:-80}"
height="${FZF_PREVIEW_LINES:-24}"
script_dir=$(cd "$(dirname "$0")" && pwd)
preview_file="$script_dir/../config/preview_file.sh"

if [[ -z "$id" ]]; then
	exit 0
fi

tmp_decode=$(mktemp --suffix=.cliphist-preview)
tmp_png=""

cleanup() {
	rm -f "$tmp_decode"
	if [[ -n "$tmp_png" ]]; then
		rm -f "$tmp_png"
	fi
}

trap cleanup EXIT

cliphist decode "$id" >"$tmp_decode"

is_binary_entry() {
	printf "%s\n" "$line" | grep -qi "binary"
}

is_svg_file() {
	file="$1"
	detected_mime=$(file -b --mime-type "$file" 2>/dev/null || true)

	if [[ "$detected_mime" == "image/svg+xml" ]]; then
		return 0
	fi

	LC_ALL=C grep -aqi '<svg[[:space:]>]' "$file" 2>/dev/null
}

render_kitty() {
	img="$1"
	display_img="$img"
	dim="${width}x${height}"

	if is_svg_file "$img"; then
		tmp_png=$(mktemp --suffix=.png)
		if magick "$img" -background white -alpha remove -alpha off "$tmp_png" 2>/dev/null; then
			display_img="$tmp_png"
		else
			"$preview_file" "$img" "$width" "$height"
			return
		fi
	fi

	kitten icat \
		--clear \
		--transfer-mode=memory \
		--unicode-placeholder \
		--stdin=no \
		--place="$dim@0x0" \
		"$display_img" |
		sed '$d' |
		sed $'$s/$/\e[m/'
}

if [[ -n "${KITTY_WINDOW_ID:-}" ]] && { is_binary_entry || is_svg_file "$tmp_decode"; }; then
	render_kitty "$tmp_decode"
else
	"$preview_file" "$tmp_decode" "$width" "$height"
fi
