#!/usr/bin/env bash
set -u

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
prev_total=0
prev_idle=0

read_cpu() {
    local user nice system idle iowait irq softirq steal
    if ! read -r _ user nice system idle iowait irq softirq steal _ </proc/stat; then
        printf -- '-%%'
        return
    fi
    local idle_all=$((idle + iowait))
    local total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    local diff_total=$((total - prev_total))
    local diff_idle=$((idle_all - prev_idle))
    prev_total=$total
    prev_idle=$idle_all

    if ((diff_total <= 0)); then
        printf '0%%'
        return
    fi
    local usage=$(((100 * (diff_total - diff_idle)) / diff_total))
    printf '%d%%' "$usage"
}

read_memory() {
    awk '
        /^MemTotal:/ { total=$2 }
        /^MemAvailable:/ { avail=$2 }
        END {
            if (total > 0) {
                printf "%.0f%%", ((total - avail) * 100) / total
            } else {
                printf "-%%"
            }
        }
    ' /proc/meminfo
}

read_temp() {
    local hwmon_dir name raw zone_file
    for hwmon_dir in /sys/class/hwmon/hwmon*; do
        if [[ -r "$hwmon_dir/name" && -r "$hwmon_dir/temp1_input" ]]; then
            read -r name <"$hwmon_dir/name" || continue
            case "$name" in
            k10temp | coretemp | zenpower | cpu_thermal)
                read -r raw <"$hwmon_dir/temp1_input" || continue
                if [[ "$raw" =~ ^[0-9]+$ ]] && ((raw > 0)); then
                    printf '%d°C' "$((raw / 1000))"
                    return
                fi
                ;;
            esac
        fi
    done
    for zone_file in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp1_input; do
        if [[ -r "$zone_file" ]]; then
            read -r raw <"$zone_file" || continue
            if [[ "$raw" =~ ^[0-9]+$ ]] && ((raw > 0)); then
                printf '%d°C' "$((raw / 1000))"
                return
            fi
        fi
    done
    printf -- '-°C'
}

read_network() {
    local default_iface
    default_iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')
    if [[ -z "$default_iface" ]]; then
        printf '󰖪'
        return
    fi
    if [[ -d "/sys/class/net/$default_iface/wireless" ]]; then
        printf ' %s' "$default_iface"
    else
        printf '󰈀 %s' "$default_iface"
    fi
}

read_recording() {
    local pid_file="/tmp/wf-recorder.pid"
    if [[ ! -f "$pid_file" ]]; then
        return
    fi
    local pid
    read -r pid <"$pid_file" 2>/dev/null || return
    if [[ -z "$pid" ]] || ! kill -0 "$pid" 2>/dev/null; then
        return
    fi
    local start_mtime now elapsed mins secs
    start_mtime=$(stat -c %Y "$pid_file" 2>/dev/null || echo 0)
    now=$(date +%s)
    elapsed=$((now - start_mtime))
    ((elapsed < 0)) && elapsed=0
    mins=$((elapsed / 60))
    secs=$((elapsed % 60))
    printf '󰑊 %02d:%02d | ' "$mins" "$secs"
}

read_battery() {
    local bat_dir
    for bat_dir in /sys/class/power_supply/BAT*; do
        if [[ -r "$bat_dir/capacity" ]]; then
            local cap status icon="󰁹"
            read -r cap <"$bat_dir/capacity" || continue
            read -r status <"$bat_dir/status" 2>/dev/null || status=""
            if [[ "$status" == "Charging" ]]; then
                icon="󰂄"
            fi
            printf ' | %s %s%%' "$icon" "$cap"
            return
        fi
    done
}

# Prime CPU counters for accurate first delta.
read_cpu >/dev/null

sleep_pid=""
trap '[[ -n "$sleep_pid" ]] && kill "$sleep_pid" 2>/dev/null || true' SIGRTMIN+7 USR1

while true; do
    rec_part="$(read_recording)"
    cpu_part="$(read_cpu)"
    mem_part="$(read_memory)"
    temp_part="$(read_temp)"
    net_part="$(read_network)"
    sink_part="$("$script_dir/sink_dwl.sh" 2>/dev/null || printf -- '-')"
    source_part="$("$script_dir/source_dwl.sh" 2>/dev/null || printf -- '-')"
    bat_part="$(read_battery)"
    time_part="$(date '+%Y-%m-%d %H:%M:%S')"

    printf ' %s %s |  %s |  %s | %s | %s %s%s | %s \n' \
        "$rec_part" \
        "$cpu_part" \
        "$mem_part" \
        "$temp_part" \
        "$net_part" \
        "$sink_part" \
        "$source_part" \
        "$bat_part" \
        "$time_part" || exit 0

    sleep 2 &
    sleep_pid=$!
    wait "$sleep_pid" 2>/dev/null || true
    sleep_pid=""
done
