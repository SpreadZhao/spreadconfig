#!/usr/bin/env bash
set -euo pipefail

unit_name="swayidle.service"

systemctl --user start "$unit_name"
swaylock -f
# Reduce wakeups caused by releasing the shortcut.
sleep 0.5
exec systemctl --user kill --kill-whom=main --signal=SIGUSR1 "$unit_name"
