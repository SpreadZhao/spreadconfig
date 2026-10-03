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

camera_device="${SPREADCONFIG_CAMERA_DEVICE-/dev/video0}"
if [[ -z "$camera_device" ]]; then
	for candidate in /dev/video*; do
		if [[ -c "$candidate" ]]; then
			camera_device="$candidate"
			break
		fi
	done
elif [[ "$camera_device" != /* ]]; then
	camera_device="/dev/$camera_device"
fi

if [[ ! -c "$camera_device" ]]; then
	printf 'camera: no camera device available (%s); configure the camera device in the host profile\n' \
		"${camera_device:-/dev/video*}" >&2
	exit 1
fi

exec mpv "$camera_device" "$@"
