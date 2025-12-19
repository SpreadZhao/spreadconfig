#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# === Option definitions ===
OPTION_CLIPBOARD="Copy to Clipboard"
OPTION_PIN="Pin"
OPTION_SAVE="Save"
OPTION_EDIT="Edit"
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

    if ! grim -g "$(slurp -d)" "$TMPFILE"; then
        [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
        notify "Capture failed ❌"
        exit 1
    fi

    [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
fi

# === Show menu ===
choice=$(
    printf "%s\n%s\n%s\n%s" \
        "$OPTION_CLIPBOARD" \
        "$OPTION_EDIT" \
        "$OPTION_PIN" \
        "$OPTION_SAVE" |
        wofi --dmenu --prompt "$PROMPT" --cache-file /dev/null
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
    swappy -f "$TMPFILE"
    ;;
"$OPTION_PIN")
    feh -Z -j --auto-zoom "$TMPFILE"
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
*)
    notify "Operation cancelled 🚫"
    ;;
esac
