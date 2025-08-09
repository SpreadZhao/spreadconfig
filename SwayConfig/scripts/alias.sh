#!/bin/bash

# alias
alias cat="bat"
alias df="duf"
alias du="gdu"
alias n="nvim ."
alias wk="cd ~/workspaces"
alias nh="cd ~/workspaces/obsidianws/notes_homeworks"
alias st="cd ~/workspaces/SpreadStudy/"
alias lg="lazygit"
alias ls="eza --icons"
alias ll="eza -l --git --icons"
alias la="eza -la --git --icons"
alias l="eza -lah --git --icons"
alias tt="tray-tui"
alias lc="cd ~/workspaces/SpreadStudy/Leetcode/LeetcodeCpp/ && n"

alias mv="mv -iv"
alias cp="cp -iv"
alias mkdir="mkdir -v"


# functions
cdgvfs() {
    source ~/scripts/cd_gvfs_webdav.sh
}
