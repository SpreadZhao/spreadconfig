#!/usr/bin/env bash
set -euo pipefail

restore_label="恢复自动锁屏（600 秒关屏，605 秒锁屏）"
disable_label="禁止自动锁屏并保持屏幕开启"
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
    } > "$override_file"
}

choice="$(
    printf '%s\n%s\n' "$restore_label" "$disable_label" |
        fuzzel --dmenu --prompt "锁屏策略: "
)"

case "$choice" in
    "$restore_label")
        rm -f "$override_file"
        rmdir "$override_dir" 2>/dev/null || true
        systemctl --user daemon-reload
        systemctl --user restart "$unit_name"
        notify-send --app-name "lock policy" "已恢复自动锁屏" "600 秒关屏，605 秒锁屏。"
        ;;
    "$disable_label")
        write_disabled_override
        systemctl --user daemon-reload
        systemctl --user restart "$unit_name"
        niri msg action power-on-monitors >/dev/null 2>&1 || true
        notify-send --app-name "lock policy" "已禁止自动锁屏" "swayidle 已临时替换为空闲进程；恢复前屏幕会保持开启。"
        ;;
    "")
        exit 0
        ;;
    *)
        notify-send --app-name "lock policy" "未知选项" "$choice"
        exit 1
        ;;
esac
