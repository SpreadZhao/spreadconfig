#!/usr/bin/env bash
set -euo pipefail

swaylock -f
dpms-off
exec dwl-display-restore
