#!/usr/bin/env bash
set -euo pipefail

# Installed symlinks resolve to the application-owned source tree.
spreadconfig_script_source=$(readlink -f "${BASH_SOURCE[0]}")
# shellcheck source=modules/home/script-tools/scripts/config/host_context.sh
source "${spreadconfig_script_source%/modules/home/*}/modules/home/script-tools/scripts/config/host_context.sh" || exit 1
unset spreadconfig_script_source

[[ "${SPREADCONFIG_HAS_BACKLIGHT:-unknown}" != false ]] || exit 0
brightness_args=(-m)
if [[ -n "${SPREADCONFIG_BACKLIGHT_DEVICE:-}" ]]; then
	brightness_args+=(--device "${SPREADCONFIG_BACKLIGHT_DEVICE##*/}")
fi
# Missing devices and unavailable brightnessctl are normal on desktop hosts.
brightness=$(brightnessctl "${brightness_args[@]}" 2>/dev/null) || exit 0
IFS=, read -r _ _ _ percent _ <<<"$brightness"
percent="${percent%\%}"
if [[ "$percent" =~ ^[0-9]+$ ]] && ((10#$percent <= 100)); then
	printf '%s󱩎\n' "$percent"
fi
