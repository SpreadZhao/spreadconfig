#!/usr/bin/env bash

exec env QT_IM_MODULE="fcitx" XMODIFIERS="@im=fcitx" wechat "$@"
