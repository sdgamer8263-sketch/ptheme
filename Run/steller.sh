#!/bin/bash



# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# ----------------------------------------------------------------
# BANNER DISPLAY
# ----------------------------------------------------------------
clear
echo -e "${BLUE}"
echo "  _________  ________  ________  ________  _____ ______   _______   ________     "
echo " |\   ____ \|\   ___ \|\   ____\|\   __  \|\   _ \  _   \|\  ___ \ |\   __  \    "
echo " \ \  \___|_\ \  \_|\ \ \  \___|\ \  \|\  \ \  \\\__\ \  \ \   __/|\ \  \|\  \   "
echo "  \ \_____  \\ \  \ \\ \ \  \  __\ \   __  \ \  \\|__| \  \ \  \_|/_\ \   _  _\  "
echo "   \|____|\  \\ \  \_\\ \ \  \|\  \ \  \ \  \ \  \    \ \  \ \  \_|\ \ \  \\  \| "
echo "     ____\_\  \\ \_______\ \_______\ \__\ \__\ \__\    \ \__\ \_______\ \__\\ _\ "
echo "    |\_________\|_______|\|_______|\|__|\|__|\|__|     \|__|\|_______|\|__|\|__|"
echo "    \|_________|                                                                "
echo -e "${NC}"
echo -e "${GREEN}    >>> Pterodactyl Theme Installer by SDGAMER <<< ${NC}"
echo "----------------------------------------------------------------"
sleep 2

# 1. Check Directory
echo -e "${BLUE}[INFO] Checking directory...${NC}"
if [ -d "$PTERO_DIR" ]; then
    cd "$PTERO_DIR"
    echo -e "${GREEN}[OK] Navigated to $PTERO_DIR${NC}"
else
    echo -e "${RED}[ERROR] Pterodactyl directory not found!${NC}"
    exit 1
fi

# 2. Maintenance Mode
echo -e "${BLUE}[INFO] Turning on maintenance mode...${NC}"
php artisan down

# 3. Download GitHub Repo
echo -e "${BLUE}[INFO] Downloading repository from GitHub...${NC}"
wget -q "https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/heads/$BRANCH.zip" -O repo_download.zip

if [ -f "repo_download.zip" ]; then
    echo -e "${GREEN}[OK] Repo downloaded.${NC}"
else
    echo -e "${RED}[ERROR] Download failed. Check GitHub connection.${NC}"
    exit 1
fi

# 4. Extract Repo to find specific ZIP
echo -e "${BLUE}[INFO] Searching for $THEME_ZIP_NAME...${NC}"
unzip -q -o repo_download.zip

# GitHub folder structure usually is 'RepoName-Branch'
EXTRACTED_FOLDER="${REPO_NAME}-${BRANCH}"

if [ -f "$EXTRACTED_FOLDER/$THEME_ZIP_NAME" ]; then
    echo -e "${GREEN}[OK] Found $THEME_ZIP_NAME inside repo.${NC}"

    # Move the theme zip to main directory
    mv "$EXTRACTED_FOLDER/$THEME_ZIP_NAME" .

    # Clean up repo junk immediately
    rm -rf "$EXTRACTED_FOLDER"
    rm repo_download.zip

    # 5. UNZIP THEME FILES (The Main Step)
    echo -e "${BLUE}[INFO] Extracting theme files from $THEME_ZIP_NAME...${NC}"
    unzip -o -q "$THEME_ZIP_NAME"
    
    # Delete the zip after extraction
    rm "$THEME_ZIP_NAME"
    echo -e "${GREEN}[OK] Theme files installed.${NC}"
else
    echo -e "${RED}[ERROR] $THEME_ZIP_NAME not found in the repository!${NC}"
    echo -e "${RED}Please make sure you uploaded 'pterodactyl.zip' to your GitHub main branch.${NC}"
    rm -rf "$EXTRACTED_FOLDER"
    rm repo_download.zip
    php artisan up
    exit 1
fi

# 6. Install Dependencies & Build
echo -e "${BLUE}[INFO] Installing react-feather...${NC}"
yarn add react-feather

echo -e "${BLUE}[INFO] Database migration...${NC}"
php artisan migrate --force

echo -e "${BLUE}[INFO] Clearing views...${NC}"
php artisan view:clear

echo -e "${BLUE}[INFO] Building production assets (This takes time)...${NC}"
yarn build:production

# 7. Set Permissions
echo -e "${BLUE}[INFO] Fixing permissions...${NC}"
chown -R www-data:www-data $PTERO_DIR/*

# 8. Maintenance Mode Off
echo -e "${BLUE}[INFO] Turning off maintenance mode...${NC}"
php artisan up

echo -e "${GREEN}"
echo "----------------------------------------------------------------"
echo " INSTALLATION COMPLETE! "
echo "----------------------------------------------------------------"
echo -e "${NC}"
