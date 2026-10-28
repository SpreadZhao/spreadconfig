#!/usr/bin/env sh
# Run lf for xdg-desktop-portal-termfilechooser.
# See xdg-desktop-portal-termfilechooser(5) for the arguments.

set -e

if [ "$6" -ge 4 ]; then
	set -x
fi

directory="$2"
save="$3"
path="$4"
out="$5"

if [ "$save" = "1" ]; then
	filename=$(basename -- "$path")
	set -- env "FILE_CHOOSER_SAVE_FILE_NAME=$filename" lf \
		-selection-path "$out" "$(dirname -- "$path")"
elif [ "$directory" = "1" ]; then
	# Select a directory with lfrc's choose-dir command.
	set -- env "LF_SELECTED_DIR_PATH=$out" lf "$path"
else
	# lf handles both single and multiple file selections.
	set -- lf -selection-path "$out" "$path"
fi

exec footclient -a lick-foot -T 'Choose File' -- "$@"
