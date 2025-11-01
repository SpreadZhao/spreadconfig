#!/bin/bash

# alias

# replace utils
alias cat="bat"
alias df="duf"
alias du="dust"
alias cd="z"
# alias rm="rip -i"

alias ls="eza --icons"
alias ll="eza -l --git --icons"
alias la="eza -la --git --icons"
alias l="eza -lah --git --icons"

# shortcut
alias n="nvim ."
alias lg="lazygit"
alias lgc="serie"
alias tt="tray-tui"
# alias t="tmux"
alias c="clear"

# quick action
alias wk="cd ~/workspaces"
alias nh="cd ~/workspaces/notes_homeworks"
alias st="cd ~/workspaces/SpreadStudy/"
alias lc="cd ~/workspaces/SpreadStudy/Leetcode/LeetcodeCpp/ && n"
alias f="~/scripts/foot_new_tab.sh"

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
