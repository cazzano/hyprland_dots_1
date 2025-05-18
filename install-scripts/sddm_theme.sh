#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM themes #

source_theme="https://codeberg.org/JaKooLit/sddm-sequoia"
theme_name="sequoia_2"

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

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm_theme.log"
    
# SDDM-themes
printf "${INFO} Installing ${SKY_BLUE}Additional SDDM Theme${RESET}\n"

# Check if assets folder has the sddm-sequoia repo
if [ -d "assets/sddm-sequoia" ]; then
  echo "${OK} - Found sddm-sequoia in assets folder, using that instead of cloning." | tee -a "$LOG"
  cp -r "assets/sddm-sequoia" "$theme_name"
else
  # Clone the repository if it doesn't exist already
  if [ ! -d "$theme_name" ]; then
    if git clone --depth=1 "$source_theme" "$theme_name"; then
      echo "${OK} - Successfully cloned the $theme_name repository." | tee -a "$LOG"
    else
      echo "${ERROR} - Failed to clone the sddm theme repository. Please check your internet connection." | tee -a "$LOG" >&2
      exit 1
    fi
  else
    echo "${OK} - $theme_name directory already exists, using existing files." | tee -a "$LOG"
  fi
fi

# Create themes directory if it doesn't exist
if [ ! -d "/usr/share/sddm/themes" ]; then
  sudo mkdir -p /usr/share/sddm/themes
  echo "${OK} - Directory '/usr/share/sddm/themes' created." | tee -a "$LOG"
fi

# Check if /usr/share/sddm/themes/$theme_name exists and backup if needed
if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
  echo "${NOTE} - Backing up existing $theme_name theme." | tee -a "$LOG"
  backup_date=$(date +%Y%m%d%H%M%S)
  sudo mv "/usr/share/sddm/themes/$theme_name" "/usr/share/sddm/themes/${theme_name}_backup_${backup_date}"
  echo "${OK} - Backed up existing theme to ${theme_name}_backup_${backup_date}." | tee -a "$LOG"
fi

# Copy the theme to the themes directory
sudo cp -r "$theme_name" "/usr/share/sddm/themes/$theme_name" 2>&1 | tee -a "$LOG"
echo "${OK} - Theme copied to /usr/share/sddm/themes/$theme_name." | tee -a "$LOG"

# setting up SDDM theme
sddm_conf_dir="/etc/sddm.conf.d"
BACKUP_SUFFIX=".bak"

echo -e "${NOTE} Setting up the login screen." | tee -a "$LOG"

if [ -d "$sddm_conf_dir" ]; then
  echo "Backing up files in $sddm_conf_dir" | tee -a "$LOG"
  for file in "$sddm_conf_dir"/*; do
    if [ -f "$file" ]; then
      if [[ "$file" == *$BACKUP_SUFFIX ]]; then
        echo "Skipping backup file: $file" | tee -a "$LOG"
        continue
      fi
      # Backup each original file
      sudo cp "$file" "$file$BACKUP_SUFFIX" 2>&1 | tee -a "$LOG"
      echo "Backup created for $file" | tee -a "$LOG"
      
      # Edit existing "Current=" 
      if grep -q '^[[:space:]]*Current=' "$file"; then
        sudo sed -i "s/^[[:space:]]*Current=.*/Current=$theme_name/" "$file" 2>&1 | tee -a "$LOG"
        echo "Updated theme in $file" | tee -a "$LOG"
      fi
    fi
  done
else
  echo "$CAT - $sddm_conf_dir not found, creating..." | tee -a "$LOG"
  sudo mkdir -p "$sddm_conf_dir" 2>&1 | tee -a "$LOG"
fi

if [ ! -f "$sddm_conf_dir/theme.conf.user" ]; then
  echo -e "[Theme]\nCurrent = $theme_name" | sudo tee "$sddm_conf_dir/theme.conf.user" > /dev/null
  
  if [ -f "$sddm_conf_dir/theme.conf.user" ]; then
    echo "Created and configured $sddm_conf_dir/theme.conf.user with theme $theme_name" | tee -a "$LOG"
  else
    echo "Failed to create $sddm_conf_dir/theme.conf.user" | tee -a "$LOG"
  fi
else
  echo "$sddm_conf_dir/theme.conf.user already exists, skipping creation." | tee -a "$LOG"
fi

# Replace current background from assets
sudo cp -r assets/sddm.png "/usr/share/sddm/themes/$theme_name/backgrounds/default" 2>&1 | tee -a "$LOG"
sudo sed -i 's|^wallpaper=".*"|wallpaper="backgrounds/default"|' "/usr/share/sddm/themes/$theme_name/theme.conf" 2>&1 | tee -a "$LOG"

echo "${OK} - ${MAGENTA}Additional SDDM Theme${RESET} successfully installed." | tee -a "$LOG"

printf "\n%.0s" {1..2}
