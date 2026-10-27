#!/usr/bin/env bash
set -euo pipefail

# Match hosts/zephyrus-m16/home/niri/files/host.kdl output layout.
wlr-randr --output HDMI-A-1 --mode 3440x1440@100.000 --scale 1.25 --pos 0,0 2>/dev/null || true
wlr-randr --output DP-1 --scale 1.25 --pos 2752,180 2>/dev/null || true
wlr-randr --output eDP-1 --scale 2 --pos 4288,500 --off 2>/dev/null || true
