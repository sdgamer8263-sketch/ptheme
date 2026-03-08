#!/bin/bash

# --- Colors for formatting ---
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Function: SDGAMER Banner ---
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "  ____  _____   ____    _    __  __ _____ ____  "
    echo " / ___||  _  \ / ___|  / \  |  \/  | ____|  _ \ "
    echo " \___ \| | | || |  _  / _ \ | |\/| |  _| | |_) |"
    echo "  ___) | |_| || |_| |/ ___ \| |  | | |___|  _ < "
    echo " |____/|_____/ \____/_/   \_\_|  |_|_____|_| \_\\"
    echo -e "${NC}"
    echo -e "${YELLOW}       Welcome to SDGAMER Panel Manager${NC}"
    echo "=================================================="
}


echo "----------------------------------------------------------------"
echo "Starting Installation 
echo "----------------------------------------------------------------"

# 1. Pterodactyl folder e dhuka
cd $PTERO_DIR || { echo "Pterodactyl directory pawa jayni!"; exit 1; }

# 2. Maintenance mode on kora
echo "[+] Turning on maintenance mode..."
php artisan down

# 3. GitHub theke Zip download kora (SFTP er bodole)
echo "[+] Downloading files directly from GitHub..."
wget "https://github.com/$GITHUB_USER/$REPO_NAME/archive/refs/heads/$BRANCH.zip" -O theme.zip

if [ -f "theme.zip" ]; then
    echo "[+] Download successful."
else
    echo "[-] Download failed. GitHub link ba repo name check koro."
    exit 1
fi

# 4. Unzip kora ebong file replace kora
echo "[+] Unzipping files..."
unzip -o theme.zip

# GitHub zip extract hole ekta folder create hoy (ex: ptheme-main)
# Oikhankar file gulo main directory te anchi
EXTRACTED_DIR="${REPO_NAME}-${BRANCH}"

if [ -d "$EXTRACTED_DIR" ]; then
    echo "[+] Moving files to Pterodactyl root..."
    cp -rf $EXTRACTED_DIR/* .
    rm -rf $EXTRACTED_DIR
    echo "[+] Files replaced successfully."
else
    echo "[-] Extracted folder pawa jayni, check directory structure."
fi

# Zip file delete kora
rm theme.zip

# 5. Tomar dewa command gulo run kora
echo "[+] Installing dependencies (react-feather)..."
yarn add react-feather

echo "[+] Database migration..."
# '--force' dewa hoyeche jate '> yes' automatic hoye jay
php artisan migrate --force

echo "[+] Building production assets (Wait a minute)..."
yarn build:production

echo "[+] Clearing view cache..."
php artisan view:clear

# 6. Permission thik kora
echo "[+] Fixing permissions..."
chown -R www-data:www-data $PTERO_DIR/*

# 7. Maintenance mode off kora
echo "[+] Turning off maintenance mode..."
php artisan up

echo "----------------------------------------------------------------"
echo "Installation Complete!Now you can change Theme From Admin Panel."
echo "----------------------------------------------------------------"

