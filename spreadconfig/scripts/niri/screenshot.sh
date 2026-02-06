#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# === Option definitions ===
OPTION_CLIPBOARD="Copy to Clipboard"
OPTION_PIN="Pin"
OPTION_SAVE="Save"
OPTION_EDIT="Edit"
OPTION_OCR="OCR"
PROMPT="Select Screenshot Action"

# === User-configurable options ===
NIRI_NATIVE=false  # true to use niri msg instead of grim + slurp
ENABLE_FREEZE=true # true to freeze the screen during screenshot
HIDE_CURSOR=true   # true to hide the cursor while freezing
KEEP_TMPFILE=false

# === Globals ===
TMPFILE=""
FREEZE_PID=""
SAVE_PATH="$HOME/Pictures/screenshot"

notify() {
    notify-send \
        --app-name "screenshot" \
        -u normal \
        -t 2000 \
        "$1"
}

cleanup() {
    if [ "$KEEP_TMPFILE" = false ] && [ -n "$TMPFILE" ]; then
        rm -f -- "$TMPFILE"
    fi
}
trap cleanup EXIT

# === Init tempfile ===
TMPFILE=$(mktemp --suffix=.png)

# === Capture screenshot ===
if [ "$NIRI_NATIVE" = true ]; then
    # --- niri native screenshot ---
    if ! niri msg action screenshot --path "$TMPFILE"; then
        notify "Capture failed ❌"
        exit 1
    fi

    # Wait until file is actually written (max ~5s)
    for _ in {1..50}; do
        if [ -s "$TMPFILE" ]; then
            break
        fi
        sleep 0.1
    done

    if [ ! -s "$TMPFILE" ]; then
        notify "Screenshot cancelled ❌"
        exit 1
    fi
else
    # --- grim + slurp with optional freeze ---
    if [ "$ENABLE_FREEZE" = true ]; then
        args=()
        [ "$HIDE_CURSOR" = true ] && args+=(--hide-cursor)
        wayfreeze "${args[@]}" &
        FREEZE_PID=$!
        sleep 0.1
    fi

    if ! grim -g "$(slurp -d -b "#0e1117aa" -c "#f5e0dc")" "$TMPFILE"; then
        [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
        notify "Capture failed ❌"
        exit 1
    fi

    [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
fi

# === Show menu ===
choice=$(
    printf "%s\n%s\n%s\n%s\n%s" \
        "$OPTION_CLIPBOARD" \
        "$OPTION_EDIT" \
        "$OPTION_PIN" \
        "$OPTION_SAVE" \
        "$OPTION_OCR" |
        fuzzel --dmenu --prompt "$PROMPT" --cache /dev/null
)

[ -z "$choice" ] && exit 0

# === Handle choice ===
case "$choice" in
"$OPTION_CLIPBOARD")
    if wl-copy --type image/png <"$TMPFILE"; then
        notify "Image copied to clipboard 📋"
    else
        notify "Failed to copy image ❌"
    fi
    ;;
"$OPTION_EDIT")
    satty -f "$TMPFILE"
    ;;
"$OPTION_PIN")
    feh --theme "fit" --output-dir "/home/spreadzhao/Pictures/screenshot" "$TMPFILE"
    ;;
"$OPTION_SAVE")
    timestamp=$(date '+%Y%m%d_%H%M%S')
    pic="$SAVE_PATH/Screenshot_${timestamp}.png"
    if mv "$TMPFILE" "$pic"; then
        KEEP_TMPFILE=true
        notify "Saved to $pic 📁"
    else
        notify "Failed to save screenshot ❌"
    fi
    ;;
"$OPTION_OCR")
    ocr_lang="chi_sim+eng"
    ocr_text=""

    if ! command -v tesseract >/dev/null 2>&1; then
        notify "tesseract not found ❌"
        exit 1
    fi

    if ! command -v wl-copy >/dev/null 2>&1; then
        notify "wl-copy not found ❌"
        exit 1
    fi

    # OCR → stdout
    # https://github.com/tesseract-ocr/tesseract/issues/991#issuecomment-311651758
    if ! ocr_text=$(tesseract "$TMPFILE" stdout -l "$ocr_lang" -c preserve_interword_spaces=1 2>/dev/null); then
        notify "OCR failed ❌"
        exit 1
    fi

    OCR_TEXT_TRIMMED=$(printf "%s" "$ocr_text" | sed '/^[[:space:]]*$/d')

    if [ -z "$OCR_TEXT_TRIMMED" ]; then
        notify "OCR finished but no text found ⚠️"
        exit 0
    fi

    if printf "%s" "$OCR_TEXT_TRIMMED" | wl-copy; then
        PREVIEW=$(printf "%s" "$OCR_TEXT_TRIMMED" | head -c 30 | tr '\n' ' ')
        notify "📋 OCR copied to clipboard : ${PREVIEW}…"
    else
        notify "Failed to copy OCR result ❌"
    fi
    ;;
*)
    notify "Operation cancelled 🚫"
    ;;
esac
