#!/usr/bin/env bash
set -euo pipefail

# Resolve the source checkout through installed symlinks.
spreadconfig_source_root=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
while [[ ! -f "$spreadconfig_source_root/flake.nix" || ! -d "$spreadconfig_source_root/hosts" ]]; do
    if [[ "$spreadconfig_source_root" == / ]]; then
        printf 'spreadconfig: could not find source checkout\n' >&2
        exit 1
    fi
    spreadconfig_source_root=$(dirname "$spreadconfig_source_root")
done
# shellcheck source=modules/home/script-tools/scripts/config/host_context.sh
source "$spreadconfig_source_root/modules/home/script-tools/scripts/config/host_context.sh"
unset spreadconfig_source_root

get_battery_status() {
	[[ "${SPREADCONFIG_HAS_BATTERY:-unknown}" != false ]] || return 0
	local supply_root="${SPREADCONFIG_POWER_SUPPLY_ROOT:-/sys/class/power_supply}"
	local battery_path="${SPREADCONFIG_BATTERY_DEVICE:-}" candidate battery_type
	local battery_percent battery_status icon

	if [[ -n "$battery_path" ]]; then
		[[ "$battery_path" == /* ]] || battery_path="$supply_root/$battery_path"
	else
		# Class entries are symlinks on real machines, so use a glob, not find -type d.
		for candidate in "$supply_root"/*; do
			[[ -r "$candidate/type" && -r "$candidate/capacity" ]] || continue
			IFS= read -r battery_type <"$candidate/type" || continue
			if [[ "$battery_type" == Battery ]]; then
				battery_path="$candidate"
				break
			fi
		done
	fi
	[[ -r "$battery_path/capacity" && -r "$battery_path/status" ]] || return 0
	IFS= read -r battery_percent <"$battery_path/capacity" || return 0
	IFS= read -r battery_status <"$battery_path/status" || return 0
	[[ "$battery_percent" =~ ^[0-9]+$ ]] || return 0
	battery_percent=$((10#$battery_percent))
	((battery_percent <= 100)) || return 0

	case "$battery_status" in
	Charging) icon="󰂄" ;;
	Discharging)
		if ((battery_percent <= 20)); then
			icon="󰁺"
		elif ((battery_percent <= 50)); then
			icon="󰁽"
		else
			icon="󰁹"
		fi
		;;
	Full) icon="󰁹" ;;
	"Not charging") icon="󰚥" ;;
	*) icon="󰁶" ;;
	esac
	printf '%s%s\n' "$battery_percent" "$icon"
}

get_battery_status
