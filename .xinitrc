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
# fix "n/a" error
sleep 5 && slstatus &
dunst &
export _JAVA_AWT_WM_NONREPARENTING=1
export AWT_TOOLKIT=MToolkit
wmname LG3D

# touchpad
TOUCHPAD_ID=$(xinput list | grep Touchpad | grep -oP 'id=\K\d+')
xinput set-prop $TOUCHPAD_ID "libinput Tapping Enabled" 1
xinput set-prop $TOUCHPAD_ID "libinput Natural Scrolling Enabled" 1
xinput set-prop $TOUCHPAD_ID "libinput Accel Speed" 0.4


export SDWM=$HOME/SpreadBash
exec dwm
