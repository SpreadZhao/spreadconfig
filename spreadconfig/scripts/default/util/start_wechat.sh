#!/usr/bin/env bash

# WeChat bundles text-input-v3 as a standalone Qt5 input-context plugin
# (NOT the default), so QT_IM_MODULE must name it explicitly. This routes
# IME through the compositor's text-input-v3 protocol (niri -> fcitx5);
# the candidate window is a compositor-managed IM popup: positioned at the
# cursor, never tiled, never steals focus.
#
# Do NOT use QT_IM_MODULE=fcitx on Wayland: WeChat's embedded fcitx-qt5
# (DBus) makes fcitx5 show the candidate as a regular toplevel, which
# niri tiles and focuses, breaking Chinese input (WeChat >= 4.1.13).
# Forcing xcb/XWayland also works but loses native Wayland scaling.
exec env QT_IM_MODULE="text-input-unstable-v3" wechat "$@"
