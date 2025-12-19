#!/bin/bash

export EDITOR=nvim
export VISUAL=nvim

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
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
)

append_path "${PATH_HOME[@]}"

export PATH
