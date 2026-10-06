#!/usr/bin/env bash
set -euo pipefail

# Installed symlinks resolve to the application-owned source tree.
spreadconfig_script_source=$(readlink -f "${BASH_SOURCE[0]}")
# shellcheck source=modules/home/script-tools/scripts/config/host_context.sh
source "${spreadconfig_script_source%/modules/home/*}/modules/home/script-tools/scripts/config/host_context.sh" || exit 1
unset spreadconfig_script_source

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
