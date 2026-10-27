#!/usr/bin/env bash

PID_FILE="/tmp/wf-recorder.pid"
LAST_FILE="/tmp/wf-recorder.lastfile"
SAVE_DIR="$HOME/Videos/screenrecord"
FILENAME_PREFIX="Recording"

notify() {
    local summary="$1"
    local message="$2"
    notify-send --app-name "screen record" -u normal "$summary" "$message"
}

refresh_bar() {
    pkill -RTMIN+7 -f dwl_status.sh 2>/dev/null || true
}

init_save_dir() {
    mkdir -p "$SAVE_DIR"
}

stop_recording() {
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null)
    if [[ -n "$pid" ]] && kill "$pid" >/dev/null 2>&1; then
        rm -f "$PID_FILE"
        refresh_bar
        if [[ -f "$LAST_FILE" ]]; then
            local lastpath
            lastpath=$(cat "$LAST_FILE")
            notify "Recording stopped" "Saved to: $lastpath"
            rm -f "$LAST_FILE"
        else
            notify "Recording stopped" ""
        fi
    else
        notify "Failed to stop recording" ""
        rm -f "$PID_FILE"
        refresh_bar
    fi
}

select_region() {
    local region
    region=$(slurp -d -b "#000000aa" -c "#ffffff")
    echo "$region"
}

generate_output_file() {
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    echo "$SAVE_DIR/${FILENAME_PREFIX}_${timestamp}.mp4"
}

start_recording() {
    local region="$1"
    local output_file="$2"

    echo "$output_file" >"$LAST_FILE"
    wf-recorder -g "$region" -f "$output_file" &

    echo $! >"$PID_FILE"
    refresh_bar
}

main() {
    init_save_dir

    if [[ -f "$PID_FILE" ]]; then
        stop_recording
        exit 0
    fi

    local region
    region=$(select_region)

    if [[ -z "$region" ]]; then
        notify "No region selected" ""
        exit 0
    fi

    local output_file
    output_file=$(generate_output_file)

    start_recording "$region" "$output_file"
}

main
