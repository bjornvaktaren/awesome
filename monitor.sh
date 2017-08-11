#!/bin/bash
intern=$(xrandr | awk '/primary/ {print $1}')
extern=DP1
dp=DP1
hdmi=HDMI1
host=$(hostname)

case $host in
    (mmpem) extern=VGA1;;
    (w1c) extern=DP1;;
esac

echo "Internal display is ${intern}, external is ${extern}"

if [[ $# -eq 0 ]]; then
    if xrandr | grep "$extern disconnected"; then
	echo "Using ${extern} only"
	xrandr --output "$extern" --off --output "$intern" --auto
    else
	echo "Using ${intern} only"
	xrandr --output "$intern" --off --output "$extern" --auto
    fi
fi
if [[ $# -eq 2 ]]; then
    if [[ $1 == "dp" ]]; then
	if [[ $2 == "on" ]]; then
	    echo "Turning ${dp} on"
	    xrandr --output "$dp" --auto
	else
	    echo "Turning ${dp} off"
	    xrandr --output "$dp" --off
	fi
    fi
    if [[ $1 == "hmdi" ]]; then
	if [[ $2 == "on" ]]; then
	    echo "Turning ${hdmi} on"
	    xrandr --output "$hdmi" --auto
	else
	    echo "Turning ${hdmi} off"
	    xrandr --output "$hdmi" --off
	fi
    fi
    if [[ $1 == "intern" ]]; then
	if [[ $2 == "on" ]]; then
	    echo "Turning ${intern} on"
	    xrandr --output "$intern" --auto
	else
	    echo "Turning ${intern} on"
	    xrandr --output "$intern" --off
	fi
    fi
fi


