#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ===============================
#        Option definitions
# ===============================
OPTION_CLIPBOARD="Copy to Clipboard"
OPTION_PIN="Pin"
OPTION_SAVE="Save"
OPTION_EDIT="Edit"
OPTION_OCR="OCR"
PROMPT_OUTPUT="Select Output"
PROMPT_ACTION="Select Screenshot Action"

# ===============================
#       User config
# ===============================
ENABLE_FREEZE=true
HIDE_CURSOR=true
KEEP_TMPFILE=false

# ===============================
#       Globals
# ===============================
TMPFILE=""
FREEZE_PID=""
SAVE_PATH="$HOME/Pictures/screenshot"
USE_OUTPUT_MODE=false
OUTPUT_NAME=""

# ===============================
#        Arg parsing
# ===============================
if [[ "${1:-}" == "-o" ]]; then
    USE_OUTPUT_MODE=true
fi

# ===============================
#        Notify
# ===============================
notify() {
    notify-send \
        --app-name "screenshot" \
        -u normal \
        -t 10000 \
        "$1"
}

# ===============================
#        Cleanup
# ===============================
cleanup() {
    if [ "$KEEP_TMPFILE" = false ] && [ -n "$TMPFILE" ]; then
        rm -f -- "$TMPFILE"
    fi
}
trap cleanup EXIT

# ===============================
#        Init tempfile
# ===============================
TMPFILE=$(mktemp --suffix=.png)

# ===============================
#        Capture
# ===============================
if [ "$USE_OUTPUT_MODE" = true ]; then
    # ----- Output selection mode -----
    if ! outputs_json=$(niri msg -j outputs); then
        notify "Failed to query outputs ❌"
        exit 1
    fi

    menu=$(jq -r '
      to_entries[] |
      select(.value.logical != null) |
      .key as $name |
      .value as $v |
      "\($name)|\($v.make // "Unknown") \($v.model // "Unknown")"
    ' <<<"$outputs_json")

    if [ -z "$menu" ]; then
        notify "No active outputs found ❌"
        exit 1
    fi

    selected=$(fuzzel --dmenu --prompt "$PROMPT_OUTPUT" --cache /dev/null <<<"$menu")
    [ -z "$selected" ] && exit 0

    OUTPUT_NAME="${selected%%|*}"

    if ! grim -o "$OUTPUT_NAME" "$TMPFILE"; then
        notify "Capture failed ❌"
        exit 1
    fi

else
    # ----- Region selection mode -----
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

# 确认文件存在
if [ ! -s "$TMPFILE" ]; then
    notify "Screenshot failed ❌"
    exit 1
fi

# ===============================
#        Action menu
# ===============================
choice=$(
    printf "%s\n%s\n%s\n%s\n%s" \
        "$OPTION_CLIPBOARD" \
        "$OPTION_EDIT" \
        "$OPTION_PIN" \
        "$OPTION_SAVE" \
        "$OPTION_OCR" |
        fuzzel --dmenu --prompt "$PROMPT_ACTION" --cache /dev/null
)

[ -z "$choice" ] && exit 0

# ===============================
#        Handle choice
# ===============================
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
    feh --theme "fit" --output-dir "$SAVE_PATH" "$TMPFILE"
    ;;

"$OPTION_SAVE")
    mkdir -p "$SAVE_PATH"
    timestamp=$(date '+%Y%m%d_%H%M%S')

    if [ "$USE_OUTPUT_MODE" = true ]; then
        pic="$SAVE_PATH/Screenshot_${OUTPUT_NAME}_${timestamp}.png"
    else
        pic="$SAVE_PATH/Screenshot_${timestamp}.png"
    fi

    if mv "$TMPFILE" "$pic"; then
        KEEP_TMPFILE=true
        notify "Saved to $pic 📁"
    else
        notify "Failed to save screenshot ❌"
    fi
    ;;

"$OPTION_OCR")
    ocr_lang="chi_sim+eng"

    if ! command -v tesseract >/dev/null 2>&1; then
        notify "tesseract not found ❌"
        exit 1
    fi

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
        notify "📋 OCR copied : ${PREVIEW}…"
    else
        notify "Failed to copy OCR result ❌"
    fi
    ;;

*)
    notify "Operation cancelled 🚫"
    ;;
esac
