#!/bin/bash

PIDFILE="/tmp/wf-recorder.pid"

if [ -f "$PIDFILE" ]; then
    pid=$(cat "$PIDFILE")
    if ps -p "$pid" > /dev/null 2>&1; then
        elapsed=$(ps -o etimes= -p "$pid")
        # Format HH:MM:SS
        printf "%02d:%02d:%02d\n" $((elapsed/3600)) $((elapsed%3600/60)) $((elapsed%60))
        exit 0
    fi
fi

# Not recording
# echo "⏹"
exit 0
