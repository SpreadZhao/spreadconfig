#!/bin/bash

# alias

# replace utils
alias cat="bat"
alias df="duf"
alias du="gdu"
alias fzf='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'
# alias rm="rip -i"

alias ls="eza --icons"
alias ll="eza -l --git --icons"
alias la="eza -la --git --icons"
alias l="eza -lah --git --icons"

# shortcut
alias n="nvim ."
alias lg="lazygit"
alias tt="tray-tui"
alias t="tmux"

# quick action
alias wk="cd ~/workspaces"
alias nh="cd ~/workspaces/obsidianws/notes_homeworks"
alias st="cd ~/workspaces/SpreadStudy/"
alias lc="cd ~/workspaces/SpreadStudy/Leetcode/LeetcodeCpp/ && n"

alias shuffle="mpv --shuffle --force-window --autofit-smaller=800x500 ."

alias q="exit"

alias ca="mpv /dev/video0"

# safe
alias mv="mv -iv"
alias cp="cp -iv"
alias mkdir="mkdir -v"

# functions
cdgvfs() {
    source ~/scripts/cd_gvfs_webdav.sh
}
