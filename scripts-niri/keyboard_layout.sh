#!/bin/bash

current=$(hyprctl devices | awk '/active keymap/ {layout=$NF} /main: yes/ {print layout; exit}')

# Уведомление
if [ "$current" == "Russian" ]; then
    #dunstify -u low --replace=70 "Language: ru"
    output='ru'
    #if [ "$capslock_state" == "off" ]; then
    #    dunstify -u low --replace=70 "Language: ru"
    #else
    #    dunstify -u low --replace=70 "Language: RU"
    #fi
elif [ "$current" == "(US)" ]; then 
    #dunstify -u low --replace=70 "Language: us"
    #if [ "$capslock_state" == "off" ]; then
    #    dunstify -u low --replace=70 "Language: us"
    #else
    #    dunstify -u low --replace=70 "Language: US"
    #fi
    output='us'
fi

echo $output
