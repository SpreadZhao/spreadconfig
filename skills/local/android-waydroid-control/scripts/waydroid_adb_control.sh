#!/usr/bin/env bash
set -euo pipefail

adb_bin="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
session_log="${XDG_RUNTIME_DIR:-/tmp}/waydroid-session.log"
serial=""

usage() {
    cat <<'EOF'
Usage: waydroid_adb_control.sh <command> [args...]

Commands:
  start                         Start Waydroid session and connect adb
  show                          Open Waydroid full UI and connect adb
  stop                          Stop Waydroid session
  status                        Show Waydroid and adb status
  connect                       Connect adb to the Waydroid device
  reset-adb                     Restart adb server and reconnect
  shell <args...>               Run adb shell command
  tap <x> <y>                   Tap screen coordinate
  swipe <x1> <y1> <x2> <y2> [ms] Swipe screen coordinate
  text <text...>                Input text; spaces are converted to %s
  key <keycode>                 Send Android keyevent
  screenshot [path]             Save PNG screenshot
  dump-ui [path]                Save uiautomator XML dump
  install <apk>                 Install APK
  launch <package>              Launch package with monkey
  logcat [args...]              Run adb logcat
EOF
}

die() {
    printf 'waydroid-adb-control: %s\n' "$*" >&2
    exit 1
}

need() {
    command -v "$1" >/dev/null 2>&1 || die "missing command: $1"
}

adb() {
    [[ -x "$adb_bin" ]] || die "adb not found at ${adb_bin}; install platform-tools in Android Studio SDK"
    "$adb_bin" "$@"
}

status_value() {
    waydroid status | awk -F '\t' -v key="$1:" '$1 == key { print $2 }'
}

waydroid_ip() {
    status_value "IP address"
}

waydroid_serial() {
    local ip
    ip="$(waydroid_ip)"
    [[ -n "$ip" ]] || die "Waydroid has no IP address; start the session first"
    printf '%s:5555\n' "$ip"
}

adb_state() {
    local target="$1"
    adb devices | awk -v target="$target" '$1 == target { print $2 }'
}

wait_for_session() {
    local deadline="${1:-60}"
    local i
    for ((i = 0; i < deadline; i++)); do
        if [[ "$(status_value "Session")" == "RUNNING" ]]; then
            return 0
        fi
        sleep 1
    done
    die "Waydroid session did not become RUNNING; see ${session_log}"
}

wait_for_container() {
    local deadline="${1:-60}"
    local i
    for ((i = 0; i < deadline; i++)); do
        if [[ "$(status_value "Container")" == "RUNNING" ]]; then
            return 0
        fi
        sleep 1
    done
    die "Waydroid container did not become RUNNING; see ${session_log}"
}

start_session() {
    need waydroid

    if [[ "$(status_value "Session")" != "RUNNING" ]]; then
        nohup waydroid session start >"${session_log}" 2>&1 &
    fi

    wait_for_session 90
}

ensure_container_awake() {
    need waydroid

    if [[ "$(status_value "Container")" == "FROZEN" ]]; then
        adb kill-server >/dev/null 2>&1 || true
        waydroid session stop >/dev/null 2>&1 || true
        nohup waydroid session start >"${session_log}" 2>&1 &
        wait_for_session 90
    elif [[ "$(status_value "Container")" != "RUNNING" ]]; then
        nohup waydroid show-full-ui >"${session_log}" 2>&1 &
    fi

    wait_for_container 90
}

show_ui() {
    start_session
    ensure_container_awake
    nohup waydroid show-full-ui >"${session_log}" 2>&1 &
    wait_for_session 90
}

connect_adb() {
    need waydroid

    start_session
    ensure_container_awake
    serial="$(waydroid_serial)"

    case "$(adb_state "$serial")" in
        device)
            return 0
            ;;
        offline)
            adb kill-server >/dev/null 2>&1 || true
            ;;
    esac

    adb start-server >/dev/null

    local last_output=""
    local i
    for ((i = 0; i < 12; i++)); do
        last_output="$(adb connect "$serial" 2>&1 || true)"

        case "$(adb_state "$serial")" in
            device)
                return 0
                ;;
            unauthorized)
                die "adb is unauthorized; run the 'show' command and accept the RSA prompt in Waydroid"
                ;;
        esac
        sleep 1
    done

    die "adb did not connect to ${serial}; last adb output: ${last_output}"
}

adb_device() {
    connect_adb
    adb -s "$serial" "$@"
}

artifact_path() {
    local suffix="$1"
    mkdir -p /tmp/waydroid
    printf '/tmp/waydroid/%s-%s\n' "$(date +%Y%m%d-%H%M%S)" "$suffix"
}

case "${1:-}" in
    start)
        connect_adb
        adb devices -l
        ;;
    show)
        show_ui
        connect_adb
        adb devices -l
        ;;
    stop)
        if [[ "$(status_value "Session")" == "RUNNING" ]]; then
            waydroid session stop
        fi
        ;;
    status)
        waydroid status
        adb devices -l
        ;;
    connect)
        connect_adb
        adb devices -l
        ;;
    reset-adb)
        adb kill-server >/dev/null 2>&1 || true
        adb start-server >/dev/null
        connect_adb
        adb devices -l
        ;;
    shell)
        shift
        [[ $# -gt 0 ]] || die "shell requires a command"
        adb_device shell "$@"
        ;;
    tap)
        [[ $# -eq 3 ]] || die "tap requires: <x> <y>"
        adb_device shell input tap "$2" "$3"
        ;;
    swipe)
        [[ $# -eq 5 || $# -eq 6 ]] || die "swipe requires: <x1> <y1> <x2> <y2> [ms]"
        adb_device shell input swipe "$2" "$3" "$4" "$5" "${6:-300}"
        ;;
    text)
        shift
        [[ $# -gt 0 ]] || die "text requires input text"
        text="$*"
        adb_device shell input text "${text// /%s}"
        ;;
    key)
        [[ $# -eq 2 ]] || die "key requires: <keycode>"
        adb_device shell input keyevent "$2"
        ;;
    screenshot)
        path="${2:-$(artifact_path screenshot.png)}"
        mkdir -p "$(dirname "$path")"
        tmp="$(mktemp)"
        adb_device exec-out screencap -p >"$tmp"
        offset="$(LC_ALL=C grep -abo $'\x89PNG' "$tmp" | head -n 1 | cut -d: -f1)"
        [[ -n "$offset" ]] || die "screenshot output did not contain a PNG stream"
        dd if="$tmp" of="$path" bs=1 skip="$offset" status=none
        rm -f "$tmp"
        printf '%s\n' "$path"
        ;;
    dump-ui)
        path="${2:-$(artifact_path window.xml)}"
        mkdir -p "$(dirname "$path")"
        adb_device shell uiautomator dump /sdcard/window.xml >/dev/null
        adb_device exec-out cat /sdcard/window.xml >"$path"
        printf '%s\n' "$path"
        ;;
    install)
        [[ $# -eq 2 ]] || die "install requires: <apk>"
        adb_device install -r "$2"
        ;;
    launch)
        [[ $# -eq 2 ]] || die "launch requires: <package>"
        adb_device shell monkey -p "$2" 1
        ;;
    logcat)
        shift
        adb_device logcat "$@"
        ;;
    "" | -h | --help | help)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac
