#!/bin/bash

# Colors
CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Possible GRUB directories
GRUB_DIR="/boot/grub"
GRUB2_DIR="/boot/grub2"

# Function to remove the theme
remove_theme() {
    if [ -d "$GRUB_DIR/themes/virtuaverse" ]; then
        echo -e "${CYAN}[MSG]\tRemoving theme from $GRUB_DIR/themes/virtuaverse...${NC}"
        sudo rm -rf "$GRUB_DIR/themes/virtuaverse"
    elif [ -d "$GRUB2_DIR/themes/virtuaverse" ]; then
        echo -e "${CYAN}[MSG]\tRemoving theme from $GRUB2_DIR/themes/virtuaverse...${NC}"
        sudo rm -rf "$GRUB2_DIR/themes/virtuaverse"
    else
        echo -e "${RED}[ERR]\tVirtuaverse theme not found in known directories.${NC}"
    fi
}

# Function to restore the GRUB configuration file
restore_grub_config() {
    GRUB_FILE="/etc/default/grub"
    GRUB_BAK="/etc/default/grub.bak"

    if [ -f "$GRUB_BAK" ]; then
        echo -e "${CYAN}[MSG]\tRestoring original GRUB configuration from $GRUB_BAK...${NC}"
        sudo cp "$GRUB_BAK" "$GRUB_FILE"
    else
        echo -e "${RED}[ERR]\tBackup GRUB file (${GRUB_BAK}) not found.${NC}"
        exit 1
    fi
}

# Function to update GRUB and initramfs
update_grub() {
    if [ -x "$(command -v update-grub2)" ]; then
        echo -e "${CYAN}[MSG]\tUpdating GRUB using update-grub2...${NC}"
        sudo update-grub2
    elif [ -x "$(command -v update-grub)" ]; then
        echo -e "${CYAN}[MSG]\tUpdating GRUB using update-grub...${NC}"
        sudo update-grub
    else
        echo -e "${RED}[ERR]\tCould not find a command to update GRUB. Please update it manually.${NC}"
        exit 1
    fi

    echo -e "${CYAN}[MSG]\tUpdating initramfs...${NC}"
    sudo update-initramfs -u
}

# Main function
main() {
    remove_theme
    restore_grub_config
    update_grub
    echo -e "${GREEN}[OK]\tVirtuaverse theme uninstalled, GRUB configuration restored, and initramfs updated.${NC}"
}

# Execute the main function
main
