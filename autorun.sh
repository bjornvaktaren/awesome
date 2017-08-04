#!/usr/bin/env bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

run setxkbmap -layout "us,se" -option "ctrl:nocaps" -option "grp:rctrl_rshift_toggle" -option "numpad:mac"
run cernbox
run nm-applet
