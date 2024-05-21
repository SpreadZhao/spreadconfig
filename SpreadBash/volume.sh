#! /bin/bash

case $1 in
    up) target="5%+" ;;
    down) target="5%-" ;;
    mute)
	    amixer -q set Master toggle
	    exit
	    ;;
esac

amixer -q set Master $target unmute
# $SDWM/update-status-bar.sh
