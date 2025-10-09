#!/usr/bin/zsh

eval "$(starship init zsh)"

source ~/scripts/enable_zsh_plugins.zsh
source ~/scripts/zsh_completion.zsh

# add after compinit
eval "$(zoxide init zsh)"
