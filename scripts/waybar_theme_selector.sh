#!/usr/bin/env bash

CONF_DIR="$HOME/.config/waybar/style.css"

clear_config() {
    echo "" > "$CONF_DIR"
}

set_my_dark_rounded() {
    clear_config

    cat << EOF > "$CONF_DIR"
/* THEME */
@import "themes/my-theme-dark.css";

/* TEMPLATE */
@import "templates/my-template-rounded.css";
EOF

    notify-send "Theme changed"
}

set_my_dark_united() {
    clear_config

    cat << EOF > "$CONF_DIR"
/* THEME */
@import "themes/my-theme-dark.css";

/* TEMPLATE */
@import "templates/my-template-united.css";
EOF

    notify-send "Theme changed"
}

set_black_white_rounded() {
    clear_config

    cat << EOF > "$CONF_DIR"
/* THEME */
@import "themes/mono-light.css";

/* TEMPLATE */
@import "templates/my-template-rounded.css";
EOF

    notify-send "Theme changed"
}

set_black_white_united() {
    clear_config

    cat << EOF > "$CONF_DIR"
/* THEME */
@import "themes/mono-light.css";

/* TEMPLATE */
@import "templates/my-template-united.css";
EOF

    notify-send "Theme changed"
}

set_white_black_rounded() {
    clear_config

    cat << EOF > "$CONF_DIR"
/* THEME */
@import "themes/mono-dark.css";

/* TEMPLATE */
@import "templates/my-template-rounded.css";
EOF

    notify-send "Theme changed"
}

set_white_black_united() {
    clear_config

    cat << EOF > "$CONF_DIR"
/* THEME */
@import "themes/mono-dark.css";

/* TEMPLATE */
@import "templates/my-template-united.css";
EOF

    notify-send "Theme changed"
}

if [ ! -d "$HOME/.config/waybar" ]; then
    notify-send "Error: $HOME/.config/waybar does not exist"
    exit 1
fi


SELECTED=$(printf "my theme dark rounded\nmy theme dark united\nblack on white rounded\nblack on white united\nwhite on black rounded\nwhite on black united\n" | rofi -dmenu -p "Waybar")
if [ -z "$SELECTED" ]; then
  notify-send "Nothing selected"
  exit 1
fi 

case "$SELECTED" in
  "my theme dark rounded") set_my_dark_rounded ;;
  "my theme dark united") set_my_dark_united ;;
  "black on white rounded") set_black_white_rounded ;;
  "black on white united") set_black_white_united ;;
  "white on black rounded") set_white_black_rounded ;;
  "white on black united") set_white_black_united ;;
  *) notify-send "Invalid theme"; exit 1;;
esac

if ! pkill waybar; then
    notify-send "Error" "Could not terminate Waybar."
    exit 1
fi

waybar &
# if ! waybar &>/dev/null &; then
#     notify-send "Error" "Could not start Waybar."
#     exit 1
# fi
