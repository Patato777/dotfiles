#!/bin/bash

##############################################################################
#      Virtuaverse GRUB Theme Installation Script
#
#      Description:
#      This script installs the Virtuaverse GRUB theme.
#
#      Authors:
#      Federico Slongo
#      Pewrie Bontal
#
#      Copyright 2022-2024 the original author or authors
##############################################################################

CYAN='\033[0;36m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

#################################################
#@# Check correct grub directory to install
check_grub_ver() {
  if [ -x "$(command -v grub2-mkconfig)" ] && [ -d "/boot/grub2" ]; then
    if [ -x "$(command -v grub-mkconfig)" ] && [ -d "/boot/grub" ]; then
      printf "${RED}[ERR]\tBoth Grub2 and Grub detected. IDK what to do\n"
      exit 1
    else
      GRUB_DIR="/boot/grub2"
      printf "${CYAN}[MSG]\tGrub2 detected. Using directory: $GRUB_DIR\n"
    fi
  elif [ -x "$(command -v grub-mkconfig)" ] && [ -d "/boot/grub" ]; then
    GRUB_DIR="/boot/grub"
    printf "${CYAN}[MSG]\tGrub detected. Using directory: $GRUB_DIR\n${NC}"
  else
    printf "${RED}[ERR]\tNo grub directory found! wtf?\n${NC}"
    printf "${RED}[ERR]\tExiting...\n${NC}"
    exit 1
  fi

  printf "[MSG]\tUsing grub directory: $GRUB_DIR\n"
}

#################################################
# only run in case no themes directory found
# some distros have themes directory by default
make_themes_dir() {
  if [ ! -d $GRUB_DIR/themes ]; then
    printf "${CYAN}[MSG]\tThemes directory not found, creating...\n"
    mkdir $GRUB_DIR/themes
  fi
}

#################################################
#@# Copy themes to grub directory
copy_theme() {
  if [ -d $GRUB_DIR/themes/virtuaverse ]; then
    printf "${ORANGE}[WRN]\tFound existing virtuaverse theme at $GRUB_DIR/themes/virtuaverse, reinstalling...\n"
    rm -rf $GRUB_DIR/themes/virtuaverse
    cp ./themes/virtuaverse $GRUB_DIR/themes -r
  elif [ ! -d $GRUB_DIR/themes/virtuaverse ]; then
    printf "${CYAN}[MSG]\tCopying virtuaverse theme... into $GRUB_DIR/themes\n"
    cp ./themes/virtuaverse $GRUB_DIR/themes -r
  fi
}

#################################################
#@# Check if virtuaverse theme is installed correctly
verify_installation() {
  source_theme_dir="./themes/virtuaverse"
  target_theme_dir="$GRUB_DIR/themes/virtuaverse"
  install_success=1

  cd "$source_theme_dir"
  printf "${BLUE}[MSG]\tVERIFYING INSTALLATION...\n"

  sleep 1 # just to make it look like we're cooking

  while read item; do
    if [ ! -e "$target_theme_dir/$item" ]; then
      install_success=0
      printf "\n"
      printf "${RED}[ERR]\tTheme was not installed correctly!\n"
      printf "${RED}[ERR]\tMissing: $item\n"
      exit 1
    fi
  done < <(find . -type f -o -type d)

  if [ $install_success == 1 ]; then
    printf "${GREEN}[OK]\tTheme installed successfully!\n"
  fi
  cd - >/dev/null
}

#################################################
#@# Backup grub file
back_up_grub_file() {
  GRUB_FILE="/etc/default/grub"
  GRUB_ORIGINAL="/etc/default/grub.original" ## this one is og grub file in case all fucked up
  GRUB_BAK="/etc/default/grub.bak"

  if [ ! -f $GRUB_ORIGINAL ]; then
    cp $GRUB_FILE $GRUB_ORIGINAL
    printf "${CYAN}[MSG]\tthe og grub file can be found at $GRUB_ORIGINAL\n"
  fi

  cp $GRUB_FILE $GRUB_BAK
}

#################################################
#@# Set virtuaverse theme
set_theme() {
  THEME_TXT=$GRUB_DIR/themes/virtuaverse/theme.txt

  # Check if GRUB_THEME exists in the file
  # if found, replace the value
  # if not, add to end of line
  if grep -q "^GRUB_THEME=" "$GRUB_FILE"; then
    sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_TXT\"|" "$GRUB_FILE"
  else
    echo "GRUB_THEME=\"$THEME_TXT\"" >>"$GRUB_FILE"
  fi

  #################################################
  ## Show the changes made
  diff $GRUB_FILE $GRUB_BAK
  sleep 2
  printf "${NC}\n"
}

#################################################
#@# Update grub
# Some Disto doesnt have update-grub already
update_grub() {
  if [ ! -x "$(command -v update-grub)" ]; then
    if [ -x "$(command -v grub2-mkconfig)" ]; then
      set -e
      exec grub2-mkconfig -o $GRUB_DIR/grub.cfg
    elif [ -x "$(command -v grub-mkconfig)" ]; then
      set -e
      exec grub-mkconfig -o $GRUB_DIR/grub.cfg
    fi
  elif [ -x "$(command -v update-grub)" ]; then
    update-grub
  else
    printf "${RED}[ERR]\tUnable to update GRUB configuration. Please update it manually.\n"
  fi
}

ascii_art() {
  echo""
  echo " █                          █                                "
  echo "  █                          █                               "
  echo "   ██   ██ █   ███████████  █ █     █  ████ █████  ██    ███ "
  echo "    ██ █████ ██ ██ ██   ██ █████  ███ ███  █████████   ███   "
  echo "     ███ ██ ████  ████ ██ ████ ██ ██ █████ ████     ███████  "
  echo "      ████ █  ██  █ ███████  ██ ███ ██    █  ██     █ ██  █  "
  echo "        █ █    █ ██  ███ █    ████ ███████    ██  ██ ████    "
  echo "       █ █      Virtuaverse GRUB Theme Installer █           "
  echo""
}

#################################################
# Display help information
show_help() {
  echo "Usage: $0 [OPTIONS]"
  ascii_art
  echo "To install the Virtuaverse GRUB theme"
  echo "run sudo $0"
  echo ""
  echo "Options:"
  echo "  --help    Display this help message and exit"
}

#@# Main function
main() {
  ascii_art
  check_grub_ver
  make_themes_dir
  copy_theme
  verify_installation
  back_up_grub_file
  set_theme
  update_grub
}

init() {
  #################################################
  #@# Check for --help flag
  for arg in "$@"; do
    if [ "$arg" == "--help" ]; then
      show_help
      exit 0
    fi
  done

  #################################################
  #@# Check if running as root
  if [ "$EUID" -ne 0 ]; then
    printf "${RED}[ERR]\tPlease run as root \n"
    exit 1
  fi

  main "${@}"

}

init "${@}"
