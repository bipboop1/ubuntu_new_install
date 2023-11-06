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

echo -e "${YELLOW}yellow${NC}"
echo -e "${BOLD_YELLOW}bold yellow${NC}"
echo -e "${BLACK}black${NC}"
echo -e "${BOLD_BLACK}bold black${NC}"
echo -e "${RED}red${NC}"
echo -e "${BOLD_RED}bold red${NC}"
echo -e "${GREEN}green${NC}"
echo -e "${BOLD_GREEN}bold green${NC}"
echo -e "${BLUE}blue${NC}"
echo -e "${BOLD_BLUE}bold blue${NC}"
echo -e "${PURPLE}purple${NC}"
echo -e "${BOLD_PURPLE}bold purple${NC}"
echo -e "${CYAN}cyan${NC}"
echo -e "${BOLD_CYAN}bold cyan${NC}"
echo -e "${WHITE}white${NC}"
echo -e "${BOLD_WHITE}bold white${NC}"
echo -e "${MAGENTA}magenta${NC}"
echo -e "${BOLD_MAGENTA}bold magenta${NC}"


echo -e "${BOLD_CYAN}
				.---------------.
				| welcome to my |
				'---------------'"
echo -e "${CYAN}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
██ ██ █ ▄▄▀█ ██ █ ▄▄▀█▄ ▄█ ██ ███▀▄▄▀█ █▀█ ▄▄▄████▄██ ▄▄▀█ ▄▄█▄ ▄█ ▄▄▀█ ██ ██ ▄▄█ ▄▄▀██
██ ██ █ ▄▄▀█ ██ █ ██ ██ ██ ██ ███ ▀▀ █ ▄▀█ █▄▀████ ▄█ ██ █▄▄▀██ ██ ▀▀ █ ██ ██ ▄▄█ ▀▀▄██
██▄▀▀▄█▄▄▄▄██▄▄▄█▄██▄██▄███▄▄▄███ ████▄█▄█▄▄▄▄███▄▄▄█▄██▄█▄▄▄██▄██▄██▄█▄▄█▄▄█▄▄▄█▄█▄▄██
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
${NC}"

# Update and upgrade the system
echo -e "${BOLD_YELLOW}updating and upgrading the system${NC}"
sudo
#sudo apt update
#sudo apt upgrade
#sudo apt-get update
#sudo apt-get upgrade
echo -e "${YELLOW}apt and apt-get are now up to date.${NC}"
