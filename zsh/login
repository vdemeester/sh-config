#!/bin/zsh

# Staring Xorg if we are on tty1
if [ -z "$DISPLAY" ] && [ $(tty) = /dev/tty1 ]; then
	while true
	do
		startx -- 2>&1 > ~/.xsession.log
		sleep 10
	done
fi 
