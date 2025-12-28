#!/usr/bin/bash
USAGE=$(rocm-smi --json -a 2>/dev/null | grep -o '{.*}' | tail -n 1 | jq -r '.card0["GPU use (%)"]')
printf "%.f󰊗\n" "$USAGE"
