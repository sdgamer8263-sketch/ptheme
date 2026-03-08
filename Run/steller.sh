#!/bin/bash

# ----------------------------------------------------------------
# AUTO-DETECT SETTINGS
# ----------------------------------------------------------------
# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# ----------------------------------------------------------------
# BANNER
# ----------------------------------------------------------------
clear
echo -e "${BLUE}"
echo "  _________  ________  ________  ________  _____ ______   _______   ________     "
echo " |\   ____ \|\   ___ \|\   ____\|\   __  \|\   _ \  _   \|\  ___ \ |\   __  \    "
echo " \ \  \___|_\ \  \_|\ \ \  \___|\ \  \|\  \ \  \\\__\ \  \ \   __/|\ \  \|\  \   "
echo "  \ \_____  \\ \  \ \\ \ \  \  __\ \   __  \ \  \\|__| \  \ \  \_|/_\ \   _  _\  "
echo "   \|____|\  \\ \  \_\\ \ \  \|\  \ \  \ \  \    \ \  \ \  \_|\ \ \  \\  \| "
echo "     ____\_\  \\ \_______\ \_______\ \__\ \__\ \__\    \ \__\ \_______\ \__\\ _\ "
echo "    |\_________\|_______|\|_______|\|__|\|__|\|__|     \|__|\|_______|\|__|\|__|"
echo "    \|_________|                                                                "
echo -e "${NC}"
echo -e "${GREEN}    >>> Fully Automatic Theme Installer by SDGAMER <<< ${NC}"
echo "----------------------------------------------------------------"
sleep 2

# 1. AUTO-DETECT DIRECTORY
echo -e "${BLUE}[INFO] Detecting Pterodactyl installation...${NC}"

if [ -d "$TARGET_DIR" ]; then
    cd "$TARGET_DIR"
    echo -e "${GREEN}[OK] Found Pterodactyl at: $TARGET_DIR${NC}"
else
    echo -e "${RED}[ERROR] Pterodactyl folder (/var/www/pterodactyl) not found!${NC}"
    echo -e "${RED}Installation cannot proceed automatically.${NC}"
    exit 1
fi

# 2. INSTALL UNZIP (Just in case)
if ! command -v unzip &> /dev/null; then
    echo -e "${BLUE}[INFO] Installing 'unzip'...${NC}"
    apt-get update && apt-get install -y unzip
fi

# 3. MAINTENANCE MODE
echo -e "${BLUE}[INFO] Enabling Maintenance Mode...${NC}"
php artisan down

# 4. DOWNLOAD REPO
echo -e "${BLUE}[INFO] Downloading resources from GitHub...${NC}"
# Delete old temp files if exist
rm -rf temp_repo.zip ptheme-main

wget -q "https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/heads/$BRANCH.zip" -O temp_repo.zip

if [ -f "temp_repo.zip" ]; then
    echo -e "${GREEN}[OK] Download complete.${NC}"
else
    echo -e "${RED}[ERROR] Could not download from GitHub.${NC}"
    php artisan up
    exit 1
fi

# 5. FIND AND EXTRACT 'pterodactyl.zip'
echo -e "${BLUE}[INFO] Extracting repository to find theme file...${NC}"
unzip -q -o temp_repo.zip

# GitHub extracts to folder 'RepoName-Branch' (e.g., ptheme-main)
EXTRACTED_FOLDER="${REPO_NAME}-${BRANCH}"

if [ -f "$EXTRACTED_FOLDER/$THEME_ZIP_NAME" ]; then
    echo -e "${GREEN}[OK] Found '$THEME_ZIP_NAME'. Installing...${NC}"
    
    # Move specific zip to current dir
    mv "$EXTRACTED_FOLDER/$THEME_ZIP_NAME" .
    
    # Unzip the theme over the panel
    unzip -o -q "$THEME_ZIP_NAME"
    
    # Clean up junk
    rm "$THEME_ZIP_NAME"
    rm -rf "$EXTRACTED_FOLDER"
    rm temp_repo.zip
    
    echo -e "${GREEN}[OK] Theme files applied.${NC}"
else
    echo -e "${RED}[ERROR] '$THEME_ZIP_NAME' not found inside the repo!${NC}"
    rm -rf "$EXTRACTED_FOLDER"
    rm temp_repo.zip
    php artisan up
    exit 1
fi

# 6. RUN COMMANDS
echo -e "${BLUE}[INFO] Installing dependencies (react-feather)...${NC}"
yarn add react-feather

echo -e "${BLUE}[INFO] Migrating database...${NC}"
php artisan migrate --force

echo -e "${BLUE}[INFO] Clearing views...${NC}"
php artisan view:clear

echo -e "${BLUE}[INFO] Building production assets (Wait koro, somoy lagbe)...${NC}"
yarn build:production

# 7. FIX PERMISSIONS
echo -e "${BLUE}[INFO] Fixing permissions...${NC}"
chown -R www-data:www-data *

# 8. EXIT MAINTENANCE MODE
echo -e "${BLUE}[INFO] Disabling Maintenance Mode...${NC}"
php artisan up

echo -e "${GREEN}"
echo "----------------------------------------------------------------"
echo " INSTALLATION SUCCESSFUL! "
echo "----------------------------------------------------------------"
echo -e "${NC}"
