#!/usr/bin/env sh
set -eu

script_home="${SCRIPT_HOME:-$HOME/scripts}"

exec "$script_home/config/preview_file.sh" "$1" "$2" "$3"
