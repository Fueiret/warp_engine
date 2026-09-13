#!/bin/bash

WALL_DIR="${HOME}/Wallpapers"
CACHE_DIR="${HOME}/.cache/niri/wallpapers"
ROFI_COMMAND="rofi -dmenu -theme ${HOME}/.config/rofi/wallSelect.rasi"

mkdir -p "${CACHE_DIR}"

for imagen in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
    if [ -f "$imagen" ]; then
        nombre_archivo=$(basename "$imagen")
        if [ ! -f "${CACHE_DIR}/${nombre_archivo}" ]; then
            magick "$imagen" -thumbnail 300x300^ -gravity center -extent 300x300 "${CACHE_DIR}/${nombre_archivo}"
        fi
    fi
done

# Выбор обоев через Rofi
SELECTED=$(find "${WALL_DIR}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A; do
    echo -en "$A\x00icon\x1f${CACHE_DIR}/${A}\n"
done | $ROFI_COMMAND -p "Выберите обои")

# Путь к выбранному файлу
SELECTED_WALLPAPER="$WALL_DIR/$SELECTED"

if [ ! -f "$SELECTED_WALLPAPER" ]; then
    exit 1
fi

awww img "$SELECTED_WALLPAPER" --transition-type outer --transition-pos 0.8,0.2 --transition-duration 2.0

notify-send "Reload Wallpapers" "Successfully updated: $SELECTED"
