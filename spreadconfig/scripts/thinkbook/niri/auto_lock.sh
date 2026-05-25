#!/usr/bin/env bash

swayidle -w timeout 600 'niri msg action power-off-monitors' timeout 605 'swaylock' before-sleep 'swaylock'
