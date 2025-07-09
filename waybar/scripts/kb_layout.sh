#!/bin/bash

layout=$(hyprctl devices | grep "active keymap" | awk '{print $4}')
caps=$(xset q | grep "Caps Lock" | awk '{print $4}')

if [ "$caps" = "on" ]; then
    echo "$layout 🔒"
else
    echo "$layout"
fi
