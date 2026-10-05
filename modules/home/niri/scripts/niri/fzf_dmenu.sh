#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
printf -v preview '%q' "$script_dir/fzf_dmenu_preview.sh"
exec fzf-popup --title 'Clipboard history' -- --with-shell "$BASH -c" --preview "$preview {}" "$@"
