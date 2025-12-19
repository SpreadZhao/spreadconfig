#!/usr/bin/env bash
#
# cpu_usage.sh — Calculate total CPU usage without delay by caching previous stats
# 
# How it works:
#   1. On each run, the script reads current CPU stats from /proc/stat.
#   2. It compares them with the previous stats saved in /tmp/cpu_stat_prev.
#   3. If previous stats exist, it calculates CPU usage instantly.
#   4. Then it saves the new stats for the next run.
#

# File to store previous CPU stats
SUFFIX=$WAYBAR_OUTPUT_NAME
PREV_FILE="/tmp/cpu_stat_prev_$SUFFIX"
DEFAULT_CPU_USAGE="0"

# ------------------------------------------------------------
# Function: read_cpu_stats
# Description: Read current CPU user, system, and idle values.
# Output: Echo three numbers: user system idle
# ------------------------------------------------------------
read_cpu_stats() {
    # grep only the total line (starts with "cpu ")
    read -r _ user nice system idle rest <<<"$(grep '^cpu ' /proc/stat)"
    echo "$user $system $idle"
}

# ------------------------------------------------------------
# Function: save_cpu_stats
# Description: Save the given stats to PREV_FILE for later use.
# Arguments: user system idle
# ------------------------------------------------------------
save_cpu_stats() {
    echo "$1 $2 $3" > "$PREV_FILE"
}

# ------------------------------------------------------------
# Function: calc_cpu_usage
# Description: Compute CPU usage percentage from two samples.
# Arguments: user1 system1 idle1 user2 system2 idle2
# Output: Print CPU usage with one decimal place.
# ------------------------------------------------------------
calc_cpu_usage() {
    local u1=$1 s1=$2 i1=$3
    local u2=$4 s2=$5 i2=$6

    local used1=$((u1 + s1))
    local used2=$((u2 + s2))
    local total1=$((u1 + s1 + i1))
    local total2=$((u2 + s2 + i2))

    local du=$((used2 - used1))
    local dt=$((total2 - total1))

    # Avoid division by zero
    if (( dt == 0 )); then
        echo "$DEFAULT_CPU_USAGE"
        return
    fi

    # Use awk for floating-point division and formatting
    awk -v du="$du" -v dt="$dt" 'BEGIN { printf "%.1f\n", du * 100.0 / dt }'
}

# ------------------------------------------------------------
# Function: main
# Description: Main control flow.
# ------------------------------------------------------------
main() {
    read -r user_now sys_now idle_now <<<"$(read_cpu_stats)"

    if [[ -f "$PREV_FILE" ]]; then
        # Previous stats exist — calculate immediately
        read -r user_prev sys_prev idle_prev < "$PREV_FILE"
        calc_cpu_usage "$user_prev" "$sys_prev" "$idle_prev" "$user_now" "$sys_now" "$idle_now"
    else
        echo "$DEFAULT_CPU_USAGE"  # First run, no previous data
    fi

    # Save current stats for next run
    save_cpu_stats "$user_now" "$sys_now" "$idle_now"
}

main "$@"
