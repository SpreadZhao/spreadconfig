#!/usr/bin/env bash
set -euo pipefail

# Match hosts/desktop1/home/niri/files/host.kdl output layout.
wlr-randr --output HDMI-A-1 --scale 1 --pos 0,0 2>/dev/null || true
wlr-randr --output DP-2 --scale 1 --pos 3440,180 2>/dev/null || true
wlr-randr --output eDP-1 --scale 2 --pos 5360,500 2>/dev/null || true
