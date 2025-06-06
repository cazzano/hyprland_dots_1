#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Check if Hyprland-Dots exists in assets folder
if [ -d "assets/Hyprland-Dots" ]; then
  printf "${NOTE} Found ${SKY_BLUE}KooL's Hyprland Dots${RESET} in assets folder, using that instead of cloning...\n"
  
  # Check if Hyprland-Dots exists in current directory
  if [ ! -d "Hyprland-Dots" ]; then
    cp -r "assets/Hyprland-Dots" "Hyprland-Dots"
  else
    printf "${NOTE} Hyprland-Dots directory already exists in current location.\n"
  fi
  
  cd Hyprland-Dots || exit 1
  chmod +x copy.sh
  ./copy.sh
else
  printf "${NOTE} Cloning and Installing ${SKY_BLUE}KooL's Hyprland Dots${RESET}....\n"

  # Check if Hyprland-Dots already exists in current directory
  if [ -d "Hyprland-Dots" ]; then
    cd Hyprland-Dots
    printf "${NOTE} Updating existing Hyprland-Dots repository...\n"
    git stash && git pull
    chmod +x copy.sh
    ./copy.sh 
  else
    # Clone the repository
    if git clone --depth=1 https://github.com/JaKooLit/Hyprland-Dots; then
      cd Hyprland-Dots || exit 1
      chmod +x copy.sh
      ./copy.sh 
    else
      echo -e "$ERROR Can't download ${YELLOW}KooL's Hyprland-Dots${RESET}. Check your internet connection"
      exit 1
    fi
  fi
fi

printf "\n%.0s" {1..2}
