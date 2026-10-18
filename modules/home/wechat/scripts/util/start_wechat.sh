#!/usr/bin/env bash

# Select WeChat's text-input-v3 plugin so niri positions the IME popup.
# With QT_IM_MODULE=fcitx, WeChat 4.1.13+ exposes the candidate window as a
# regular toplevel; niri tiles and focuses it, interrupting input.
exec env QT_IM_MODULE="text-input-unstable-v3" wechat "$@"
