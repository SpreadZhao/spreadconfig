#!/usr/bin/env bash
set -euo pipefail

export XDG_CURRENT_DESKTOP="dwl"
export XDG_SESSION_TYPE="wayland"
export XDG_SESSION_DESKTOP="dwl"

systemctl --user import-environment \
    WAYLAND_DISPLAY \
    DISPLAY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_TYPE \
    XDG_SESSION_DESKTOP \
    PATH || true

if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY \
        DISPLAY \
        XDG_CURRENT_DESKTOP \
        XDG_SESSION_TYPE \
        XDG_SESSION_DESKTOP \
        PATH || true
fi

systemctl --user start dwl-session.target || true

config_script="${XDG_CONFIG_HOME:-$HOME/.config}/dwl/config.sh"
if [[ -f "$config_script" ]]; then
    bash "$config_script" || true
fi
