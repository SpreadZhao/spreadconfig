#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PREVIEW_SCRIPT="$SCRIPT_DIR/fzf_dmenu_preview.sh"

TMP_INPUT=$(mktemp)
TMP_OUTPUT=$(mktemp)

trap 'rm -f "$TMP_INPUT" "$TMP_OUTPUT"' EXIT

cat >"$TMP_INPUT"

footclient \
	-a "lick-foot" \
	-T "dmenu" \
	-- sh -c 'fzf --preview "$1 {}" < "$2" > "$3"' \
	sh "$PREVIEW_SCRIPT" "$TMP_INPUT" "$TMP_OUTPUT"

if [[ -s "$TMP_OUTPUT" ]]; then
	cat "$TMP_OUTPUT"
fi
