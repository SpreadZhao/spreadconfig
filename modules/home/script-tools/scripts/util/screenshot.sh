#!/usr/bin/env bash
set -euo pipefail

script_home="${SCRIPT_HOME:-$HOME/scripts}"
temporary_image=""
freeze_pid=""

cleanup() {
	if [[ -n "$freeze_pid" ]]; then
		kill "$freeze_pid" 2>/dev/null || true
		wait "$freeze_pid" 2>/dev/null || true
	fi
	[[ -z "$temporary_image" ]] || rm -f -- "$temporary_image"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

temporary_image=$(mktemp --suffix=.png)
prefix=Screenshot
case "${1:-}" in
"")
	wayfreeze --hide-cursor &
	freeze_pid=$!
	sleep 0.1
	if ! kill -0 "$freeze_pid" 2>/dev/null; then
		notify-send --app-name screenshot 'Could not freeze the screen'
		exit 1
	fi
	if ! geometry=$(slurp -d -b '#000000aa' -c '#ffffff'); then
		exit 0
	fi
	[[ -n "$geometry" ]] || exit 0
	grim -g "$geometry" "$temporary_image"
	;;
-o)
	if ! output=$(slurp -o -r -f '%o'); then
		exit 0
	fi
	[[ -n "$output" ]] || exit 0
	grim -o "$output" "$temporary_image"
	prefix="Screenshot_$output"
	;;
-w)
	windows=$(lswt --json)
	count=$(jq '[.toplevels[] | select(.identifier != null)] | length' <<<"$windows")
	((count > 0)) || exit 0
	if ! selected_index=$(jq -r '.toplevels[] | select(.identifier != null) | "\(.title) [\(."app-id")]" | gsub("[\n\r\t]"; " ")' <<<"$windows" |
		fuzzel --dmenu --index --prompt 'Capture window: ' --cache /dev/null); then
		exit 0
	fi
	[[ "$selected_index" =~ ^[0-9]+$ ]] || exit 0
	identifier=$(jq -r --argjson index "$selected_index" '[.toplevels[] | select(.identifier != null)][$index].identifier // empty' <<<"$windows")
	[[ -n "$identifier" ]] || exit 0
	grim -T "$identifier" "$temporary_image"
	;;
*)
	printf 'Usage: screenshot.sh [-o|-w]\n' >&2
	exit 2
	;;
esac

if [[ -n "$freeze_pid" ]]; then
	kill "$freeze_pid" 2>/dev/null || true
	wait "$freeze_pid" 2>/dev/null || true
	freeze_pid=""
fi
"$script_home/util/image_action_menu.sh" "$temporary_image" "$prefix"
