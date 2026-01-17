# replace utils
alias cat="bat"
alias df="duf"
alias du="dust"
alias cd="z"
# alias rm="rip -i"
alias rm="rm -Iv"

alias ls="eza --icons"
alias ll="eza -l --git --icons"
alias la="eza -la --git --icons"
alias l="eza -lah --git --icons"

# shortcut
alias n="nvim ."
alias lg="lazygit"
alias c="clear"

# quick action
alias wk="cd ~/workspaces"
alias sb="cd ~/workspaces/SecondBrain/"
alias st="cd ~/workspaces/SpreadStudy/"
alias lc="cd ~/workspaces/SpreadStudy/Leetcode/LeetcodeCpp/ && n"
alias shuffle="mpv --shuffle --force-window --autofit-smaller=800x500 ."
alias q="exit"
alias ca="mpv /dev/video0"
alias feh="feh --theme fit"
alias cdgvfs="cd /run/user/$(id -u)/gvfs"
alias se="sudo -E nvim"
alias sf="cd ~/workspaces/spreadconfig && n"

# safe
alias mv="mv -iv"
alias cp="cp -iv"
alias mkdir="mkdir -v"
