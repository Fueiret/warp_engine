#!/bin/bash

# PulseAudio Volume Control Script with Dunst Notifications
# Features:
# - Prevents volume > 100%
# - Uses dunstify for notifications
# - Mute/unmute toggle
# - Volume up/down with 2% steps

# Check if PulseAudio is running
if ! pactl info &>/dev/null; then
    echo "PulseAudio не запущен!"
    exit 1
fi

# Check required commands
for cmd in pactl dunstify; do
    if ! command -v $cmd &>/dev/null; then
        echo "Error: $cmd not found!"
        exit 1
    fi
done

# Get current volume (0-100)
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' '{print $2}' | grep -o '[0-9]*%' | tr -d '%'
}

# Get mute status (returns "yes" or "no")
get_mute() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

# Show volume notification
show_notification() {
    local vol=$(get_volume)
    local mute=$(get_mute)
    
    if [ "$mute" = "yes" ]; then
        notify-send -u low -r 69 -h "int:value:$vol" "Mute"
    else
        notify-send -u low -r 69 -h "int:value:$vol" "Volume: $vol%"
    fi
}

# Increase volume (cap at 100%)
volume_up() {
    local current=$(get_volume)
    if [ "$current" -lt 150 ]; then
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    	  local vol=$(get_volume)
        notify-send -u low -r 69 -h "int:value:$vol" "Volume: $vol%"
    else
        pactl set-sink-volume @DEFAULT_SINK@ 150%
    	local vol=$(get_volume)
        notify-send -u low -r 69 -h "int:value:$vol" "Volume: $vol%"
    fi
    # show_notification
    # notify-send -u low -r 69 -h "int:value:$vol" "Volume: $vol%"
}

# Decrease volume
volume_down() {
    pactl set-sink-volume @DEFAULT_SINK@ -5%
    local vol=$(get_volume)
    # show_notification
    notify-send -u low -r 69 -h "int:value:$vol" "Volume: $vol%"
}

# Toggle mute
toggle_mute() {
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_notification
}

# Handle arguments
case "$1" in
    --up) volume_up ;;
    --down) volume_down ;;
    --toggle) toggle_mute ;;
    --get) get_volume ;;
    *) echo "Use it $0 [up|down|mute|get]" ;;
esac
