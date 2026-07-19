#!/bin/bash
#
# manjaro_new_install.sh — dialog-based TUI installer for a fresh Manjaro box.
#
# Requires: dialog (auto-installed via pacman if missing)

set -u

BACKTITLE="Manjaro New Install"
LOGFILE="$HOME/manjaro_install_$(date +%Y%m%d_%H%M%S).log"
RESULTS_FILE="$(mktemp)"
PKG_MANAGER=""
declare -a TASKS=()
declare -A TAG_DESC=()

trap 'rm -f "$RESULTS_FILE"' EXIT

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------

ensure_dialog()
{
	if command -v dialog >/dev/null 2>&1; then
		return
	fi
	echo "The 'dialog' package is required for this installer's UI."
	if command -v pacman >/dev/null 2>&1; then
		echo "Installing it now via pacman..."
		sudo pacman -S --noconfirm --needed dialog || {
			echo "Failed to install dialog. Aborting." >&2
			exit 1
		}
	else
		echo "pacman not found, cannot auto-install dialog. Aborting." >&2
		exit 1
	fi
}

detect_pkg_manager()
{
	if command -v pamac >/dev/null 2>&1 && command -v pacman >/dev/null 2>&1; then
		PKG_MANAGER=$(dialog --stdout --backtitle "$BACKTITLE" \
			--title "Package manager" \
			--menu "Both pamac and pacman were found. Which should be used for installs?" 12 60 2 \
			pamac  "Use pamac (handles AUR too)" \
			pacman "Use pacman (official repos only)")
		[ -z "$PKG_MANAGER" ] && exit 0
	elif command -v pamac >/dev/null 2>&1; then
		PKG_MANAGER="pamac"
	elif command -v pacman >/dev/null 2>&1; then
		PKG_MANAGER="pacman"
	else
		dialog --backtitle "$BACKTITLE" --title "Error" \
			--msgbox "Neither pamac nor pacman were found on this system. This script only supports Arch/Manjaro." 8 60
		exit 1
	fi
}

install_pkg()
{
	local pkg="$1"
	if [ "$PKG_MANAGER" = "pamac" ]; then
		sudo pamac install --no-confirm "$pkg"
	else
		sudo pacman -S --noconfirm --needed "$pkg"
	fi
}

# ---------------------------------------------------------------------------
# Section definitions: tag  description  default-state(on/off)
# ---------------------------------------------------------------------------

SEC_UPDATE=(
	sys_update "Update and upgrade the system" on
)

SEC_ESSENTIAL=(
	curl           "curl - command line data transfer"                          on
	git            "git - version control"                                      on
	zsh            "zsh - shell"                                                off
	ohmyzsh        "Oh My Zsh (sets zsh as default shell, restarts session)"     off
	vim            "vim - text editor"                                          off
	tree           "tree - directory listing tool"                              off
	clang          "clang - C/C++ compiler"                                     off
	python         "python (python3 + pip)"                                     off
	wget           "wget - downloader"                                          off
	snapd          "snapd - snap package support"                               off
	flatpak        "flatpak + libpamac-flatpak-plugin"                          off
	vscode_snap    "Visual Studio Code (via snap)"                              off
	vscode_flatpak "Visual Studio Code (via flatpak)"                           off
	cursor         "Cursor IDE (installs via upstream git script)"              off
	arduino        "Arduino IDE"                                                off
	timeshift      "Timeshift - system backups"                                 off
)

SEC_42=(
	gcc      "gcc"                                                     off
	make     "make"                                                    off
	valgrind "valgrind"                                                off
	cmake    "cmake"                                                   off
	42header "42 header (vim plugin, optional 42 login setup)"         off
)

SEC_GENERAL=(
	brave  "Brave browser" off
	vlc    "VLC media player" off
	mpv    "MPV media player" off
	ffmpeg "ffmpeg" off
)

SEC_TORRENTS=(
	transmission "Transmission" off
	qbittorrent  "qBittorrent" off
	yt-dlp       "yt-dlp (installed to /usr/local/bin)" off
	seedmage     "seedmage" off
)

SEC_GRAPHICS=(
	gimp     "GIMP" off
	krita    "Krita" off
	audacity "Audacity" off
	blender  "Blender" off
	msfonts  "MS core fonts (ttf-ms-fonts, AUR)" off
)

SEC_MESSAGING=(
	telegram "Telegram Desktop" off
	signal   "Signal Desktop (AUR via pamac, snap fallback)" off
	discord  "Discord (via snap)" off
)

SEC_GAMES=(
	0ad "0 A.D. strategy game" off
)

CAT_KEYS=(update essential 42school general torrents graphics messaging games)

cat_label()
{
	case "$1" in
		update)     echo "System Update" ;;
		essential)  echo "Essential Packages & Dev Tools" ;;
		42school)   echo "42 School Stuff" ;;
		general)    echo "General Purpose Programs" ;;
		torrents)   echo "Torrents & Downloads" ;;
		graphics)   echo "Graphics & Creation" ;;
		messaging)  echo "Messaging Apps" ;;
		games)      echo "Games" ;;
	esac
}

cat_array_name()
{
	case "$1" in
		update)     echo "SEC_UPDATE" ;;
		essential)  echo "SEC_ESSENTIAL" ;;
		42school)   echo "SEC_42" ;;
		general)    echo "SEC_GENERAL" ;;
		torrents)   echo "SEC_TORRENTS" ;;
		graphics)   echo "SEC_GRAPHICS" ;;
		messaging)  echo "SEC_MESSAGING" ;;
		games)      echo "SEC_GAMES" ;;
	esac
}

# ---------------------------------------------------------------------------
# UI helpers
# ---------------------------------------------------------------------------

add_task()
{
	local tag="$1"
	for t in "${TASKS[@]:-}"; do
		[ "$t" = "$tag" ] && return
	done
	TASKS+=("$tag")
}

# Shows a checklist for one section and appends chosen tags to TASKS.
show_section_checklist()
{
	local key="$1"
	local arr_name
	arr_name=$(cat_array_name "$key")
	local -n items="$arr_name"

	local menu_args=()
	local i tag desc state
	for ((i = 0; i < ${#items[@]}; i += 3)); do
		tag="${items[i]}"; desc="${items[i+1]}"; state="${items[i+2]}"
		TAG_DESC["$tag"]="$desc"
		menu_args+=("$tag" "$desc" "$state")
	done

	local selection
	selection=$(dialog --stdout --backtitle "$BACKTITLE" \
		--title "$(cat_label "$key")" \
		--separate-output \
		--checklist "SPACE to toggle, ENTER to confirm, ESC to skip this section" \
		22 78 14 "${menu_args[@]}")

	[ $? -ne 0 ] && return

	while IFS= read -r tag; do
		[ -n "$tag" ] && add_task "$tag"
	done <<< "$selection"
}

show_full_list()
{
	local text=""
	local key arr_name items i
	for key in "${CAT_KEYS[@]}"; do
		arr_name=$(cat_array_name "$key")
		local -n items="$arr_name"
		text+="$(cat_label "$key")\n"
		for ((i = 0; i < ${#items[@]}; i += 3)); do
			text+="   - ${items[i+1]}\n"
		done
		text+="\n"
	done
	dialog --backtitle "$BACKTITLE" --title "Full package list" \
		--msgbox "$(echo -e "$text")" 28 78
}

ask_42_login()
{
	local login
	login=$(dialog --stdout --backtitle "$BACKTITLE" --title "42 login" \
		--inputbox "Enter your 42 login (leave empty to skip):" 8 50)
	if [ -n "$login" ]; then
		{
			echo "USER=$login"
			echo "MAIL=$login@student.42.fr"
		} >> ~/.zshrc
	fi
}

# ---------------------------------------------------------------------------
# Task execution
# ---------------------------------------------------------------------------

run_task()
{
	local tag="$1"
	case "$tag" in
		sys_update)
			if [ "$PKG_MANAGER" = "pamac" ]; then sudo pamac update; else sudo pacman -Syu --noconfirm; fi ;;
		curl)     install_pkg curl ;;
		git)      install_pkg git ;;
		zsh)      install_pkg zsh ;;
		ohmyzsh)
			sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
				&& sudo chsh -s "$(command -v zsh)" "$(whoami)" ;;
		vim)      install_pkg vim ;;
		tree)     install_pkg tree ;;
		clang)    install_pkg clang ;;
		python)   install_pkg python && install_pkg python-pip ;;
		wget)     install_pkg wget ;;
		snapd)    install_pkg snapd ;;
		flatpak)  install_pkg flatpak && install_pkg libpamac-flatpak-plugin ;;
		vscode_snap)    sudo snap install --classic code ;;
		vscode_flatpak) sudo flatpak install -y flathub com.visualstudio.code ;;
		cursor)
			sudo pacman -Sy --noconfirm \
				&& sudo pacman -S --noconfirm --needed git curl bash \
				&& rm -rf /tmp/InstallCursorEditorLinux \
				&& git clone --depth=1 https://github.com/IsRengel/InstallCursorEditorLinux.git /tmp/InstallCursorEditorLinux \
				&& (cd /tmp/InstallCursorEditorLinux && ./install.sh) \
				&& rm -rf /tmp/InstallCursorEditorLinux ;;
		arduino)  install_pkg arduino ;;
		timeshift) install_pkg timeshift ;;
		gcc)      install_pkg gcc ;;
		make)     install_pkg make ;;
		valgrind) install_pkg valgrind ;;
		cmake)    install_pkg cmake ;;
		42header)
			mkdir -p ~/.vim/plugin \
				&& wget -qO ~/.vim/plugin/stdheader.vim \
					https://raw.githubusercontent.com/42Paris/42header/71e6a4df6d72ae87a080282bf45bb993da6146b2/plugin/stdheader.vim
			ask_42_login
			;;
		brave)    install_pkg brave-browser ;;
		vlc)      install_pkg vlc ;;
		mpv)      install_pkg mpv ;;
		ffmpeg)   install_pkg ffmpeg ;;
		transmission) install_pkg transmission-gtk ;;
		qbittorrent)  install_pkg qbittorrent ;;
		yt-dlp)
			sudo wget -qO /usr/local/bin/yt-dlp \
				https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
				&& sudo chmod a+rx /usr/local/bin/yt-dlp ;;
		seedmage)
			rm -rf /tmp/seedmage \
				&& git clone https://github.com/DimitriFourny/seedmage.git /tmp/seedmage \
				&& sudo install -m755 /tmp/seedmage/seedmage.py /usr/local/bin/seedmage \
				&& rm -rf /tmp/seedmage ;;
		gimp)     install_pkg gimp ;;
		krita)    install_pkg krita ;;
		audacity) install_pkg audacity ;;
		blender)  install_pkg blender ;;
		msfonts)  install_pkg ttf-ms-fonts ;;
		telegram) install_pkg telegram-desktop ;;
		signal)
			if [ "$PKG_MANAGER" = "pamac" ]; then
				sudo pamac install --no-confirm signal-desktop
			else
				sudo snap install signal-desktop
			fi ;;
		discord)  sudo snap install discord ;;
		0ad)      install_pkg 0ad ;;
		*) return 1 ;;
	esac
}

run_all_tasks()
{
	[ ${#TASKS[@]} -eq 0 ] && return

	# Oh My Zsh restarts the shell session, so it must run last.
	local reordered=() has_ohmyzsh=0
	for t in "${TASKS[@]}"; do
		if [ "$t" = "ohmyzsh" ]; then has_ohmyzsh=1; else reordered+=("$t"); fi
	done
	[ "$has_ohmyzsh" -eq 1 ] && reordered+=("ohmyzsh")
	TASKS=("${reordered[@]}")

	: > "$RESULTS_FILE"
	local total=${#TASKS[@]} count=0

	(
		for tag in "${TASKS[@]}"; do
			count=$((count + 1))
			echo $(( count * 100 / total ))
			echo "XXX"
			echo "[$count/$total] ${TAG_DESC[$tag]:-$tag}"
			echo "XXX"
			{
				echo "===== $tag: ${TAG_DESC[$tag]:-} ====="
				if run_task "$tag"; then
					echo "$tag:OK" >> "$RESULTS_FILE"
				else
					echo "$tag:FAIL" >> "$RESULTS_FILE"
				fi
			} >> "$LOGFILE" 2>&1
		done
	) | dialog --stdout --backtitle "$BACKTITLE" --title "Installing selected packages" \
		--gauge "Starting..." 8 70 0
}

show_report()
{
	local text="Log saved to: $LOGFILE\n\n"
	local ok=0 fail=0
	while IFS=: read -r tag status; do
		[ -z "$tag" ] && continue
		if [ "$status" = "OK" ]; then
			text+="  [OK]   ${TAG_DESC[$tag]:-$tag}\n"
			ok=$((ok + 1))
		else
			text+="  [FAIL] ${TAG_DESC[$tag]:-$tag}\n"
			fail=$((fail + 1))
		fi
	done < "$RESULTS_FILE"
	text="Done: $ok succeeded, $fail failed.\n\n$text"
	dialog --backtitle "$BACKTITLE" --title "Installation report" --msgbox "$(echo -e "$text")" 24 76
}

# ---------------------------------------------------------------------------
# Main menu flow
# ---------------------------------------------------------------------------

welcome_screen()
{
	dialog --backtitle "$BACKTITLE" --title "Welcome" --msgbox \
"  __  __            _
 |  \\/  | __ _ _ __ (_) __ _ _ __ ___
 | |\\/| |/ _\` | '_ \\| |/ _\` | '__/ _ \\
 | |  | | (_| | | | | | (_| | | | (_) |
 |_|  |_|\\__,_|_| |_|_|\\__,_|_|  \\___/

        New Install — Manjaro Edition

Pick and choose the software you want installed.
Use SPACE to select, ENTER to confirm, ESC to go back." 16 60
}

main_menu()
{
	while true; do
		local choice
		choice=$(dialog --stdout --backtitle "$BACKTITLE" --title "Main menu" \
			--menu "What would you like to do?" 15 62 4 \
			1 "Full install (go through every category)" \
			2 "Choose specific categories" \
			3 "View full package list" \
			0 "Exit")

		case "$choice" in
			1)
				for key in "${CAT_KEYS[@]}"; do
					show_section_checklist "$key"
				done
				break ;;
			2)
				pick_categories
				break ;;
			3)
				show_full_list ;;
			0|"")
				clear
				exit 0 ;;
		esac
	done
}

pick_categories()
{
	local menu_args=() key
	for key in "${CAT_KEYS[@]}"; do
		menu_args+=("$key" "$(cat_label "$key")" off)
	done

	local chosen
	chosen=$(dialog --stdout --backtitle "$BACKTITLE" --title "Choose categories" \
		--separate-output --checklist "Select which categories to configure" \
		18 66 8 "${menu_args[@]}")
	[ $? -ne 0 ] && return

	while IFS= read -r key; do
		[ -n "$key" ] && show_section_checklist "$key"
	done <<< "$chosen"
}

confirm_and_run()
{
	if [ ${#TASKS[@]} -eq 0 ]; then
		dialog --backtitle "$BACKTITLE" --title "Nothing selected" \
			--msgbox "No packages were selected. Exiting." 7 50
		clear
		exit 0
	fi

	local summary="" t
	for t in "${TASKS[@]}"; do
		summary+="  - ${TAG_DESC[$t]:-$t}\n"
	done

	dialog --backtitle "$BACKTITLE" --title "Confirm installation" \
		--yesno "$(echo -e "About to install/run ${#TASKS[@]} item(s):\n\n$summary")" 24 74
	if [ $? -ne 0 ]; then
		clear
		exit 0
	fi

	run_all_tasks
	show_report
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

ensure_dialog
detect_pkg_manager
welcome_screen
main_menu
confirm_and_run

dialog --backtitle "$BACKTITLE" --title "Enjoy!" \
	--msgbox "All done. Enjoy your new Manjaro setup!" 7 45
clear
