#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
file="$1"
width="${2:-${FZF_PREVIEW_COLUMNS:-80}}"
height="${3:-${FZF_PREVIEW_LINES:-24}}"

exec "$script_dir/preview_file.sh" "$file" "$width" "$height"
