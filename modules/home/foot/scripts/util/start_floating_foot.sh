#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
	notify-send \
		--urgency=critical \
		"Expected one command string; received $# arguments."
	exit 1
fi

exec footclient \
	-a "lick-foot" \
	-T "$1" \
	-- zsh -lc "$1"
