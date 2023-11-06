#!/bin/bash

# ANSI color codes
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
██ ██ █ ▄▄▀█ ██ █ ▄▄▀█▄ ▄█ ██ ███▀▄▄▀█ █▀█ ▄▄▄████▄██ ▄▄▀█ ▄▄█▄ ▄█ ▄▄▀█ ██ ██ ▄▄█ ▄▄▀██
██ ██ █ ▄▄▀█ ██ █ ██ ██ ██ ██ ███ ▀▀ █ ▄▀█ █▄▀████ ▄█ ██ █▄▄▀██ ██ ▀▀ █ ██ ██ ▄▄█ ▀▀▄██
██▄▀▀▄█▄▄▄▄██▄▄▄█▄██▄██▄███▄▄▄███ ████▄█▄█▄▄▄▄███▄▄▄█▄██▄█▄▄▄██▄██▄██▄█▄▄█▄▄█▄▄▄█▄█▄▄██
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
"

# Update and upgrade the system
echo -e "${YELLOW}updating and upgrading the system${NC}"
sudo
#sudo apt update
#sudo apt upgrade
#sudo apt-get update
#sudo apt-get upgrade
echo -e "${YELLOW}apt and apt-get are now up to date.${NC}"
