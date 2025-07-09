#!/usr/bin/env bash

# Проверяем, включен ли Bluetooth (аппаратно и через bluetoothctl)
is_powered_on() {
    # Вариант 1: через bluetoothctl (точнее)
    bluetoothctl show | grep -q "Powered: yes" && return 0 || return 1

    # Вариант 2: через rfkill (быстрее, но менее точно)
    # rfkill list bluetooth | grep -q "Soft blocked: no" && return 0 || return 1
}

# Проверяем, есть ли подключенные устройства
get_connected_device() {
    connected_info=$(bluetoothctl info)
    if echo "$connected_info" | grep -q "Connected: yes"; then
        echo "$connected_info" | grep "Name:" | cut -d' ' -f2-
    else
        echo ""
    fi
}

# Основная логика
main() {
    if is_powered_on; then
        connected_device=$(get_connected_device)
        if [[ -n "$connected_device" ]]; then
            echo "󰂱 $connected_device"  # Устройство подключено
        else
            echo "󰂯"  # Bluetooth включен, но нет подключений
        fi
    else
        echo "󰂲"  # Bluetooth выключен
    fi
}

main
