#!/usr/bin/env bash
set -euo pipefail

line="${1:-}"
id=$(printf "%s\n" "$line" | awk '{print $1}')
width="${FZF_PREVIEW_COLUMNS:-80}"
height="${FZF_PREVIEW_LINES:-24}"
# Installed symlinks resolve to the application-owned source tree.
spreadconfig_script_source=$(readlink -f "${BASH_SOURCE[0]}")
# shellcheck source=modules/home/script-tools/scripts/config/host_context.sh
source "${spreadconfig_script_source%/modules/home/*}/modules/home/script-tools/scripts/config/host_context.sh" || exit 1
unset spreadconfig_script_source
preview_file="$SPREADCONFIG_SOURCE_ROOT/modules/home/script-tools/scripts/config/preview_file.sh"

if [[ -z "$id" ]]; then
	exit 0
fi

tmp_decode=$(mktemp --suffix=.cliphist-preview)

cleanup() {
	rm -f "$tmp_decode"
}

trap cleanup EXIT

cliphist decode "$id" >"$tmp_decode"

"$preview_file" "$tmp_decode" "$width" "$height"
