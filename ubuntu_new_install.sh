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

confirm_update()
{
	local pkg_name="$1" # this is kinda useless, i could just use $1 but sure ok i guess its more readable
	echo -e "${BOLD_CYAN}Do you want to update and upgrade $pkg_name? (y/n): ${NC}"
	read choice
	if [ "$choice" = "y"  ] || [ "$choice" = "yes" ]; then
		return 0
	elif [ "$choice" = "n" ] || [ "$choice" = "no" ]; then
		return 1
	else
		echo -e "${BOLD_RED}Invalid choice. Please try again.${NC}"
		confirm_update $pkg_name
	fi
}

# Function to confirm installation
confirm_install()
{
	local pkg_name="$1"
	echo -e "${BOLD_CYAN}Do you want to install $pkg_name? (y/n): ${NC}"
	read choice
	if [ "$choice" = "y"  ] || [ "$choice" = "yes" ]; then
		return 0
	elif [ "$choice" = "n" ] || [ "$choice" = "no" ]; then
		return 1
	else
		echo -e "${BOLD_RED}Invalid choice. Please try again.${NC}"
		confirm_install $pkg_name
	fi
}


# Update and upgrade the system
echo -e "${BOLD_YELLOW}updating and upgrading the system${NC}"
if confirm_update "apt"; then
	sudo apt update
	sudo apt upgrade
fi	

if confirm_update "apt-get"; then
	sudo apt-get update
	sudo apt-get upgrade
fi
echo -e "${YELLOW}apt and apt-get are now up to date.${NC}"

# Install essential packages and development
echo -e "${BOLD_YELLOW}entering essential packages and development section${NC}"
if confirm_install "curl"; then
    sudo apt install curl
fi

if confirm_install "git"; then
    sudo apt install git
fi

if confirm_install "zsh"; then
    sudo apt install zsh
fi

if confirm_install "vim"; then
    sudo apt install vim
fi

if confirm_install "tree"; then
    sudo apt install tree
fi

if confirm_install "clang"; then
    sudo apt install clang
fi

if confirm_install "pip3"; then
    sudo apt install python3-pip
fi

if confirm_install "pip"; then
	sudo apt install python-pip
fi

if confirm_install "python3"; then
	sudo apt install python3
fi

#if confirm_install "python"; then
#	sudo apt install python
#fi

if confirm_install "wget"; then
	sudo apt-get install wget
fi

# Install Oh My Zsh and set it as the default shell
if confirm_install "Oh My Zsh"; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sudo chsh -s $(which zsh) $(whoami)
fi

# Install Visual Studio Code via Snap
if confirm_install "Visual Studio Code"; then
    sudo snap install --classic code
fi

# Install 42 school stuff
echo -e "${BOLD_YELLOW}entering 42 school stuff section${NC}"
if confirm_install "gcc"; then
    sudo apt install gcc
fi

if confirm_install "make"; then
    sudo apt install make
fi

if confirm_install "valgrind"; then
    sudo apt install valgrind
fi

if confirm_install "cmake"; then
    sudo apt install cmake
fi

if confirm_install "42 header"; then
	curl https://raw.githubusercontent.com/42Paris/42header/master/install.sh | bash
fi

if confirm_install "norminette"; then
	curl -o norminette.deb -L
fi

# General purpose programs
echo -e "${BOLD_YELLOW}entering general purpose section${NC}"

# Install Brave browser
if confirm_install "Brave browser"; then
    sudo apt install brave-browser
fi

if confirm_install "VLC"; then
    sudo apt install vlc
fi

if confirm_install "MPV"; then
    sudo apt install mpv
fi

if confirm_install "ffmpeg"; then
	sudo apt install ffmpeg
fi

# Install torrenting stuff
echo -e "${BOLD_YELLOW}entering torrents and downloads section${NC}"

if confirm_install "Transmission"; then
	sudo apt install transmission
fi

if confirm_install "qBittorrent"; then
	sudo apt install qbittorrent
fi

if confirm_install "yt-dlp"; then
	sudo wget -qO /usr/local/bin/yt-dlp https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
	sudo chmod a+rx /usr/local/bin/yt-dlp
fi

if confirm_install "seedmage"; then
	sudo wget -qO /usr/local/bin/seedmage https://github.com/DimitriFourny/seedmage.git
	sudo chmod a+rx /usr/local/bin/seedmage
fi

# Install graphics and creation programs
echo -e "${BOLD_YELLOW}entering graphics programs section${NC}"
if confirm_install "GIMP"; then
	sudo apt install gimp
fi

if confirm_install "Krita"; then
	sudo apt install krita
fi

if confirm_install "Audacity"; then
	sudo apt install audacity
fi

if confirm_install "Blender"; then
	sudo apt install blender
fi

# Install messaging apps
echo -e "${BOLD_YELLOW}entering messaging apps section${NC}"
if confirm_install "Discord"; then
	sudo snap install discord
fi

if confirm_install "Telegram"; then
	sudo apt install telegram-desktop
fi

if confirm_install "Signal"; then
# 1. Install our official public software signing key:
	wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
	cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

# 2. Add our repository to your list of repositories:
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' |\
 	 sudo tee /etc/apt/sources.list.d/signal-xenial.list

# 3. Update your package database and install Signal:
	sudo snap install signal-desktop
fi

# Install games
echo -e "${BOLD_YELLOW}entering games section${NC}"
if confirm_install "0 A.D."; then
	sudo add-apt-repository ppa:wfg/0ad
	sudo apt-get update
	sudo apt-get install 0ad
fi

echo -e "${BOLD_GREEN}All selected programs and packages have been installed.${NC} ${BLACK}Except if there were any errors,${BOLD_BLACK} i dunno i dont keep track of that.${NC}"
echo -e "${BOLD_GREEN}Enjoy!${NC}"
