#!/usr/bin/env bash
set -euo pipefail

coproc events {
    export LC_ALL=C
    exec gdbus monitor --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1
}
monitor_pid=$!
exec {events_fd}<&"${events[0]}"

# shellcheck disable=SC2329 # Invoked by the EXIT trap.
cleanup() {
    kill "$monitor_pid" 2>/dev/null || true
    wait "$monitor_pid" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

while IFS= read -r event <&"$events_fd"; do
    case "$event" in
    'The name org.freedesktop.login1 is owned by '*)
        systemd-notify --ready
        ;;
    '/org/freedesktop/login1: org.freedesktop.login1.Manager.PrepareForShutdown (true,)')
        systemctl --user stop dwl-session.target graphical-session.target
        exit 0
        ;;
    'The name org.freedesktop.login1 does not have an owner')
        echo 'dwl-shutdown: logind is unavailable' >&2
        exit 1
        ;;
    esac
done

echo 'dwl-shutdown: logind signal monitor exited' >&2
exit 1
