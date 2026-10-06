#!/usr/bin/env bash
set -euo pipefail

# Installed symlinks resolve to the application-owned source tree.
spreadconfig_script_source=$(readlink -f "${BASH_SOURCE[0]}")
# shellcheck source=modules/home/script-tools/scripts/config/host_context.sh
source "${spreadconfig_script_source%/modules/home/*}/modules/home/script-tools/scripts/config/host_context.sh" || exit 1
unset spreadconfig_script_source
preview_file="$SPREADCONFIG_SOURCE_ROOT/modules/home/script-tools/scripts/config/preview_file.sh"
file="$1"
width="${2:-${FZF_PREVIEW_COLUMNS:-80}}"
height="${3:-${FZF_PREVIEW_LINES:-24}}"

exec "$preview_file" "$file" "$width" "$height"
