#!/usr/bin/env bash
set -euo pipefail

entry=${1:-}
id=${entry%%$'\t'*}
[[ "$id" =~ ^[0-9]+$ ]] || exit 0
decoded=$(mktemp --suffix=.clipboard-preview)
trap 'rm -f -- "$decoded"' EXIT
cliphist decode "$id" >"$decoded"
"${SCRIPT_HOME:-$HOME/scripts}/config/preview_file.sh" "$decoded" \
	"${FZF_PREVIEW_COLUMNS:-80}" "${FZF_PREVIEW_LINES:-24}"
