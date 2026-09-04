#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

PROMPT_OUTPUT="Select Output: "

# ===============================
#       User config
# ===============================
ENABLE_FREEZE=true
HIDE_CURSOR=true

# ===============================
#       Globals
# ===============================
TMPFILE=""
FREEZE_PID=""
USE_OUTPUT_MODE=false
USE_WINDOW_MODE=false
OUTPUT_NAME=""
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# ===============================
#        Arg parsing
# ===============================
case "${1:-}" in
-o)
    USE_OUTPUT_MODE=true
    ;;
-w)
    USE_WINDOW_MODE=true
    ;;
esac

# ===============================
#        Notify
# ===============================
notify() {
    notify-send \
        --app-name "screenshot" \
        -u normal \
        "$1" \
        "$2"
}

# ===============================
#        Cleanup
# ===============================
cleanup() {
    if [ -n "$TMPFILE" ]; then
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
        notify "Failed to query outputs ❌" ""
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
        notify "No active outputs found ❌" ""
        exit 1
    fi

    selected=$(fuzzel --dmenu --prompt "$PROMPT_OUTPUT" --cache /dev/null <<<"$menu")
    [ -z "$selected" ] && exit 0

    OUTPUT_NAME="${selected%%|*}"

    if ! grim -o "$OUTPUT_NAME" "$TMPFILE"; then
        notify "Capture failed ❌" ""
        exit 1
    fi

elif [ "$USE_WINDOW_MODE" = true ]; then
    # ----- Window selection mode -----

    if ! win_json=$(niri msg -j pick-window); then
        notify "Window selection failed ❌" ""
        exit 1
    fi

    win_id=$(jq '.id' <<<"$win_json")

    # 从窗口列表获取几何信息
    if ! rect=$(niri msg -j windows | jq -r "
        .[] | select(.id == $win_id) |
        .rect |
        \"\(.x),\(.y) \(.width)x\(.height)\"
    "); then
        notify "Failed to get window geometry ❌" ""
        exit 1
    fi

    echo "rect: $rect"

    if [ -z "$rect" ]; then
        notify "Window geometry not found ❌" ""
        exit 1
    fi

    if ! grim -g "$rect" "$TMPFILE"; then
        notify "Capture failed ❌" ""
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

    if ! grim -g "$(slurp -d -b "#000000aa" -c "#ffffff")" "$TMPFILE"; then
        [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
        notify "Capture failed ❌" ""
        exit 1
    fi

    [ -n "$FREEZE_PID" ] && kill "$FREEZE_PID" 2>/dev/null
fi

# 确认文件存在
if [ ! -s "$TMPFILE" ]; then
    notify "Screenshot failed ❌" ""
    exit 1
fi

save_prefix="Screenshot"
if [ "$USE_OUTPUT_MODE" = true ]; then
    save_prefix="Screenshot_${OUTPUT_NAME}"
fi

"$SCRIPT_DIR/image_action_menu.sh" "$TMPFILE" "$save_prefix"
