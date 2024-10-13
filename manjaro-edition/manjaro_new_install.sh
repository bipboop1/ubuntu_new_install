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
SECT=0 # section number for skipping

# Function to display full list of programs and packages
full_list_menu()
{
	echo -e "${BOLD_YELLOW}This is the list of all programs and packages to be installed. Select a section number to skip to.${NC}"
}

# Function to display list of sections and skip
skip_to_section()
{
	echo -e "${BOLD_YELLOW}This is the list of sections.
	Select a section number to skip to, or type \"list\" to see the list of all programs.${NC}"
	echo -e "${BOLD_YELLOW}
	1.Update apt and apt_get
	2.Essential packages and dev
	3.42 school stuff
	4.General purpose programs
	5.Torrents and downloads
	6.Graphics and creation programs
	7.Messaging apps
	8.Games
	${NC}"
	read choice
	let SECT=$(($choice + 0))
}

# Function to set 42 logins in the header
set42intra()
{
	echo -e "${BOLD_YELLOW}Enter your 42 login: ${NC}"
	read login
	echo "USER=$login" >> ~/.zshrc
	echo "MAIL=$login@student.42.fr" >> ~/.zshrc
}

# Function to confirm update/upgrade of apt/apt-get
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
		echo -e "${BOLD_RED}Invalid answer. Use y/n/yes/no.${NC}"
		confirm_update $pkg_name
	fi
}

# Function to confirm installation of package
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
		echo -e "${BOLD_RED}Invalid aswer. Use y/n/yes/noy${NC}"
		confirm_install $pkg_name
	fi
}

# intro
sleep 2
echo -e "${BOLD_CYAN}
				.---------------.
				| welcome to my |
				'---------------'"
echo -e "${CYAN}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄
██ ██ █ ▄▄▀█ ██ █ ▄▄▀█▄ ▄█ ██ ███▀▄▄▀█ █▀█ ▄▄▄████▄██ ▄▄▀█ ▄▄█▄ ▄█ ▄▄▀█ ██ ██ ▄▄█ ▄▄▀██
██ ██ █ ▄▄▀█ ██ █ ██ ██ ██ ██ ███ ▀▀ █ ▄▀█ █▄▀████ ▄█ ██ █▄▄▀██ ██ ▀▀ █ ██ ██ ▄▄█ ▀▀▄██
██▄▀▀▄█▄▄▄▄██▄▄▄█▄██▄██▄███▄▄▄███ ████▄█▄█▄▄▄▄███▄▄▄█▄██▄█▄▄▄██▄██▄██▄█▄▄█▄▄█▄▄▄█▄█▄▄██
▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀

			   .--------------------.
			   | manjaro edition ;) |
			   '--------------------'


${NC}"

# menu
echo -e "${BOLD_CYAN}Would you like to use the full program, or skip to a specific section?${NC}"
echo -e "1.full program		2.skip to section		3.see full list		0.exit program"
read choice
if [ "$choice" = "1" ]; then
	echo -e "${BOLD_YELLOW}Launching full installer.${NC}"
elif [ "$choice" = "2" ]; then
	skip_to_section
elif [ "$choice" = "3" ]; then
	full_list_menu
elif [ "$choice" = "0" ]; then
	echo -e "${BOLD_YELLOW}Exiting program.${NC}"
	exit 0
else
	echo -e "${BOLD_RED}Invalid answer. Launching full installer.${NC}"
fi

# package manager selection
echo -e "${BOLD_CYAN}What is your package manager?${NC}"
read pkg_manager

# Update and upgrade the system
#if [ $SECT <= 1 ]; then
	echo -e "${BOLD_YELLOW}updating and upgrading the system${NC}"
	if confirm_update "apt"; then
		sudo apt update
		sudo apt upgrade
	fi	

	if confirm_update "apt-get"; then
		sudo apt-get update
		sudo apt-get upgrade
	fi

	if confirm_update "pamac"; then
		sudo pamac update
		sudo pamac upgrade
	fi
	echo -e "${YELLOW}apt/apt-get/pamac are now up to date.${NC}"
#fi

# Install essential packages and development
#if [ $SECT <= 2 ]; then
	echo -e "\n\n${BOLD_YELLOW}entering essential packages and development section${NC}\n"
	if confirm_install "curl"; then
	    sudo $pkg_manager install curl
	fi

	if confirm_install "git"; then
	    sudo $pkg_manager install git
	fi

	if confirm_install "zsh"; then
	    sudo $pkg_manager install zsh
	fi
#fi

# Install Oh My Zsh and set it as the default shell
echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW}Setting zsh as default shell will close this program. You'll have to restart the script.${NC}"
if confirm_install "Oh My Zsh"; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    sudo chsh -s $(which zsh) $(whoami)
fi

if confirm_install "vim"; then
    sudo $pkg_manager install vim
fi

if confirm_install "tree"; then
    sudo $pkg_manager install tree
fi

if confirm_install "clang"; then
    sudo $pkg_manager install clang
fi

if confirm_install "python3"; then
	sudo $pkg_manager install python3
fi

if confirm_install "pip"; then
	sudo $pkg_manager install python-pip
fi

echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} installing pip3 removes pip, i guess${NC}"
if confirm_install "pip3"; then
    sudo $pkg_manager install python3-pip
fi

#if confirm_install "python"; then
#	sudo $pkg_manager install python
#fi

echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} next pkg is using apt-get.${NC}"
if confirm_install "wget"; then
	sudo apt-get install wget
fi

# Install Visual Studio Code via Snap
echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} next pkg is using snap.${NC}"
if confirm_install "Visual Studio Code (ubuntu)"; then
    sudo snap install --classic code
fi

# Install Visual Studio Code via flatpak
echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} next pkg is using flatpak.${NC}"
if confirm_install "Visual Studio Code (manjaro)"; then
    sudo flatpak install com.visualstudio.code
fi

if confirm_install "Arduino IDE"; then
	sudo $pkg_manager install arduino
fi

# Install 42 school stuff
echo -e "\n\n${BOLD_YELLOW}entering 42 school stuff section${NC}\n"
if confirm_install "gcc"; then
    sudo $pkg_manager install gcc
fi

if confirm_install "make"; then
    sudo $pkg_manager install make
fi

if confirm_install "valgrind"; then
    sudo $pkg_manager install valgrind
fi

if confirm_install "cmake"; then
    sudo $pkg_manager install cmake
fi

if confirm_install "42 header"; then
	wget -qO ~/.vim/plugin https://raw.githubusercontent.com/42Paris/42header/71e6a4df6d72ae87a080282bf45bb993da6146b2/plugin/stdheader.vim
	echo -e "${BOLD_YELLOW}Set your header login now?${NC}"
	read choice
	if [ "$choice" = "y" ] || [ "$choice" = "yes" ]; then
		set42intra
	fi
fi

#if confirm_install "norminette"; then
#	curl -o norminette.deb -L
#fi

# General purpose programs
echo -e "\n\n${BOLD_YELLOW}entering general purpose section${NC}\n"

# Install Brave browser
if confirm_install "Brave browser"; then
    sudo $pkg_manager install brave-browser
fi

if confirm_install "VLC"; then
    sudo $pkg_manager install vlc
fi

if confirm_install "MPV"; then
    sudo $pkg_manager install mpv
fi

if confirm_install "ffmpeg"; then
	sudo $pkg_manager install ffmpeg
fi

# Install torrenting stuff
echo -e "\n\n${BOLD_YELLOW}entering torrents and downloads section${NC}\n"

if confirm_install "Transmission"; then
	sudo $pkg_manager install transmission
fi

if confirm_install "qBittorrent"; then
	sudo $pkg_manager install qbittorrent
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
echo -e "\n\n${BOLD_YELLOW}entering graphics programs section${NC}\n"
if confirm_install "GIMP"; then
	sudo $pkg_manager install gimp
fi

if confirm_install "Krita"; then
	sudo $pkg_manager install krita
fi

if confirm_install "Audacity"; then
	sudo $pkg_manager install audacity
fi

if confirm_install "Blender"; then
	sudo $pkg_manager install blender
fi

# Install messaging apps
echo -e "\n\n${BOLD_YELLOW}entering messaging apps section${NC}\n"

if confirm_install "Telegram"; then
	sudo $pkg_manager install telegram-desktop
fi

echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} next pkg is using wget, tee and snap.${NC}"
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

echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} next pkg is using snap.${NC}"
if confirm_install "Discord"; then
	sudo snap install discord
fi

# Install games
echo -e "\n\n${BOLD_YELLOW}entering games section${NC}\n"
echo -e "${BOLD_RED}WARNING: ${BOLD_YELLOW} next pkg is using apt-get.${NC}"
if confirm_install "0 A.D."; then
	sudo add-apt-repository ppa:wfg/0ad
	sudo apt-get update
	sudo apt-get install 0ad
fi

echo -e "\n\n${BOLD_GREEN}All selected programs and packages have been installed.${NC} ${BLUE}Except if there were any errors, i dunno i dont keep track of that.${NC}"
echo -e "${BOLD_GREEN}
	.--------.
	| Enjoy! |
	'--------'
	${NC}"
	sleep 9
