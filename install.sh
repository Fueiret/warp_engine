#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Run this script with root (sudo)"
    exit 1
fi

if [[ -z "$SUDO_USER" ]]; then
    echo "SUDO_USER is not defined. Run script with sudo."
    exit 1
fi

USER_HOME="/home/$SUDO_USER"
CONFIG_DIR="$USER_HOME/.config"
HYPR_DIR="$CONFIG_DIR/hypr"
WALLPAPERS_DIR="$USER_HOME/wallpapers"

# updating system
echo "Updating system..."
pacman -Syu --noconfirm --needed

echo "Installing essential packages..."
pacman -S --noconfirm git curl sudo base-devel

# pacman packages
if [[ -f "pkglist.txt" ]]; then
    echo "Installing packages from pkglist.txt..."
    PKGS=$(grep -Ev '^\s*#' pkglist.txt | tr '\n' ' ')
    if [[ -n "$PKGS" ]]; then
        pacman -S --noconfirm $PKGS --needed
    fi
else
    echo "pkglist.txt not found, skipping repository package installation."
fi

# aur packages
if [[ ! -x "$(command -v yay)" ]]; then
    echo "Installing yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    chown -R "$SUDO_USER:$SUDO_USER" /tmp/yay
    cd /tmp/yay || exit
    su "$SUDO_USER" -c "makepkg -si --noconfirm"
    cd - || exit
fi

if [[ -f "aurlist.txt" ]]; then
    echo "Installing packages from aurlist.txt..."
    AUR_PKGS=$(grep -Ev '^\s*#' aurlist.txt | tr '\n' ' ')
    if [[ -n "$AUR_PKGS" ]]; then
        su "$SUDO_USER" -c "yay -S --noconfirm $AUR_PKGS --needed"
    fi
else
    echo "aurlist.txt not found, skipping AUR package installation."
fi

# Hypralnd
mkdir -p "$HYPR_DIR" "$CONFIG_DIR/waybar" "$CONFIG_DIR/rofi" "$CONFIG_DIR/dunst" "$CONFIG_DIR/alacritty" "$WALLPAPERS_DIR"

REPO_URL="https://github.com/Fueiret/warp_engine.git"
TEMP_DIR="/tmp/hyprland-configs"
rm -rf "$TEMP_DIR"
su "$SUDO_USER" -c "git clone $REPO_URL $TEMP_DIR"

if [[ $? -ne 0 ]]; then
    echo "Error cloning git repository. Check URL."
    exit 1
fi

# creating directories
cp -r "$TEMP_DIR/alacritty" "$CONFIG_DIR/alacritty"
cp -r "$TEMP_DIR/dunst" "$CONFIG_DIR/dunst"
cp -r "$TEMP_DIR/hypr" "$HYPR_DIR"
cp -r "$TEMP_DIR/rofi" "$CONFIG_DIR/rofi"
cp -r "$TEMP_DIR/scripts" "$CONFIG_DIR/scripts"
cp -r "$TEMP_DIR/waybar" "$CONFIG_DIR/waybar"
cp -r "$TEMP_DIR/wallpapers" "$USER_HOME/wallpapers"

# zsh
cp "$TEMP_DIR/.zshrc" "$USER_HOME/.zshrc"
cp -r "$TEMP_DIR/.zsh" "$USER_HOME/.zsh"

chown -R "$SUDO_USER:$SUDO_USER" "$CONFIG_DIR"
chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.zshrc"
chown -R "$SUDO_USER:$SUDO_USER" "$USER_HOME/.zsh"

pacman -S --noconfirm zsh
chsh -s /bin/zsh "$SUDO_USER"

systemctl enable bluetooth.service
systemctl start bluetooth.service
systemctl enable sddm.service

echo "Installation complete. Reboot and select Hyprland in Display Manager."
