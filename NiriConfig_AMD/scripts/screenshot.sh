#!/bin/bash

# === Option definitions ===
OPTION_CLIPBOARD="Copy to Clipboard"
OPTION_PIN="Pin"
OPTION_SAVE="Save"
OPTION_EDIT="Edit"
PROMPT="Select Screenshot Action"

# === User-configurable options ===
ENABLE_FREEZE=true # true to freeze the screen during screenshot, false to disable
HIDE_CURSOR=true   # true to hide the cursor while freezing, false to show

# === Globals ===
TMPFILE=""

notify() {
    local message="$1"
    notify-send --app-name "screenshot" -u normal "" "$message"
}

# --- Function: Initialize temporary file for screenshot ---
init_tempfile() {
    TMPFILE=$(mktemp --suffix=.png)
}

# --- Function: Cleanup temporary file ---
cleanup() {
    rm -f "$TMPFILE"
}
trap cleanup EXIT

# --- Function: Freeze the screen if enabled ---
freeze_screen() {
    if [ "$ENABLE_FREEZE" = true ]; then
        local args=()
        if [ "$HIDE_CURSOR" = true ]; then
            args+=(--hide-cursor)
        fi
        wayfreeze "${args[@]}" &
        PID=$!
        # Allow some time for freeze to take effect
        sleep 0.1
    fi
}

# --- Function: Unfreeze the screen if it was frozen ---
unfreeze_screen() {
    if [ "$ENABLE_FREEZE" = true ]; then
        kill "$PID" 2>/dev/null
        # Clear the trap since unfreeze happened
        trap - EXIT
    fi
}

# --- Function: Capture screenshot ---
capture_screenshot() {
    freeze_screen
    if grim -g "$(slurp -d)" "$TMPFILE"; then
        unfreeze_screen
        notify "Capture successful ✅"
        return 0
    else
        unfreeze_screen
        notify "Capture failed ❌"
        cleanup
        return 1
    fi
}

# --- Function: Show action menu and get choice ---
show_menu() {
    printf "%s\n%s\n%s\n%s" \
        "$OPTION_CLIPBOARD" \
        "$OPTION_EDIT" \
        "$OPTION_PIN" \
        "$OPTION_SAVE" | wofi --dmenu --prompt "$PROMPT" --cache-file /dev/null
}

# --- Function: Handle the selected menu option ---
handle_choice() {
    case "$1" in
    "$OPTION_CLIPBOARD")
        if wl-copy --type image/png <"$TMPFILE"; then
            notify "Image copied to clipboard 📋"
        else
            notify "Failed to copy image to clipboard ❌"
        fi
        ;;
    "$OPTION_PIN")
        feh -. -Z -j ~/Pictures/ "$TMPFILE"
        ;;
    "$OPTION_SAVE")
        local timestamp
        timestamp=$(date '+%Y%m%d_%H%M%S')
        local savepath="$HOME/Pictures/Screenshot_${timestamp}.png"
        if mv "$TMPFILE" "$savepath"; then
            notify "Saved to $savepath 📁"
            # Prevent cleanup after move
            TMPFILE=""
        else
            notify "Failed to save screenshot ❌"
            cleanup
        fi
        ;;
    "$OPTION_EDIT")
        if swappy -f "$TMPFILE"; then
            notify "Editing completed ✏️"
        else
            notify "Editing cancelled or failed ❌"
        fi
        ;;
    *)
        notify "Operation cancelled 🚫"
        ;;
    esac
}

# === Main script execution ===
init_tempfile

if capture_screenshot; then
    choice=$(show_menu)
    handle_choice "$choice"
else
    exit 1
fi

# Clean up temporary file if it still exists
if [ -n "$TMPFILE" ] && [ -f "$TMPFILE" ]; then
    cleanup
fi
