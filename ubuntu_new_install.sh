#!/bin/bash

# Update and upgrade the system
echo "update and upgrade the system"
sudo apt update
sudo apt upgrade
sudo apt-get update
sudo apt-get upgrade

# Function to confirm installation
confirm_install()
{
    read -p "Do you want to install $1? (y/n): " choice
    if [ "$choice" = "y"  ]; then
        return 0
	elif [ "$choice" = "yes" ]; then
		return 0
	elif [ "$choice" = "n" ]; then
		return 1
	elif [ "$choice" = "no" ]; then
		return 1
	else
		echo "Invalid choice. Please try again."
		confirm_install $1
	fi
}

# Install essential packages and development
echo "entering essential packages and development section"
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

if confirm_install "python"; then
	sudo apt install python
fi

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
echo "entering 42 school stuff section"
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
echo "entering general purpose section"

# Install Brave browser
if confirm_install "Brave browser"; then
    sudo apt install brave-browser
fi

# Install VLC and MPV
if confirm_install "VLC"; then
    sudo apt install vlc
fi

if confirm_install "MPV"; then
    sudo apt install mpv
fi

# Install graphics and creation programs
echo "entering graphics programs section"
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
echo "entering messaging apps section"
if confirm_install "Discord"; then
	sudo snap install discord
fi

if confirm_install "Telegram"; then
	sudo apt install telegram-desktop
fi

if confirm_install "Signal"; then
	sudo apt install signal-desktop
fi

# Install games
echo "entering games section"
if confirm_install "0 A.D."; then
	sudo add-apt-repository ppa:wfg/0ad
	sudo apt-get update
	sudo apt-get install 0ad
fi

echo "All programs and packages have been installed."
