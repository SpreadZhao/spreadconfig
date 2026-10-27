#!/usr/bin/env bash
set -euo pipefail

image=${1:?Expected an image path}
prefix=${2:-Image}
[[ -s "$image" ]] || exit 1
mime=$(file -b --mime-type -- "$image")
[[ "$mime" == image/* ]] || exit 1

if ! action=$(printf '%s\n' 'Copy to clipboard' 'Save' 'Edit' 'Pin' 'OCR' |
	fuzzel --dmenu --prompt 'Image action: ' --cache /dev/null); then
	exit 0
fi
case "$action" in
'Copy to clipboard')
	wl-copy --type "$mime" <"$image"
	notify-send --app-name screenshot 'Image copied to clipboard'
	;;
Save)
	directory="$(xdg-user-dir PICTURES)/screenshot"
	mkdir -p -- "$directory"
	case "$mime" in
	image/png) extension=png ;;
	image/jpeg) extension=jpg ;;
	image/webp) extension=webp ;;
	image/gif) extension=gif ;;
	image/svg+xml) extension=svg ;;
	image/tiff) extension=tiff ;;
	image/bmp | image/x-bmp) extension=bmp ;;
	image/heic | image/heif) extension=heic ;;
	*) extension=img ;;
	esac
	destination="$directory/${prefix//\//_}_$(date +%Y%m%d_%H%M%S)_$RANDOM.$extension"
	cp -- "$image" "$destination"
	notify-send --app-name screenshot 'Image saved' "$destination"
	;;
Edit)
	mkdir -p -- "$(xdg-user-dir PICTURES)/satty"
	satty --filename "$image"
	;;
Pin)
	swayimg --viewer --appid=swayimg-pin "$image"
	;;
OCR)
	text=$(tesseract "$image" stdout -l chi_sim+eng -c preserve_interword_spaces=1)
	if [[ -n "${text//[[:space:]]/}" ]]; then
		printf '%s' "$text" | wl-copy
		notify-send --app-name screenshot 'OCR text copied'
	else
		notify-send --app-name screenshot 'No text found'
	fi
	;;
esac
