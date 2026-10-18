#!/usr/bin/env bash

# Handle org.freedesktop.FileManager1 requests with one lf window per URI.
# https://www.freedesktop.org/wiki/Specifications/file-manager-interface/

BDUS_METHOD="$1"
shift 1

quote_string() {
	local input="$1"
	echo "'${input//\'/\'\\\'\'}'"
}

cmd="lf"
termcmd="footclient -a lf -T '$1'"
case "$BDUS_METHOD" in
"ShowFolders" | "ShowItems" | "ShowItemProperties")
	for file in "$@"; do
		decoded_arg=$(printf '%b' "${file//%/\\x}")
		eval "$termcmd -- $cmd $(quote_string "$decoded_arg")" &
		disown
	done
	;;
esac
