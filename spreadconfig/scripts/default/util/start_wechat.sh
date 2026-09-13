#!/usr/bin/env bash

# Force XWayland: WeChat >= 4.1.13 under native Wayland uses its embedded
# fcitx-qt5 (DBus), whose candidate window shows up as a regular toplevel
# that tiling compositors (niri) tile/steal focus from, breaking Chinese
# input. Override-redirect X11 candidate windows via xwayland-satellite
# work fine.
exec env QT_QPA_PLATFORM="xcb" WAYLAND_DISPLAY= QT_IM_MODULE="fcitx" XMODIFIERS="@im=fcitx" wechat "$@"
