#!/usr/bin/bash
pkill -9 waybar
sleep 1
niri msg action spawn -- waybar
