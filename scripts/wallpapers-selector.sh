#!/bin/bash

# Set some variables
WALL_DIR="${HOME}/Wallpapers"
CACHE_DIR="${HOME}/.cache/jp/${theme}"
ROFI_COMMAND="rofi -dmenu -theme ${HOME}/.config/rofi/wallSelect.rasi -theme-str ${ROFI_OVERRIDE}"

# Create cache dir if not exists
if [ ! -d "${CACHE_DIR}" ] ; then
        mkdir -p "${CACHE_DIR}"
    fi


MONITOR_SIZE=24
MONITOR_RES=$(hyprctl monitors |grep -A2 Monitor |head -n 2 |awk '{print $1}' | grep -oE '^[0-9]+')
DPI=$(echo "scale=2; $MONITOR_RES / $MONITOR_SIZE" | bc | xargs printf "%.0f")
MONITOR_RES=1 # $(( $MONITOR_RES * $MONITOR_SIZE / $DPI ))

ROFI_OVERRIDE="element-icon{size:${MONITOR_RES}px;border-radius:0px;}"

# Convert images in directory and save to cache dir
for imagen in "$WALL_DIR"/*.{jpg,jpeg,png,webp}; do
	if [ -f "$imagen" ]; then
		nombre_archivo=$(basename "$imagen")
		if [ ! -f "${CACHE_DIR}/${nombre_archivo}" ] ; then
			magick "$imagen" -thumbnail 500x500^ -gravity center -extent 500x500 "${CACHE_DIR}/${nombre_archivo}"
		fi
  fi
done

# Select a wallpaper with rofi
SELECTED=$(find "${WALL_DIR}"  -maxdepth 1  -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -exec basename {} \; | sort | while read -r A ; do  echo -en "$A\x00icon\x1f""${CACHE_DIR}"/"$A\n" ; done | $ROFI_COMMAND)


# The wallpaper path
SELECTED_WALLPAPER="$WALL_DIR/$SELECTED"

if [ ! -f "$SELECTED_WALLPAPER" ]; then
  notify-send "Error: Wallpaper not found"
  exit 1
fi

# Reload hyprpaper config
echo "" > "$HOME/.config/hypr/hyprpaper.conf"

cat << EOF > $HOME/.config/hypr/hyprpaper.conf
preload = $SELECTED_WALLPAPER
wallpaper = eDP-1, $SELECTED_WALLPAPER
wallpaper = HDMI-A-1, $SELECTED_WALLPAPER
splash = true
# offset.splash = 2.0
splash_color = 0xbbffffff
ipc = true
EOF

# reload hyprpaper
pkill hyprpaper 
hyprpaper

notify-send "Wallpaper has been reloaded"

exit 0
