#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == --startup ]]; then
    read -r -a import_variables <<<"$DWL_IMPORT_VARIABLES"
    systemctl --user import-environment "${import_variables[@]}" || true
    dbus-update-activation-environment --systemd "${import_variables[@]}" || true
    systemctl --user start dwl-session.target || true
    "$DWL_HOST_STARTUP"
    exit 0
fi

session_vars="$DWL_SESSION_PROFILE/etc/profile.d/hm-session-vars.sh"
if [[ -f "$session_vars" ]]; then
    # Home Manager appends to environment variables that may be unset at login.
    set +u
    # shellcheck source=/dev/null
    source "$session_vars"
    set -u
fi

status_pid=
compositor_pid=
# shellcheck disable=SC2329 # Invoked by the EXIT trap.
cleanup() {
    local pid
    for pid in "$compositor_pid" "$status_pid"; do
        if [[ -n "$pid" ]]; then
            kill "$pid" 2>/dev/null || true
            wait "$pid" 2>/dev/null || true
        fi
    done
    systemctl --user stop dwl-session.target graphical-session.target || true
    systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

exec {status_fd}< <(exec slstatus -s)
status_pid=$!
dwl -s "\"$0\" --startup" "$@" <&"$status_fd" {status_fd}<&- &
compositor_pid=$!
exec {status_fd}<&-
if wait "$compositor_pid"; then
    result=0
else
    result=$?
fi
compositor_pid=
exit "$result"
