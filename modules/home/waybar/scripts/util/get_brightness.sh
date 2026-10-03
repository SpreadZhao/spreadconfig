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
