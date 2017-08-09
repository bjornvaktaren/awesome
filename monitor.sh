#!/bin/bash
intern=eDP1
dp=DP1
hdmi=HDMI1

if [[ $# -eq 0 ]]; then
    if xrandr | grep "$dp disconnected"; then
	xrandr --output "$dp" --off --output "$intern" --auto
    else
	xrandr --output "$intern" --off --output "$dp" --auto
    fi
fi
if [[ $# -eq 2 ]]; then
    if [[ $1 == "dp" ]]; then
	if [[ $2 == "on" ]]; then
	    xrandr --output "$dp" --auto
	else
	    xrandr --output "$dp" --off
	fi
    fi
    if [[ $1 == "hmdi" ]]; then
	if [[ $2 == "on" ]]; then
	    xrandr --output "$hdmi" --auto
	else
	    xrandr --output "$hdmi" --off
	fi
    fi
    if [[ $1 == "laptop" ]]; then
	if [[ $2 == "on" ]]; then
	    xrandr --output "$intern" --auto
	else
	    xrandr --output "$intern" --off
	fi
    fi
fi


