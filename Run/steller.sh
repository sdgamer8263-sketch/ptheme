#!/bin/bash

# ----------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------
GITHUB_USER="sdgamer8263-sketch"
REPO_NAME="ptheme"
BRANCH="main"
THEME_ZIP_NAME="pterodactyl.zip"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# ----------------------------------------------------------------
# BANNER: ONLY SDGAMER
# ----------------------------------------------------------------
clear
echo -e "${BLUE}"
echo "   _____ ____  _____          __  __ ______ _____  "
echo "  / ____|  _ \|  __ \   /\   |  \/  |  ____|  __ \ "
echo " | (___ | | | | |  \/  /  \  | \  / | |__  | |__) |"
echo "  \___ \| | | | | __  / /\ \ | |\/| |  __| |  _  / "
echo "  ____) | |_| | |_\ \/ ____ \| |  | | |____| | \ \ "
echo " |_____/|____/ \____/_/    \_\_|  |_|______|_|  \_\\"
echo -e "${NC}"
echo "----------------------------------------------------------------"
sleep 2

# ----------------------------------------------------------------
# 1. AUTO-DETECT DIRECTORY
# ----------------------------------------------------------------
echo -e "${BLUE}[INFO] Searching for Pterodactyl installation...${NC}"

if [ -d "/var/www/pterodactyl" ]; then
    cd "/var/www/pterodactyl"
    echo -e "${GREEN}[OK] Detected Pterodactyl at: /var/www/pterodactyl${NC}"
elif [ -f "./artisan" ]; then
    echo -e "${GREEN}[OK] Detected Pterodactyl in current directory.${NC}"
else
    echo -e "${RED}[ERROR] Could not find Pterodactyl directory!${NC}"
    echo -e "${RED}Please run this script inside your Pterodactyl folder.${NC}"
    exit 1
fi

# ----------------------------------------------------------------
# 2. CHECK & INSTALL YARN (NEW STEP)
# ----------------------------------------------------------------
if ! command -v yarn &> /dev/null; then
    echo -e "${BLUE}[INFO] Yarn command not found. Installing Yarn...${NC}"
    npm install -g yarn
    
    if ! command -v yarn &> /dev/null; then
        echo -e "${RED}[ERROR] Failed to install Yarn automatically.${NC}"
        echo -e "${RED}Please run: apt install -y yarn OR npm install -g yarn manually.${NC}"
        exit 1
    else
        echo -e "${GREEN}[OK] Yarn installed successfully.${NC}"
    fi
else
    echo -e "${GREEN}[OK] Yarn is already installed.${NC}"
fi

# ----------------------------------------------------------------
# 3. DOWNLOAD & EXTRACT
# ----------------------------------------------------------------
echo -e "${BLUE}[INFO] Enabling Maintenance Mode...${NC}"
php artisan down

echo -e "${BLUE}[INFO] Downloading theme files...${NC}"
rm -rf temp_repo.zip
rm -rf "${REPO_NAME}-${BRANCH}"

wget -q "https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/heads/$BRANCH.zip" -O temp_repo.zip

if [ ! -f "temp_repo.zip" ]; then
    echo -e "${RED}[ERROR] Download failed. Check internet connection.${NC}"
    php artisan up
    exit 1
fi

echo -e "${BLUE}[INFO] Extracting repository...${NC}"
unzip -q -o temp_repo.zip

EXTRACTED_FOLDER="${REPO_NAME}-${BRANCH}"

if [ -f "$EXTRACTED_FOLDER/$THEME_ZIP_NAME" ]; then
    echo -e "${GREEN}[OK] Found theme ZIP. Installing...${NC}"
    
    mv "$EXTRACTED_FOLDER/$THEME_ZIP_NAME" .
    rm -rf "$EXTRACTED_FOLDER"
    rm temp_repo.zip
    
    unzip -o -q "$THEME_ZIP_NAME"
    rm "$THEME_ZIP_NAME"
    
    echo -e "${GREEN}[OK] Theme files applied.${NC}"
else
    echo -e "${RED}[ERROR] '$THEME_ZIP_NAME' not found in repository!${NC}"
    rm -rf "$EXTRACTED_FOLDER"
    rm temp_repo.zip
    php artisan up
    exit 1
fi

# ----------------------------------------------------------------
# 4. INSTALLATION COMMANDS
# ----------------------------------------------------------------
echo -e "${BLUE}[INFO] Installing dependencies (react-feather)...${NC}"
yarn add react-feather

echo -e "${BLUE}[INFO] Migrating database...${NC}"
php artisan migrate --force

echo -e "${BLUE}[INFO] Clearing views...${NC}"
php artisan view:clear

echo -e "${BLUE}[INFO] Building assets (This may take a few minutes)...${NC}"
yarn build:production

# ----------------------------------------------------------------
# 5. FINALIZE
# ----------------------------------------------------------------
echo -e "${BLUE}[INFO] Fixing permissions...${NC}"
chown -R www-data:www-data *

echo -e "${BLUE}[INFO] Disabling Maintenance Mode...${NC}"
php artisan up

echo -e "${GREEN}"
echo "----------------------------------------------------------------"
echo " INSTALLATION COMPLETE! "
echo "----------------------------------------------------------------"
echo -e "${NC}"
