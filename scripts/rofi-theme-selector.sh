#!/bin/bash


THEME_DIR="$HOME/.config/rofi/themes"
TEMPLATE_DIR="$HOME/.config/rofi/templates"

THEME_FILE="$HOME/.config/rofi/theme.rasi"
TEMPLATE_FILE="$HOME/.config/rofi/template.rasi"

SELECTOR_CONF="$HOME/.config/rofi/theme-selector.rasi"


if [[ ! -d "$THEME_DIR" ]]; then
    echo "($THEME_DIR) not found!"
    exit 1
fi

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "($TEMPLATE_DIR) not found!"
    exit 1
fi


THEMES=($(ls "$THEME_DIR"/*.rasi | xargs -n 1 basename | sed 's/\.rasi$//'))
TEMPLATES=($(ls "$TEMPLATE_DIR"/*.rasi | xargs -n 1 basename | sed 's/\.rasi$//'))


show_menu() {
    local prompt="Rofi settings"
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


apply_theme() {
    local theme="$1"

    if [[ -f "$THEME_DIR/$theme.rasi" ]]; then
        echo "" > "$THEME_FILE"

        cat << EOF > "$THEME_FILE"
/* THEME PATH */ 
@import "themes/$theme.rasi"
EOF

        notify-send "Rofi Theme Switcher" "Theme: '$theme'"
    else 
        echo "Theme $theme not found"
        exit 1
    fi
}

apply_template() {
    local template="$1"

    if [[ -f "$TEMPLATE_DIR/$template.rasi" ]]; then
        echo "" > "$TEMPLATE_FILE"

        cat << EOF > "$TEMPLATE_FILE"
/* TEMPLATE PATH */ 
@import "templates/$template.rasi"
EOF

        notify-send "Rofi Theme Switcher" "Template: '$template'"
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

exit 0
