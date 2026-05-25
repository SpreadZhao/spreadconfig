#!/bin/bash

if which tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux
fi
