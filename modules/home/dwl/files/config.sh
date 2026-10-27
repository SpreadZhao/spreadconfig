#!/usr/bin/env bash
set -euo pipefail

config_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$config_dir/host.sh" ]]; then
    # shellcheck source=/dev/null
    source "$config_dir/host.sh"
fi

if [[ -f "$config_dir/common.sh" ]]; then
    # shellcheck source=/dev/null
    source "$config_dir/common.sh"
fi
