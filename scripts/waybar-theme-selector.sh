#!/bin/bash


THEME_DIR="$HOME/.config/waybar/themes"
TEMPLATE_DIR="$HOME/.config/waybar/templates"

THEME_FILE="$HOME/.config/waybar/theme.css"
TEMPLATE_FILE="$HOME/.config/waybar/template.css"

CONFIG_FILE="$HOME/.config/waybar/config.jsonc"

SELECTOR_CONF="$HOME/.config/rofi/theme-selector.rasi"


if [[ ! -d "$THEME_DIR" ]]; then
    echo "($THEME_DIR) not found!"
    exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "($TEMPLATE_DIR) not found!"
    exit 1
fi


THEMES=($(ls "$THEME_DIR"/*.css | xargs -n 1 basename | sed 's/\.css$//'))
TEMPLATES=($(ls "$TEMPLATE_DIR"/*.css | xargs -n 1 basename | sed 's/\.css$//'))


show_menu() {
    local prompt="Waybar settings"
    local options=("Themes" "Templates")
    local selected_category=$(echo -e "${options[@]}" | tr ' ' '\n' | rofi -dmenu -p "$prompt" -config $SELECTOR_CONF)

    case "$selected_category" in
        "Themes")
            echo -e "${THEMES[@]}" | tr ' ' '\n' | rofi -dmenu -p "Choose theme" -config $SELECTOR_CONF
            ;;
        "Templates")
            echo -e "${TEMPLATES[@]}" | tr ' ' '\n' | rofi -dmenu -p "Choose templates" -config $SELECTOR_CONF
            ;;
        *)
            echo ""
            ;;
    esac
}

restart_waybar() {
    if ! pkill waybar; then
        notify-send "Error" "Could not terminate Waybar."
        exit 1
    fi

    waybar &
}


apply_theme() {
    local theme="$1"

    if [[ -f "$THEME_DIR/$theme.css" ]]; then
        echo "" > "$THEME_FILE"

        cat << EOF > "$THEME_FILE"
/* THEME PATH */
@import "themes/$theme.css";
EOF

        notify-send "Waybar Theme Switcher" "Theme: '$theme'"
    else 
        echo "Theme $theme not found"
        exit 1
    fi
}

apply_template() {
    local template="$1"

    if [[ -f "$TEMPLATE_DIR/$template.css" ]]; then
        echo "" > "$TEMPLATE_FILE"

        cat << EOF > "$TEMPLATE_FILE"
/* TEMPLATE PATH */ 
@import "templates/$template.css";
EOF

        cp "$TEMPLATE_DIR/$template.jsonc" "$CONFIG_FILE"

        notify-send "Waybar Theme Switcher" "Template: '$template'"
    else 
        echo "Template $template not found"
        exit 1
    fi
}


main() {
    selected=$(show_menu)

    
    if [[ -z "$selected" ]]; then
        echo "Nothing selected"
        exit 1
    fi

    
    if [[ " ${THEMES[*]} " =~ " $selected " ]]; then
        apply_theme "$selected"
    elif [[ " ${TEMPLATES[*]} " =~ " $selected " ]]; then
        apply_template "$selected"
    else
        echo "Wrong!"
        exit 1
    fi
}

main

restart_waybar

exit 0
