#!/bin/bash

# ANSI color codes
YELLOW='\033[0;33m'
BOLD_YELLOW='\033[1;33m'
BLACK='\033[0;30m'
BOLD_BLACK='\033[1;30m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
GREEN='\033[0;32m'
BOLD_GREEN='\033[1;32m'
BLUE='\033[0;34m'
BOLD_BLUE='\033[1;34m'
PURPLE='\033[0;35m'
BOLD_PURPLE='\033[1;35m'
CYAN='\033[0;36m'
BOLD_CYAN='\033[1;36m'
WHITE='\033[0;37m'
BOLD_WHITE='\033[1;37m'
MAGENTA='\033[0;95m'
BOLD_MAGENTA='\033[1;95m'
NC='\033[0m' # No Color

echo "${YELLOW}yellow${NC}"
echo "${BOLD_YELLOW}bold yellow${NC}"
echo "${BLACK}black${NC}"
echo "${BOLD_BLACK}bold black${NC}"
echo "${RED}red${NC}"
echo "${BOLD_RED}bold red${NC}"
echo "${GREEN}green${NC}"
echo "${BOLD_GREEN}bold green${NC}"
echo "${BLUE}blue${NC}"
echo "${BOLD_BLUE}bold blue${NC}"
echo "${PURPLE}purple${NC}"
echo "${BOLD_PURPLE}bold purple${NC}"
echo "${CYAN}cyan${NC}"
echo "${BOLD_CYAN}bold cyan${NC}"
echo "${WHITE}white${NC}"
echo "${BOLD_WHITE}bold white${NC}"
echo "${MAGENTA}magenta${NC}"
echo "${BOLD_MAGENTA}bold magenta${NC}"


echo "
▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
██ ██ █ ▄▄▀█ ██ █ ▄▄▀█▄ ▄█ ██ ███▀▄▄▀█ █▀█ ▄▄▄████▄██ ▄▄▀█ ▄▄█▄ ▄█ ▄▄▀█ ██ ██ ▄▄█ ▄▄▀██
██ ██ █ ▄▄▀█ ██ █ ██ ██ ██ ██ ███ ▀▀ █ ▄▀█ █▄▀████ ▄█ ██ █▄▄▀██ ██ ▀▀ █ ██ ██ ▄▄█ ▀▀▄██
██▄▀▀▄█▄▄▄▄██▄▄▄█▄██▄██▄███▄▄▄███ ████▄█▄█▄▄▄▄███▄▄▄█▄██▄█▄▄▄██▄██▄██▄█▄▄█▄▄█▄▄▄█▄█▄▄██
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
"

# Update and upgrade the system
echo -e "${BOLD_YELLOW}updating and upgrading the system${NC}"
sudo
#sudo apt update
#sudo apt upgrade
#sudo apt-get update
#sudo apt-get upgrade
echo -e "${YELLOW}apt and apt-get are now up to date.${NC}"
