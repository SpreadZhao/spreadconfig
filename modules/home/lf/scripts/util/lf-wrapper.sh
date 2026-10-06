#!/usr/bin/env sh
# This wrapper script is invoked by xdg-desktop-portal-termfilechooser.
#
# For more information about input/output arguments read `xdg-desktop-portal-termfilechooser(5)`

set -e

if [ "$6" -ge 4 ]; then
	set -x
fi

directory="$2"
save="$3"
path="$4"
out="$5"

cmd="lf"
termcmd="footclient -a lick-foot -T 'Choose File'"

if [ "$save" = "1" ]; then
	# save a file
	filename=$(basename -- "$path")
	cmd="env FILE_CHOOSER_SAVE_FILE_NAME=\"$filename\" $cmd"
	set -- -selection-path "$out" "$path"
elif [ "$directory" = "1" ]; then
	# select a directory explicitly with lfrc's choose-dir command
	cmd="env LF_SELECTED_DIR_PATH=\"$out\" $cmd"
	set -- "$path"
else
	# select files; lf handles both single and multiple selections
	set -- -selection-path "$out" "$path"
fi

command="$termcmd $cmd"
for arg in "$@"; do
	# escape double quotes
	escaped=$(printf "%s" "$arg" | sed 's/"/\\"/g')
	# escape special
	command="$command \"$escaped\""
done

sh -c "$command"
