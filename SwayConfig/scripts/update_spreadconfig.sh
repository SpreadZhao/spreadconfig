#!/usr/bin/bash

CONFIG_DIR="$HOME/workspaces/spreadconfig/SwayConfig"

# pacman & aur
paru -Qqetn > "$CONFIG_DIR/package-list.txt"
paru -Qqem > "$CONFIG_DIR/package-list-aur.txt"

# scripts
cp -r ~/scripts "$CONFIG_DIR/"
