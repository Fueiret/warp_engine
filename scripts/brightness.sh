#!/usr/bin/env bash

BACKLIGHT_DIR="/sys/class/backlight/amdgpu_bl1"
BRIGHTNESS_FILE="$BACKLIGHT_DIR/brightness"
MAX_BRIGHTNESS_FILE="$BACKLIGHT_DIR/max_brightness"

# Проверяем, что директория существует
# if [ ! -d "$BACKLIGHT_DIR" ]; then
#     echo "Backlight interface not found"
#     exit 1
#fi

# Читаем текущую и максимальную яркость
current_brightness=$(cat "$BRIGHTNESS_FILE")
max_brightness=$(cat "$MAX_BRIGHTNESS_FILE")

# Функция для вывода яркости в процентах
print_brightness() {
    percent=$(( 100 * current_brightness / max_brightness ))
    echo "$percent%"
}

# Функция для установки яркости (значение в абсолютных единицах)
set_brightness() {
    local new_brightness=$1
    if (( new_brightness < 0 )); then
        new_brightness=0
    elif (( new_brightness > max_brightness )); then
        new_brightness=$max_brightness
    fi
    # Записываем новое значение (нужны права)
    echo "$new_brightness" | sudo tee "$BRIGHTNESS_FILE" > /dev/null
}

# Увеличить яркость на 5%
increase_brightness() {
    # step=$(( max_brightness / 20 ))  # 5% от max
    # set_brightness $new_brightness
    brightnessctl set +16
    brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    current_brightness=$(( brightness * 100 / max_brightness))
    dunstify -u low --replace=69 -h "int:value:$current_brightness" "Brightness: $current_brightness%"
}

# Уменьшить яркость на 5%
decrease_brightness() {
    # step=$(( max_brightness / 20 ))  # 5% от max
    #new_brightness=$(( current_brightness - step ))
    # set_brightness $new_brightness
    brightnessctl set 16-
    brightness=$(brightnessctl get)
    max_brightness=$(brightnessctl max)
    current_brightness=$(( brightness * 100 / max_brightness))
    dunstify -u low --replace=69 -h "int:value:$current_brightness" "Brightness: $current_brightness%"
}

# Основная логика
if [[ "$1" == "--get" ]]; then
        print_brightness
elif [[ "$1" == "--up" ]]; then
        increase_brightness
elif [[ "$1" == "--down" ]]; then
        decrease_brightness
else
        print_brightness
fi
