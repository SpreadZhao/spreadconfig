#!/usr/bin/zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# enable vim mode in zsh
bindkey -v

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/spreadzhao/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


eval "$(starship init zsh)"

source ~/scripts/enable_zsh_plugins.zsh
source ~/scripts/zsh_completion.zsh

# add after compinit
eval "$(zoxide init zsh)"
