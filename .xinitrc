#!/bin/bash
# Taken from:
#	https://raw.github.com/kaihendry/Kai-s--HOME/master/.xinitrc
#

xrdb -merge $HOME/.Xresources

#while true
#do
#	~/SpreadBash/update-status-bar.sh
#	sleep 20s
#done &

fcitx5 &
# xmodmap ~/.Xmodmap
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
flameshot &
slstatus &

export SDWM=$HOME/SpreadBash
exec dwm
