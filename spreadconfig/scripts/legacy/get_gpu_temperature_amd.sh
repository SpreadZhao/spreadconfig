#!/usr/bin/bash
TEMPERATURE=$(rocm-smi --json -a 2>/dev/null | grep -o '{.*}' | tail -n 1 | jq -r '.card0["Temperature (Sensor edge) (C)"]')
printf "%.f󰊗\n" "$TEMPERATURE"
