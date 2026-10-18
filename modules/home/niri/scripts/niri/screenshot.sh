#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROMPT_OUTPUT="Select output: "

ENABLE_FREEZE=true
HIDE_CURSOR=true

TMPFILE=""
FREEZE_PID=""
USE_OUTPUT_MODE=false
USE_WINDOW_MODE=false
OUTPUT_NAME=""
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

case "${1:-}" in
-o)
    USE_OUTPUT_MODE=true
    ;;
-w)
    USE_WINDOW_MODE=true
    ;;
esac

notify() {
    notify-send \
        --app-name "screenshot" \
        -u normal \
        "$1" \
        "$2"
}

cleanup() {
    if [ -n "$TMPFILE" ]; then
        rm -f -- "$TMPFILE"
    fi
}
trap cleanup EXIT

TMPFILE=$(mktemp --suffix=.png)

if [ "$USE_OUTPUT_MODE" = true ]; then
    # Capture one output.
    if ! outputs_json=$(niri msg -j outputs); then
        notify "Failed to query outputs" ""
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
        notify "No active outputs found" ""
        exit 1
    fi

    selected=$(fuzzel --dmenu --prompt "$PROMPT_OUTPUT" --cache /dev/null <<<"$menu")
    [ -z "$selected" ] && exit 0

    OUTPUT_NAME="${selected%%|*}"

    if ! grim -o "$OUTPUT_NAME" "$TMPFILE"; then
        notify "Capture failed" ""
        exit 1
    fi

elif [ "$USE_WINDOW_MODE" = true ]; then
    # Capture the selected window.

    if ! win_json=$(niri msg -j pick-window); then
        notify "Window selection failed" ""
        exit 1
    fi

    win_id=$(jq '.id' <<<"$win_json")

    # Read the selected window geometry.
    if ! rect=$(niri msg -j windows | jq -r "
        .[] | select(.id == $win_id) |
        .rect |
        \"\(.x),\(.y) \(.width)x\(.height)\"
    "); then
        notify "Failed to get window geometry" ""
        exit 1
    fi

    echo "rect: $rect"

    if [ -z "$rect" ]; then
        notify "Window geometry not found" ""
        exit 1
    fi

    if ! grim -g "$rect" "$TMPFILE"; then
        notify "Capture failed" ""
        exit 1
    fi

else
    # Freeze the screen while selecting a region.
    if [ "$ENABLE_FREEZE" = true ]; then
        args=()
        [ "$HIDE_CURSOR" = true ] && args+=(--hide-cursor)
        wayfreeze "${args[@]}" &
        FREEZE_PID=$!
        sleep 0.1
    fi

    if ! grim -g "$(slurp -d -b "#000000aa" -c "#ffffff")" "$TMPFILE"; then
        [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
        notify "Capture failed" ""
        exit 1
    fi

    [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
fi

# Reject an empty capture.
if [ ! -s "$TMPFILE" ]; then
    notify "Screenshot failed" ""
    exit 1
fi

save_prefix="Screenshot"
if [ "$USE_OUTPUT_MODE" = true ]; then
    save_prefix="Screenshot_${OUTPUT_NAME}"
fi

"$SCRIPT_DIR/image_action_menu.sh" "$TMPFILE" "$save_prefix"
