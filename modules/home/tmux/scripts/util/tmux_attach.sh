#!/usr/bin/env bash
set -euo pipefail

window_format='#{?window_active,*, } #{window_index}: #{window_name}#{?#{&&:#{!=:#{pane_title},},#{&&:#{!=:#{pane_title},#{host}},#{!=:#{pane_title},#{window_name}}}}, - #{pane_title},}'

if [[ "${1:-}" == "--preview" ]]; then
	session="${2:-}"
	[[ -n "$session" ]] || exit 0
	tmux list-windows -t "=$session" -F "$window_format" 2>/dev/null || true
	exit 0
fi

session_format=$'#{session_name}\t#{session_name}: #{?#{&&:#{!=:#{pane_title},},#{!=:#{pane_title},#{host}}},#{pane_title},#{window_name}}'
mapfile -t sessions < <(
	tmux list-sessions -f '#{==:#{session_attached},0}' -F "$session_format" 2>/dev/null || true
)

count=${#sessions[@]}
if ((count == 0)); then
	notify-send --app-name "tmux" "Tmux Attach" "No unattached tmux sessions."
	exit 0
fi

self=$(readlink -f -- "$0")
printf -v quoted_self '%q' "$self"
if ! selected=$(
	printf '%s\n' "${sessions[@]}" |
		fzf-popup --title "Tmux Attach ($count)" -- \
			--with-shell "$BASH -c" \
			--delimiter=$'\t' \
			--with-nth=2.. \
			--no-sort \
			--prompt="Sessions ($count)> " \
			--header="Unattached sessions: $count" \
			--preview="$quoted_self --preview {1}" \
			--preview-window='right,55%,wrap'
); then
	exit 0
fi

session="${selected%%$'\t'*}"
[[ -n "$session" ]] || exit 0
exec footclient tmux attach-session -t "=$session"
