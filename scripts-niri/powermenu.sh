#!/bin/env bash

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | rofi -dmenu)
case "$choice" in
  Lock) sh /bin/screen-lock ;;
  Logout) pkill -KILL -u "$USER" ;;
  Suspend) systemctl suspend && sh /bin/screen-lock ;;
  Reboot) systemctl reboot ;;
  Shutdown) systemctl poweroff ;;
esac
