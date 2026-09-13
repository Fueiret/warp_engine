#!/bin/bash

ROFI_DIR="$HOME/.config/rofi/config.rasi"
ROFI_WALL_DIR="$HOME/.config/rofi/wallSelect.rasi"
WAYBAR_DIR="$HOME/.config/waybar/style.css"

clear_rofi() {
    echo "" > "$ROFI_DIR"
}

clear_rofi_wallpapers() {
    echo "" > "$ROFI_WALL_DIR"
}

clear_waybar() {
    echo "" > "$WAYBAR_DIR"
}

restart_waybar() {
    if ! pkill waybar; then
        notify-send "Error" "Could not terminate Waybar."
        exit 1
    fi

    waybar &
}

if [ ! -d "$HOME/.config/rofi" ]; then
    notify-send "Error: $HOME/.config/rofi does not exist"
    exit 1
fi

if [ ! -d "$HOME/.config/waybar" ]; then
    notify-send "Error: $HOME/.config/waybar does not exist"
    exit 1
fi


# ROFI THEMES
set_my_dark_rofi() {
    clear_rofi

    cat << EOF > "$ROFI_DIR"
/* THEME */
@theme "themes/catppuccin-dark.rasinc"

/* TEMPLATE */
@import "templates/my-template.rasi"
EOF

    cat << EOF > "$ROFI_WALL_DIR"
/* THEME */
@theme "themes/catppuccin-dark.rasinc"

/* TEMPLATE */
@import "templates/wall-selector.rasi"
EOF
    notify-send "Theme changed to my_dark"
}

set_my_light_rofi() {
    clear_rofi

    cat << EOF > "$ROFI_DIR"
/* THEME */
@theme "themes/catppuccin-light.rasinc"

/* TEMPLATE */
@import "templates/my-template.rasi"
EOF

    cat << EOF > "$ROFI_WALL_DIR"
/* THEME */
@theme "themes/catppuccin-light.rasinc"

/* TEMPLATE */
@import "templates/wall-selector.rasi"
EOF

    notify-send "Theme changed to my_light"
}

set_mono_dark_rofi() {
    clear_rofi

    cat << EOF > "$ROFI_DIR"
/* THEME */
@theme "themes/mono-dark.rasinc"

/* TEMPLATE */
@import "templates/my-template.rasi"
EOF

    cat << EOF > "$ROFI_WALL_DIR"
/* THEME */
@theme "themes/mono-dark.rasinc"

/* TEMPLATE */
@import "templates/wall-selector.rasi"
EOF

    notify-send "Theme changed to my_light"
}

set_mono_light_rofi() {
    clear_rofi

    cat << EOF > "$ROFI_DIR"
/* THEME */
@theme "themes/mono-light.rasinc"

/* TEMPLATE */
@import "templates/my-template.rasi"
EOF

    cat << EOF > "$ROFI_WALL_DIR"
/* THEME */
@theme "themes/mono-light.rasinc"

/* TEMPLATE */
@import "templates/wall-selector.rasi"
EOF

    notify-send "Theme changed to my_light"
}


# WAYBAR THEMES
set_my_dark_rounded_wb() {
    clear_waybar

    cat << EOF > "$WAYBAR_DIR"
/* THEME */
@import "themes/my-theme-dark.css";

/* TEMPLATE */
@import "templates/my-template-rounded.css";
EOF

    notify-send "Theme changed"
}

set_my_dark_united_wb() {
    clear_waybar

    cat << EOF > "$WAYBAR_DIR"
/* THEME */
@import "themes/my-theme-dark.css";

/* TEMPLATE */
@import "templates/my-template-united.css";
EOF

    notify-send "Theme changed"
}

set_mono_light_rounded_wb() {
    clear_waybar

    cat << EOF > "$WAYBAR_DIR"
/* THEME */
@import "themes/mono-light.css";

/* TEMPLATE */
@import "templates/my-template-rounded.css";
EOF

    notify-send "Theme changed"
}

set_mono_light_united_wb() {
    clear_waybar

    cat << EOF > "$WAYBAR_DIR"
/* THEME */
@import "themes/mono-light.css";

/* TEMPLATE */
@import "templates/my-template-united.css";
EOF

    notify-send "Theme changed"
}

set_mono_dark_rounded_wb() {
    clear_waybar

    cat << EOF > "$WAYBAR_DIR"
/* THEME */
@import "themes/mono-dark.css";

/* TEMPLATE */
@import "templates/my-template-rounded.css";
EOF

    notify-send "Theme changed"
}

set_mono_dark_united_wb() {
    clear_waybar

    cat << EOF > "$WAYBAR_DIR"
/* THEME */
@import "themes/mono-dark.css";

/* TEMPLATE */
@import "templates/my-template-united.css";
EOF

    notify-send "Theme changed"
}


SELECTED=$(printf "My dark (rounded)\nMy dark (united)\nMono dark (rounded)\nMono dark (united)\nMono light (rounded)\nMono light (united)" | rofi -dmenu -p "Theme")
if [ -z "$SELECTED" ]; then
  notify-send "Nothing selected"
  exit 1
fi 

case "$SELECTED" in
  "My dark (rounded)") set_my_dark_rofi; set_my_dark_rounded_wb ;;
  "My dark (united)") set_my_dark_rofi; set_my_dark_united_wb ;;
  "Mono dark (rounded)") set_mono_dark_rofi; set_mono_dark_rounded_wb ;;
  "Mono dark (united)") set_mono_dark_rofi; set_mono_dark_united_wb ;;
  "Mono light (rounded)") set_mono_light_rofi; set_mono_light_rounded_wb ;;
  "Mono light (united)") set_mono_light_rofi; set_mono_light_united_wb ;;
  *) notify-send "Invalid theme"; exit 1;;
esac

restart_waybar
