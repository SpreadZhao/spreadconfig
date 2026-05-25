#!/usr/bin/env bash

SERVICE="wbg.service"

if systemctl --user is-active --quiet "$SERVICE"; then
    echo "$SERVICE is running, stopping it..."
    systemctl --user stop "$SERVICE"
else
    echo "$SERVICE is not running, starting it..."
    systemctl --user start "$SERVICE"
fi
