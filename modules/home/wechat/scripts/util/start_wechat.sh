#!/usr/bin/env bash

# Use text-input-v3 to position the IME popup through the compositor.
exec env QT_IM_MODULE="text-input-unstable-v3" wechat "$@"
