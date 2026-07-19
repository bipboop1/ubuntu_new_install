#!/bin/bash
#
# manjaro_new_install.sh — an in-terminal installer for a fresh Manjaro box.
#
# No dialog/whiptail boxes: this draws menus directly in your terminal and
# redraws them in place (like a CLI tool), instead of scrolling the screen.

set -u

# ---------------------------------------------------------------------------
# Terminal / rendering engine
# ---------------------------------------------------------------------------

C_RESET=$(tput sgr0 2>/dev/null)
C_BOLD=$(tput bold 2>/dev/null)
C_DIM=$(tput dim 2>/dev/null)
C_CYAN=$(tput setaf 6 2>/dev/null)
C_GREEN=$(tput setaf 2 2>/dev/null)
C_YELLOW=$(tput setaf 3 2>/dev/null)
C_RED=$(tput setaf 1 2>/dev/null)
C_MAGENTA=$(tput setaf 5 2>/dev/null)
C_GRAY=$(tput setaf 8 2>/dev/null || tput setaf 7 2>/dev/null)
NL=$'\n'

PREV_LINES=0
COLS=$(tput cols 2>/dev/null || echo 80)

term_init()
{
	tput civis 2>/dev/null
}

term_cleanup()
{
	tput cnorm 2>/dev/null
	printf '%s' "$C_RESET"
}
trap term_cleanup EXIT INT TERM

# Redraws the given content in place, replacing whatever the previous
# render() call printed.
render()
{
	local content="$1"
	if [ "$PREV_LINES" -gt 0 ]; then
		printf '\033[%dA' "$PREV_LINES"
	fi
	printf '\033[J'
	printf '%s' "$content"
	PREV_LINES=$(printf '%s' "$content" | wc -l)
}

# Truncates a line to fit the terminal width (used for raw command output).
clip()
{
	local s="$1"
	local max=$(( COLS > 10 ? COLS - 4 : 76 ))
	if [ "${#s}" -gt "$max" ]; then
		echo "${s:0:max}…"
	else
		echo "$s"
	fi
}

# Reads a single keypress and prints a normalized token:
# UP DOWN LEFT RIGHT ENTER SPACE ESC BACKSPACE, or the literal character.
read_key()
{
	local k rest
	IFS= read -rsn1 k
	if [[ $k == $'\x1b' ]]; then
		IFS= read -rsn2 -t 0.05 rest
		case "$rest" in
			'[A') echo UP ;;
			'[B') echo DOWN ;;
			'[C') echo RIGHT ;;
			'[D') echo LEFT ;;
			*) echo ESC ;;
		esac
		return
	fi
	case "$k" in
		'') echo ENTER ;;
		' ') echo SPACE ;;
		$'\x7f'|$'\x08') echo BACKSPACE ;;
		*) echo "$k" ;;
	esac
}

# ---------------------------------------------------------------------------
# Generic UI widgets
# ---------------------------------------------------------------------------

# select_menu TITLE values_array labels_array [footer]
# Prints result value on stdout via SELECTED_VALUE. Returns 1 on cancel.
SELECTED_VALUE=""
select_menu()
{
	local title="$1"; local -n _v="$2"; local -n _l="$3"
	local footer="${4:-↑/↓ move    enter select    q quit}"
	local n=${#_v[@]}
	local cursor=0
	while true; do
		local frame="${C_BOLD}${C_MAGENTA}${title}${C_RESET}${NL}${NL}"
		local i
		for ((i = 0; i < n; i++)); do
			if [ "$i" -eq "$cursor" ]; then
				frame+="  ${C_CYAN}❯ ${_l[i]}${C_RESET}${NL}"
			else
				frame+="    ${C_DIM}${_l[i]}${C_RESET}${NL}"
			fi
		done
		frame+="${NL}${C_DIM}${footer}${C_RESET}${NL}"
		render "$frame"
		local key; key=$(read_key)
		case "$key" in
			UP) cursor=$(( (cursor - 1 + n) % n )) ;;
			DOWN) cursor=$(( (cursor + 1) % n )) ;;
			ENTER) SELECTED_VALUE="${_v[cursor]}"; return 0 ;;
			q|Q|ESC) return 1 ;;
		esac
	done
}

# checklist_menu TITLE tags_array labels_array states_array
# Result goes into SELECTED_TAGS array. Returns 1 on cancel/esc.
SELECTED_TAGS=()
checklist_menu()
{
	local title="$1"; local -n _tags="$2"; local -n _labels="$3"; local -n _states="$4"
	local n=${#_tags[@]}
	local cursor=0 i
	local -a sel=()
	for ((i = 0; i < n; i++)); do
		[ "${_states[i]}" = "on" ] && sel[i]=1 || sel[i]=0
	done
	while true; do
		local frame="${C_BOLD}${C_MAGENTA}${title}${C_RESET}${NL}${NL}"
		for ((i = 0; i < n; i++)); do
			local mark="${C_DIM}[ ]${C_RESET}"
			[ "${sel[i]}" = "1" ] && mark="${C_GREEN}[x]${C_RESET}"
			if [ "$i" -eq "$cursor" ]; then
				frame+="  ${C_CYAN}❯ ${mark} ${_labels[i]}${C_RESET}${NL}"
			else
				frame+="    ${mark} ${C_DIM}${_labels[i]}${C_RESET}${NL}"
			fi
		done
		frame+="${NL}${C_DIM}↑/↓ move   space toggle   enter confirm   esc back${C_RESET}${NL}"
		render "$frame"
		local key; key=$(read_key)
		case "$key" in
			UP) cursor=$(( (cursor - 1 + n) % n )) ;;
			DOWN) cursor=$(( (cursor + 1) % n )) ;;
			SPACE) [ "${sel[cursor]}" = "1" ] && sel[cursor]=0 || sel[cursor]=1 ;;
			ENTER)
				SELECTED_TAGS=()
				for ((i = 0; i < n; i++)); do
					[ "${sel[i]}" = "1" ] && SELECTED_TAGS+=("${_tags[i]}")
				done
				return 0 ;;
			ESC|q|Q) return 1 ;;
		esac
	done
}

# text_input PROMPT -> sets SELECTED_VALUE, returns 1 on esc
text_input()
{
	local prompt="$1"
	local buf=""
	while true; do
		local frame="${C_BOLD}${C_MAGENTA}${prompt}${C_RESET}${NL}${NL}"
		frame+="  ${C_CYAN}> ${buf}${C_RESET}${C_DIM}_${C_RESET}${NL}${NL}"
		frame+="${C_DIM}enter confirm   esc skip${C_RESET}${NL}"
		render "$frame"
		local key; key=$(read_key)
		case "$key" in
			ENTER) SELECTED_VALUE="$buf"; return 0 ;;
			ESC) return 1 ;;
			BACKSPACE) buf="${buf%?}" ;;
			UP|DOWN|LEFT|RIGHT) : ;;
			*) buf+="$key" ;;
		esac
	done
}

# msg_screen TITLE BODY -> waits for any key
msg_screen()
{
	local title="$1" body="$2"
	local frame="${C_BOLD}${C_MAGENTA}${title}${C_RESET}${NL}${NL}${body}${NL}${NL}${C_DIM}press any key to continue${C_RESET}${NL}"
	render "$frame"
	read_key >/dev/null
}

# ---------------------------------------------------------------------------
# Bootstrap
# ---------------------------------------------------------------------------

LOGFILE="$HOME/manjaro_install_$(date +%Y%m%d_%H%M%S).log"
PKG_MANAGER=""
declare -a TASKS=()
declare -A TAG_DESC=()

detect_pkg_manager()
{
	if command -v pamac >/dev/null 2>&1 && command -v pacman >/dev/null 2>&1; then
		local vals=(pamac pacman) labels=("pamac (handles AUR too)" "pacman (official repos only)")
		if select_menu "Both pamac and pacman found. Which should be used?" vals labels; then
			PKG_MANAGER="$SELECTED_VALUE"
		else
			term_cleanup; exit 0
		fi
	elif command -v pamac >/dev/null 2>&1; then
		PKG_MANAGER="pamac"
	elif command -v pacman >/dev/null 2>&1; then
		PKG_MANAGER="pacman"
	else
		msg_screen "Error" "${C_RED}Neither pamac nor pacman were found. This script only supports Arch/Manjaro.${C_RESET}"
		term_cleanup; exit 1
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
# Section helpers
# ---------------------------------------------------------------------------

add_task()
{
	local tag="$1" t
	for t in "${TASKS[@]:-}"; do
		[ "$t" = "$tag" ] && return
	done
	TASKS+=("$tag")
}

show_section_checklist()
{
	local key="$1"
	local arr_name; arr_name=$(cat_array_name "$key")
	local -n items="$arr_name"

	local -a tags=() labels=() states=()
	local i
	for ((i = 0; i < ${#items[@]}; i += 3)); do
		tags+=("${items[i]}")
		labels+=("${items[i+1]}")
		states+=("${items[i+2]}")
		TAG_DESC["${items[i]}"]="${items[i+1]}"
	done

	if checklist_menu "$(cat_label "$key")" tags labels states; then
		local t
		for t in "${SELECTED_TAGS[@]:-}"; do
			[ -n "$t" ] && add_task "$t"
		done
	fi
}

show_full_list()
{
	local body="" key arr_name items i
	for key in "${CAT_KEYS[@]}"; do
		arr_name=$(cat_array_name "$key")
		local -n items="$arr_name"
		body+="${C_YELLOW}$(cat_label "$key")${C_RESET}${NL}"
		for ((i = 0; i < ${#items[@]}; i += 3)); do
			body+="   ${C_DIM}-${C_RESET} ${items[i+1]}${NL}"
		done
		body+="${NL}"
	done
	msg_screen "Full package list" "$body"
}

ask_42_login()
{
	if text_input "Enter your 42 login (esc to skip):"; then
		if [ -n "$SELECTED_VALUE" ]; then
			{
				echo "USER=$SELECTED_VALUE"
				echo "MAIL=$SELECTED_VALUE@student.42.fr"
			} >> ~/.zshrc
		fi
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

declare -a STATUS=()
declare -a TAIL=()
LINE_COUNT=0
SPIN_CHARS='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

draw_progress()
{
	local current="$1"
	local total=${#TASKS[@]}
	local frame="${C_BOLD}${C_MAGENTA}Installing selected packages${C_RESET}  ${C_DIM}($current/$total)${C_RESET}${NL}${NL}"
	local i
	for ((i = 0; i < total; i++)); do
		local icon label="${TAG_DESC[${TASKS[i]}]:-${TASKS[i]}}"
		case "${STATUS[i]}" in
			ok)      icon="${C_GREEN}✔${C_RESET}" ;;
			fail)    icon="${C_RED}✘${C_RESET}" ;;
			running) icon="${C_YELLOW}${SPIN_CHARS:$((LINE_COUNT % ${#SPIN_CHARS})):1}${C_RESET}" ;;
			*)       icon="${C_DIM}○${C_RESET}" ;;
		esac
		frame+="  $icon  ${label}${NL}"
	done
	if [ ${#TAIL[@]} -gt 0 ]; then
		frame+="${NL}${C_DIM}output:${C_RESET}${NL}"
		local l
		for l in "${TAIL[@]}"; do
			frame+="  ${C_GRAY}$(clip "$l")${C_RESET}${NL}"
		done
	fi
	render "$frame"
}

run_all_tasks()
{
	[ ${#TASKS[@]} -eq 0 ] && return

	# Oh My Zsh restarts the shell session, so it must run last.
	local reordered=() has_ohmyzsh=0 t
	for t in "${TASKS[@]}"; do
		if [ "$t" = "ohmyzsh" ]; then has_ohmyzsh=1; else reordered+=("$t"); fi
	done
	[ "$has_ohmyzsh" -eq 1 ] && reordered+=("ohmyzsh")
	TASKS=("${reordered[@]}")

	local total=${#TASKS[@]} i
	STATUS=()
	for ((i = 0; i < total; i++)); do STATUS[i]="pending"; done

	for ((i = 0; i < total; i++)); do
		local tag="${TASKS[i]}"
		STATUS[i]="running"
		TAIL=()
		draw_progress $((i + 1))

		# 42header needs to prompt for a login mid-task; do that first.
		if [ "$tag" = "42header" ]; then
			ask_42_login
		fi

		local exit_code=0 line
		while IFS= read -r line; do
			if [[ $line == __TASK_EXIT__* ]]; then
				exit_code="${line#__TASK_EXIT__}"
			else
				echo "$line" >> "$LOGFILE"
				LINE_COUNT=$((LINE_COUNT + 1))
				TAIL+=("$line")
				[ ${#TAIL[@]} -gt 6 ] && TAIL=("${TAIL[@]: -6}")
				draw_progress $((i + 1))
			fi
		done < <( { run_task "$tag"; printf '__TASK_EXIT__%d\n' "$?"; } 2>&1 )

		echo "===== $tag exited $exit_code =====" >> "$LOGFILE"
		if [ "$exit_code" -eq 0 ]; then STATUS[i]="ok"; else STATUS[i]="fail"; fi
		draw_progress $((i + 1))
	done
}

show_report()
{
	local body="${C_DIM}Log saved to: $LOGFILE${C_RESET}${NL}${NL}"
	local ok=0 fail=0 i
	for ((i = 0; i < ${#TASKS[@]}; i++)); do
		local label="${TAG_DESC[${TASKS[i]}]:-${TASKS[i]}}"
		if [ "${STATUS[i]}" = "ok" ]; then
			body+="  ${C_GREEN}✔${C_RESET} ${label}${NL}"
			ok=$((ok + 1))
		else
			body+="  ${C_RED}✘${C_RESET} ${label}${NL}"
			fail=$((fail + 1))
		fi
	done
	msg_screen "Done: ${ok} succeeded, ${fail} failed" "$body"
}

# ---------------------------------------------------------------------------
# Main menu flow
# ---------------------------------------------------------------------------

main_menu()
{
	while true; do
		local vals=(full categories list exit)
		local labels=(
			"Full install (go through every category)"
			"Choose specific categories"
			"View full package list"
			"Exit"
		)
		if ! select_menu "Manjaro New Install — what would you like to do?" vals labels; then
			term_cleanup; exit 0
		fi
		case "$SELECTED_VALUE" in
			full)
				local key
				for key in "${CAT_KEYS[@]}"; do
					show_section_checklist "$key"
				done
				return ;;
			categories)
				pick_categories
				return ;;
			list)
				show_full_list ;;
			exit)
				term_cleanup; exit 0 ;;
		esac
	done
}

pick_categories()
{
	local -a tags=() labels=() states=()
	local key
	for key in "${CAT_KEYS[@]}"; do
		tags+=("$key"); labels+=("$(cat_label "$key")"); states+=("off")
	done
	if checklist_menu "Choose categories" tags labels states; then
		local k
		for k in "${SELECTED_TAGS[@]:-}"; do
			[ -n "$k" ] && show_section_checklist "$k"
		done
	fi
}

confirm_and_run()
{
	if [ ${#TASKS[@]} -eq 0 ]; then
		msg_screen "Nothing selected" "${C_DIM}No packages were selected. Exiting.${C_RESET}"
		term_cleanup; exit 0
	fi

	local body="${C_BOLD}${C_MAGENTA}Confirm installation${C_RESET}${NL}${NL}About to install/run ${#TASKS[@]} item(s):${NL}${NL}"
	local t
	for t in "${TASKS[@]}"; do
		body+="  ${C_DIM}-${C_RESET} ${TAG_DESC[$t]:-$t}${NL}"
	done

	local vals=(yes no) labels=("Yes, install" "No, cancel")
	if ! select_menu "$body" vals labels; then
		term_cleanup; exit 0
	fi
	if [ "$SELECTED_VALUE" != "yes" ]; then
		term_cleanup; exit 0
	fi

	run_all_tasks
	show_report
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

term_init
detect_pkg_manager
main_menu
confirm_and_run

msg_screen "Enjoy!" "${C_GREEN}All done. Enjoy your new Manjaro setup!${C_RESET}"
term_cleanup
clear
