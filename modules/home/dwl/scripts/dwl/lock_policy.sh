#!/usr/bin/env bash
set -euo pipefail

restore_label="Restore idle lock (screen off at 600s, lock at 605s)"
disable_label="Disable idle lock and keep the screen on"
unit_name="swayidle.service"
systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
override_dir="$systemd_user_dir/$unit_name.d"
override_file="$override_dir/lock-policy-disabled.conf"

write_disabled_override() {
    local sleep_bin="/run/current-system/sw/bin/sleep"

    if [[ ! -x "$sleep_bin" ]]; then
        sleep_bin="$(command -v sleep)"
    fi

    mkdir -p "$override_dir"
    {
        printf '[Service]\n'
        printf 'ExecStart=\n'
        printf 'ExecStart=%s infinity\n' "$sleep_bin"
    } >"$override_file"
}

choice="$(
    printf '%s\n%s\n' "$restore_label" "$disable_label" |
        fuzzel --dmenu --prompt "Idle lock: "
)"

case "$choice" in
"$restore_label")
    rm -f "$override_file"
    rmdir "$override_dir" 2>/dev/null || true
    systemctl --user daemon-reload
    systemctl --user restart "$unit_name"
    notify-send --app-name "lock policy" "Idle lock restored" "Screen off after 600 seconds; lock after 605 seconds."
    ;;
"$disable_label")
    write_disabled_override
    systemctl --user daemon-reload
    systemctl --user restart "$unit_name"
    wlopm --on '*' >/dev/null 2>&1 || true
    notify-send --app-name "lock policy" "Idle lock disabled" "The screen will stay on until idle lock is restored."
    ;;
"")
    exit 0
    ;;
*)
    notify-send --app-name "lock policy" "Unknown option" "$choice"
    exit 1
    ;;
esac
