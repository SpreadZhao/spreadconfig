#!/usr/bin/env bash
set -euo pipefail

wlopm --off '*' >/dev/null 2>&1 || true
exec swaylock
