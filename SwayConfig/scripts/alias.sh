#!/bin/bash

# alias

# utils
alias cat="bat"
alias df="duf"
alias du="gdu"
alias rm="rip -i"

alias ls="eza --icons"
alias ll="eza -l --git --icons"
alias la="eza -la --git --icons"
alias l="eza -lah --git --icons"

# shortcut
alias n="nvim ."
alias lg="lazygit"
alias tt="tray-tui"

# quick cd
alias wk="cd ~/workspaces"
alias nh="cd ~/workspaces/obsidianws/notes_homeworks"
alias st="cd ~/workspaces/SpreadStudy/"
alias lc="cd ~/workspaces/SpreadStudy/Leetcode/LeetcodeCpp/ && n"

# safe
alias mv="mv -iv"
alias cp="cp -iv"
alias mkdir="mkdir -v"

# functions
cdgvfs() {
    source ~/scripts/cd_gvfs_webdav.sh
}
