#!/usr/bin/env bash
set -euo pipefail

restore_label="Restore idle lock (screen off at 600s, lock at 605s)"
disable_label="Disable automatic screen blanking and locking"
unit_name="swayidle.service"
systemd_user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
override_dir="$systemd_user_dir/$unit_name.d"
override_file="$override_dir/lock-policy-disabled.conf"

write_disabled_override() {
    local swayidle_bin wlopm_bin
    swayidle_bin="$(command -v swayidle)"
    wlopm_bin="$(command -v wlopm)"

    mkdir -p "$override_dir"
    rm -f "$override_file"
    {
        printf '[Service]\nExecStart=\n'
        printf 'ExecStart=%s -C /dev/null -w timeout 0 "%s" resume "%s" after-resume "%s"\n' \
            "$swayidle_bin" "$wlopm_bin --off '*'" "$wlopm_bin --on '*'" "$wlopm_bin --on '*'"
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
    wlopm --on '*'
    notify-send --app-name "lock policy" "Idle lock disabled" "Automatic screen blanking and locking are disabled."
    ;;
"")
    exit 0
    ;;
*)
    notify-send --app-name "lock policy" "Unknown option" "$choice"
    exit 1
    ;;
esac
