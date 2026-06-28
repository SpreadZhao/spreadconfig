#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: run_python_helper.sh HELPER.py [ARGS...]

Run a leetcode-coach Python helper from this skill's scripts directory.
Uses python3 from PATH when available, otherwise falls back to nixpkgs#python3.
EOF
}

if (($# < 1)); then
  usage
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
helper="$1"
shift

case "$helper" in
  */*) helper_path="$helper" ;;
  *) helper_path="$script_dir/$helper" ;;
esac

if [[ ! -f "$helper_path" ]]; then
  echo "run_python_helper.sh: helper not found: $helper_path" >&2
  exit 2
fi

if command -v python3 >/dev/null 2>&1; then
  exec python3 "$helper_path" "$@"
fi

exec nix shell nixpkgs#python3 --command python3 "$helper_path" "$@"
