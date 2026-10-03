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
preview_file="$spreadconfig_source_root/modules/home/script-tools/scripts/config/preview_file.sh"
unset spreadconfig_source_root
file="$1"
width="${2:-${FZF_PREVIEW_COLUMNS:-80}}"
height="${3:-${FZF_PREVIEW_LINES:-24}}"

exec "$preview_file" "$file" "$width" "$height"
