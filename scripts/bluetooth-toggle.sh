# #!/bin/bash

# # Если вызван с аргументом "list", выводим список устройств
# if [ "$1" = "list" ]; then
#     # Получаем список известных устройств с их статусом подключения
#     bluetoothctl devices | while read -r line; do
#         mac=$(echo "$line" | awk '{print $2}')
#         alias=$(echo "$line" | cut -d ' ' -f 3-)
#         connected=$(bluetoothctl info "$mac" | grep "Connected:" | awk '{print $2}')
#         echo "$alias - $( [ "$connected" = "yes" ] && echo "Connected" || echo "Disconnected" )"
#     done
#     exit 0

# # Иначе выводим статус Bluetooth (вкл/выкл# )
# status=$(bluetoothctl show | grep "Powere# d:" | awk '{print $2}')
# if [ "$status" = "yes" ]; t# hen
#     echo " # ON"
# else
#     echo " OFF"
# fi

#!/usr/bin/env bash

# Проверяем, запущен ли NetworkManager
bluetooth_status=$(ps aux | grep bluetoothd | grep -v grep)

# Если служба не запущена
if [ "$bluetooth_status" = "" ]; then
    # TODO: Hide password entry
    rofi -dmenu -p "Root Password: " | sudo -S systemctl start bluetooth
fi

# Получаем список устройств
notify-send "Scanning for Bluetooth devices..."
device_list=$(bluetoothctl devices | awk '{print $3 " " substr($0, index($0,$2))}')

# Проверяем статус Bluetooth
bt_powered=$(bluetoothctl show | grep "Powered: yes")
if [[ -n "$bt_powered" ]]; then
    toggle="󰂲  Disable Bluetooth"
else
    toggle="󰂯  Enable Bluetooth"
fi

# Добавляем пункт для сканирования
scan_option="󰑬  Scan for devices"

chosen_device=$(echo -e "$toggle\n$scan_option\n$device_list" | rofi -dmenu -i -selected-row 1 -p "Bluetooth: ")
chosen_id=$(echo "$chosen_device" | awk '{print $1}')

if [ "$chosen_device" = "" ]; then
    exit
elif [ "$chosen_device" = "󰂯  Enable Bluetooth" ]; then
    bluetoothctl power on
    notify-send "Bluetooth Enabled"
elif [ "$chosen_device" = "󰂲  Disable Bluetooth" ]; then
    bluetoothctl power off
    notify-send "Bluetooth Disabled"
elif [ "$chosen_device" = "󰑬  Scan for devices" ]; then
    bluetoothctl scan on &
    sleep 5
    bluetoothctl scan off
    notify-send "Bluetooth scan completed"
else
    # Проверяем, подключено ли уже устройство
    connected=$(bluetoothctl info "$chosen_id" | grep "Connected: yes")
    if [[ -n "$connected" ]]; then
        bluetoothctl disconnect "$chosen_id"
        notify-send "Disconnected from $chosen_device"
    else
        bluetoothctl connect "$chosen_id" | grep -q "Connection successful" && \
        notify-send "Bluetooth Connected" "Successfully connected to $chosen_device"
    fi
fi
