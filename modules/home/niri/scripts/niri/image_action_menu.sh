#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

OPTION_CLIPBOARD="Copy to Clipboard"
OPTION_PIN="Pin"
OPTION_SAVE="Save"
OPTION_EDIT="Edit"
OPTION_OCR="OCR"
PROMPT_ACTION="Select Image Action: "

IMAGE_PATH="${1:-}"
SAVE_PREFIX="${2:-Image}"
SAVE_PATH="$HOME/Pictures/screenshot"

notify() {
    notify-send \
        --app-name "image-actions" \
        -u normal \
        "$1" \
        "$2"
}

image_extension() {
    case "$1" in
    image/png) printf 'png' ;;
    image/jpeg) printf 'jpg' ;;
    image/webp) printf 'webp' ;;
    image/gif) printf 'gif' ;;
    image/svg+xml) printf 'svg' ;;
    image/tiff) printf 'tiff' ;;
    image/bmp | image/x-bmp) printf 'bmp' ;;
    image/heic | image/heif) printf 'heic' ;;
    *) printf 'img' ;;
    esac
}

if [[ -z "$IMAGE_PATH" || ! -s "$IMAGE_PATH" ]]; then
    notify "Image file is missing or empty ❌" "$IMAGE_PATH"
    exit 1
fi

mime_type=$(file -b --mime-type -- "$IMAGE_PATH" 2>/dev/null || true)
if [[ "$mime_type" != image/* ]]; then
    notify "Selected content is not an image ❌" "$mime_type"
    exit 1
fi

if ! choice=$(
    printf "%s\n%s\n%s\n%s\n%s" \
        "$OPTION_CLIPBOARD" \
        "$OPTION_EDIT" \
        "$OPTION_PIN" \
        "$OPTION_SAVE" \
        "$OPTION_OCR" |
        fuzzel --dmenu --prompt "$PROMPT_ACTION" --cache /dev/null
); then
    exit 0
fi

[[ -n "$choice" ]] || exit 0

case "$choice" in
"$OPTION_CLIPBOARD")
    if wl-copy --type "$mime_type" <"$IMAGE_PATH"; then
        notify "Image copied to clipboard 📋" ""
    else
        notify "Failed to copy image ❌" ""
        exit 1
    fi
    ;;

"$OPTION_EDIT")
    if ! satty -f "$IMAGE_PATH"; then
        notify "Failed to open image editor ❌" ""
        exit 1
    fi
    ;;

"$OPTION_PIN")
    if ! swayimg --viewer --appid=swayimg-pin "$IMAGE_PATH"; then
        notify "Failed to pin image ❌" ""
        exit 1
    fi
    ;;

"$OPTION_SAVE")
    mkdir -p "$SAVE_PATH"
    timestamp=$(date '+%Y%m%d_%H%M%S')
    extension=$(image_extension "$mime_type")
    safe_prefix=${SAVE_PREFIX//\//_}
    destination="$SAVE_PATH/${safe_prefix}_${timestamp}.${extension}"

    if cp -- "$IMAGE_PATH" "$destination"; then
        notify "Saved to 📁" "$destination"
    else
        notify "Failed to save image ❌" ""
        exit 1
    fi
    ;;

"$OPTION_OCR")
    ocr_lang="chi_sim+eng"

    if ! command -v tesseract >/dev/null 2>&1; then
        notify "tesseract not found ❌" ""
        exit 1
    fi

    if ! ocr_text=$(tesseract "$IMAGE_PATH" stdout -l "$ocr_lang" -c preserve_interword_spaces=1 2>/dev/null); then
        notify "OCR failed ❌" ""
        exit 1
    fi

    ocr_text_trimmed=$(printf "%s" "$ocr_text" | sed '/^[[:space:]]*$/d')

    if [[ -z "$ocr_text_trimmed" ]]; then
        notify "OCR finished but no text found ⚠️" ""
        exit 0
    fi

    if printf "%s" "$ocr_text_trimmed" | wl-copy; then
        preview=${ocr_text_trimmed:0:30}
        preview=${preview//$'\n'/ }
        notify "📋 OCR copied" "${preview}…"
    else
        notify "Failed to copy OCR result ❌" ""
        exit 1
    fi
    ;;

*)
    exit 0
    ;;
esac
