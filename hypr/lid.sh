#!/bin/bash

if [ -z "$1" ]; then
  if grep -q "open" /proc/acpi/button/lid/LID0/state; then
    LID_STATUS="open"
  else
    LID_STATUS="close"
  fi
else
  LID_STATUS="$1"
fi

if hyprctl monitors | grep -q "DP-7" || hyprctl monitors | grep -q "DP-6"; then
  if [[ $LID_STATUS == "open" ]]; then
    hyprctl keyword monitor "eDP-1,preferred,auto,1.333"
  else
    hyprctl keyword monitor "eDP-1,disable"
  fi
else
  if [[ $LID_STATUS == "close" ]]; then
    systemctl suspend
  fi
fi
