#!/usr/bin/env bash

file="$1"
width="${2:-${FZF_PREVIEW_COLUMNS:-80}}"
height="${3:-${FZF_PREVIEW_LINES:-24}}"

show_by_chafa() {
	img="$1"
	width="$2"
	height="$3"
	bg="${4:-black}"

	chafa -f sixel -s "${width}x${height}" \
		--animate off \
		--polite on \
		-t 1 \
		--bg "$bg" \
		"$img"
}

is_svg_file() {
	file="$1"
	detected_mime="$(file -b --mime-type "$file" 2>/dev/null || true)"

	case "$detected_mime" in
	image/svg+xml)
		return 0
		;;
	esac

	case "${file##*.}" in
	svg | SVG)
		LC_ALL=C grep -qi '<svg[[:space:]>]' "$file" 2>/dev/null
		;;
	*)
		return 1
		;;
	esac
}

preview_video() {
	file="$1"
	width="$2"
	height="$3"

	tmp_img="$(mktemp --suffix=.png)"

	if ffmpegthumbnailer -i "$file" -o "$tmp_img" -s 0 2>/dev/null; then
		show_by_chafa "$tmp_img" "$width" "$height"
	fi

	rm -f "$tmp_img"
}

preview_audio() {
	file="$1"
	width="$2"
	height="$3"

	tmp_img="$(mktemp --suffix=.png)"

	if ffmpegthumbnailer -i "$file" -o "$tmp_img" -s 0 2>/dev/null; then
		show_by_chafa "$tmp_img" "$width" "$height"
	fi

	rm -f "$tmp_img"
}

preview_webp() {
	file="$1"
	width="$2"
	height="$3"

	tmp_img="$(mktemp --suffix=.png)"

	if magick "$file[0]" "$tmp_img" 2>/dev/null; then
		show_by_chafa "$tmp_img" "$width" "$height"
	fi

	rm -f "$tmp_img"
}

preview_bat() {
	file="$1"
	width="$2"

	bat --force-colorization \
		--paging=never \
		--style=changes,numbers \
		--terminal-width "$((width - 3))" \
		"$file"
}

preview_default() {
	file="$1"
	width="$2"
	height="$3"

	if file -b --extension "$file" | tr '/' '\n' | grep -qx ts; then
		preview_video "$file" "$width" "$height"
		exit 0
	fi

	preview_bat "$file" "$width"
}

mime_type="$(xdg-mime query filetype "$file")"

case "$mime_type" in
*application/pdf*)
	tmp_img="$(mktemp --suffix=.png)"

	if pdftoppm -singlefile -png -r 100 "$file" "$tmp_img" 2>/dev/null; then
		show_by_chafa "$tmp_img.png" "$width" "$height"
	fi

	rm -f "$tmp_img.png"
	;;

*application/x-7z-compressed*)
	7z l "$file"
	;;

*application/x-tar*)
	tar -tvf "$file"
	;;

*application/x-compressed-tar* | *application/x-*-compressed-tar*)
	tar -tvf "$file"
	;;

*application/vnd.rar*)
	unrar l "$file"
	;;

*application/zip*)
	unzip -l "$file"
	;;

*image/svg+xml*)
	show_by_chafa "$file" "$width" "$height" white
	;;

*image/webp*)
	preview_webp "$file" "$width" "$height"
	;;

*image/*)
	show_by_chafa "$file" "$width" "$height"
	;;

*video/*)
	preview_video "$file" "$width" "$height"
	;;

*audio/*)
	preview_audio "$file" "$width" "$height"
	;;

*application/xml* | *application/xhtml+xml*)
	if is_svg_file "$file"; then
		show_by_chafa "$file" "$width" "$height" white
	else
		preview_default "$file" "$width" "$height"
	fi
	;;

text/*)
	if is_svg_file "$file"; then
		show_by_chafa "$file" "$width" "$height" white
	else
		preview_default "$file" "$width" "$height"
	fi
	;;

*)
	preview_default "$file" "$width" "$height"
	;;
esac
