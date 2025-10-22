#!/bin/bash

export EDITOR=nvim
export VISUAL=nvim

# export XDG_SESSION_DESKTOP="sway"
# if [ "$XDG_SESSION_DESKTOP" = "sway" ]; then
#     # https://github.com/swaywm/sway/issues/595
#     export _JAVA_AWT_WM_NONREPARENTING=1
# fi
# export _JAVA_AWT_WM_NONREPARENTING=1

# PATH
append_path() {
    for p in "$@"; do
        p="${p%/}"
        if [ -d "$p" ] && [[ ":$PATH:" != *":$p:"* ]]; then
            PATH="$PATH:$p"
        fi
    done
}

PATH_HOME=(
    "$HOME/scripts"
    "$HOME/.local/bin"
)

append_path "${PATH_HOME[@]}"

export PATH
