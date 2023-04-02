#!/usr/bin/env bash
#  _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By      - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github  - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|
# Made for Arch Linux

##--> Usage <--##
	# Usage: ./Fresh-Install.sh [Options...] <url>
	#  -a, --arch           Install Arch Linux using Arch-I.
	#  -d, --dots           Install various config files
	#  -g, --grub           Install GRUB Theme
	#  -n, --nvim           Install only configs Related to Neovim
	#  -r, --deps           Install all the dependencies
	#  -s, --st             Install only configs Related to st
	#  -w, --wall           Install Wallpapers
	#  -z, --zsh            Install zsh configs

	### Calling directly inside terminal
	# curl -sL https://bit.ly/Fresh-Install | sh -s -- <flags>

##--> Main Entry Point of the script <--##
_mainScript_() {
	# _header_
    # _makeTempDir_ $SCRIPT_NAME

	if [ $# -gt 0 ]; then
		case "$1" in
		-a | --arch)
			_installArch_
			;;
		-v | --nvim)
			curl -sLO https://raw.githubusercontent.com/adityastomar67/Fresh-Install/master/nvim.sh && ./nvim.sh
			;;
		--LazyNV)
			_installLazyNV_
			;;
		-d | --dots)
			_installDots_
			;;
		-w | --wall)
			_setWallpaper_
			;;
		-z | --zsh)
			_installZsh_
			;;
		-g | --grub)
			_installGrub_
			;;
		-r | --deps)
		    _installDeps_
			;;
		-h | --help)
			_usage_
			;;
		?)
			echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
			exit 1
			;;
		esac
	else
		echo "No args"
	fi

	[[ -d $SCRIPT_NAME ]] && rm -rf $SCRIPT_NAME

	echo "${green}Everything you asked is done. Enjoy your new setup!${reset}"
}

##--> Variables & Flags <--##
### Variables
SCRIPT_NAME="fresh-install"
export GITHUB_URL="https://www.github.com/adityastomar67"
DOTS_URL="$GITHUB_URL/.dotfiles.git"
PACKAGE_MANAGER=""

if [[ $(uname) == "Linux" ]]; then
	PACKAGE_MANAGER=""
	if [ -x "$(command -v pacman)" ]; then
		PACKAGE_MANAGER="sudo pacman -Sy "
	elif [ -x "$(command -v apt-get)" ]; then
		PACKAGE_MANAGER="sudo apt-get install "
	elif [ -x "$(command -v dnf)" ]; then
		PACKAGE_MANAGER="sudo dnf install "
	elif [ -x "$(command -v zypper)" ]; then
		PACKAGE_MANAGER="sudo zypper install -n "
	elif [ -x "$(command -v emerge)" ]; then
		PACKAGE_MANAGER="emerge "
	fi
elif [[ $(uname) == "Darwin" ]]; then
	LIST_OF_APPS=($(ls "/bin")+$(ls "/usr/bin"))
	IFS="|"
	if [[ "${IFS}"${LIST_OF_APPS[*]}"${IFS}" =~ "${IFS}brew${IFS}" ]]; then
		echo "brew is not installed"
		echo "Installing brew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	else
		echo "brew, is installed. Checking next dependency.."
	fi
	PACKAGE_MANAGER="brew install "
fi

### Colors
if tput setaf 1 &>/dev/null; then
	export bold=$(tput bold)
	export white=$(tput setaf 7)
	export reset=$(tput sgr0)
	export purple=$(tput setaf 171)
	export red=$(tput setaf 1)
	export green=$(tput setaf 76)
	export tan=$(tput setaf 3)
	export yellow=$(tput setaf 3)
	export blue=$(tput setaf 38)
	export underline=$(tput sgr 0 1)
else
	export bold="\033[4;37m"
	export white="\033[0;37m"
	export reset="\033[0m"
	export purple="\033[0;35m"
	export red="\033[0;31m"
	export green="\033[1;32m"
	export tan="\033[0;33m"
	export yellow="\033[0;33m"
	export blue="\033[0;34m"
	export underline="\033[4;37m"
fi

##--> Functionalities <--##
_makeTempDir_() {
	[ -d "${tmpDir:-$1}" ] && return 0

	if [ -n "${1-}" ]; then
		tmpDir="${TMPDIR:-/tmp/}${1}"
	else
		tmpDir="${TMPDIR:-/tmp/}$(basename "$0")"
	fi
	(umask 077 && mkdir -p "${tmpDir}") || {
		echo "${red}Could not create temporary directory! Exiting.${reset}"
	}
}

_clone_() {
	if [ $# -gt 1 ]; then
		if [ -d "$2" ]; then
			# TODO: Create error command
			# error "Directory $2 already exists"
			return
		fi
		git clone --quiet "$1" "$2"
	else
		git clone --quiet "$1"
	fi
}

_pkgInstall_() {
	LIST_OF_APPS=($(ls "/bin")+$(ls "/usr/bin"))
	IFS="|"
	if [[ "${IFS}"${LIST_OF_APPS[*]}"${IFS}" =~ "${IFS}$2${IFS}" ]]; then
		echo "$1, is installed. Checking next dependency..."
	else
		echo "$1 is not installed."
		$PACKAGE_MANAGER $1
	fi
}

_usage_() {
	cat <<EOF
  Usage: ./${bold}$(basename "$0") [OPTION]... <url>${reset}
  This is a environment setup script that eases up the configuration part of the new OS installation.

  ${bold}Options:${reset}
    -a, --arch           Install Arch Linux using Arch-I.
    -d, --dots           Install various config files.
    -g, --grub           Install GRUB Theme.
	-h, --help           Show Usage/help.
    -n, --nvim           Install only configs Related to Neovim.
	-r, --deps           Install all the dependencies
	-s, --st             Install only configs Related to st
    -m, --menu           Show other options.
    -w, --wall           Install Wallpapers.

EOF
}

_header_() {
    clear
    printf "%${COLUMNS}s\n" "███████╗██████╗ ███████╗ ██████╗██╗  ██╗      ██╗███╗  ██╗ ██████╗████████╗ █████╗ ██╗     ██╗         ██████╗██╗  ██╗"
    printf "%${COLUMNS}s\n" "██╔════╝██╔══██╗██╔════╝██╔════╝██║  ██║      ██║████╗ ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║        ██╔════╝██║  ██║"
    printf "%${COLUMNS}s\n" "█████╗  ██████╔╝█████╗  ╚█████╗ ███████║█████╗██║██╔██╗██║╚█████╗    ██║   ███████║██║     ██║        ╚█████╗ ███████║"
    printf "%${COLUMNS}s\n" "██╔══╝  ██╔══██╗██╔══╝   ╚═══██╗██╔══██║╚════╝██║██║╚████║ ╚═══██╗   ██║   ██╔══██║██║     ██║         ╚═══██╗██╔══██║"
    printf "%${COLUMNS}s\n" "██║     ██║  ██║███████╗██████╔╝██║  ██║      ██║██║ ╚███║██████╔╝   ██║   ██║  ██║███████╗███████╗██╗██████╔╝██║  ██║"
    printf "%${COLUMNS}s\n" "╚═╝     ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝      ╚═╝╚═╝  ╚══╝╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝"
    printf "%${COLUMNS}s\n" "                                                 █▄▄ █▄█   ▄▄   ▄▀█ █▀▄ █ ▀█▀ █▄█ ▄▀█ █▀ ▀█▀ █▀█ █▀▄▀█ ▄▀█ █▀█ █▄▄ ▀▀█"
    printf "%${COLUMNS}s\n" "                                                 █▄█  █         █▀█ █▄▀ █  █   █  █▀█ ▄█  █  █▄█ █ ▀ █ █▀█ █▀▄ █▄█   █"
}

##--> Configurations <--##
_installZsh_() {
	echo "${blue}${bold}Installing ZSH Configs...${reset}"

	[[ $SHELL != *zsh ]] && echo "${yellow}This is meant to be used with ZSH Shell${reset}"

    if ! cat /etc/shells | grep -qE "\/bin\/zsh"; then
        echo "${red}ZSH Shell not Installed${reset}"
        echo "${yellow}Installing ZSH Shell..."
		_pkgInstall_ "zsh"
        sleep 1
	fi

    [ -d "$HOME/.config/.zsh" ] && rm -rf "$HOME/.config/.zsh"
    [ -d "$HOME/.oh-my-zsh" ]   && rm -rf "$HOME/.oh-my-zsh"
    [ -d "$HOME/.zinit" ]       && rm -rf "$HOME/.zinit"
    [ -f "$HOME/.zshrc" ]       && rm -rf "$HOME/.zshrc"

    _clone_ "$GITHUB_URL/.dotfiles.git" "$tmpDir/dots"
    cp -r "$tmpDir/dots/.zsh" "$HOME/.config/.zsh"
    chsh -s /usr/bin/zsh
    source "$HOME/.config/.zsh/.zshrc"
}

_installGrub_() {
	# local TYPE
    _clone_ "https://github.com/AllJavi/tartarus-grub.git" "/tmp/GRUB/tartarus" && sudo cp -r /tmp/GRUB/tartarus/tartarus /usr/share/grub/themes/
	_clone_ "https://github.com/catppuccin/grub.git" "/tmp/GRUB/catppuccin"     && sudo cp -r /tmp/GRUB/catppuccin/src/* /usr/share/grub/themes/

	echo "Which GRUB Theme you want?: "
    select typ in "catppuccin-latte" "catppuccin-frappe" "catppuccin-macchiato" "catppuccin-mocha" "tartarus"; do
        if [ $typ ]; then
            break
        fi
    done

	if [[ $typ == "tartarus" ]]; then
		THEME="GRUB_THEME='/usr/share/grub/themes/$typ/theme.txt'"
		sudo sed -r -i "s/GRUB_THEME=\"([/.-][a-z]\w+)*\"/$THEME/" /etc/default/grub
	else
		THEME="GRUB_THEME='/usr/share/grub/themes/$typ-grub-theme/theme.txt'"
		sudo sed -r -i "s/GRUB_THEME=\"([/.-][a-z]\w+)*\"/$THEME/" /etc/default/grub
	fi

	sudo grub-mkconfig -o /boot/grub/grub.cfg
}


_installLazyNV_() {
	NEOVIM_DIR=$HOME/.config/nvim
	export NEOVIM_DIR

	## Back up current config
	echo "Backin up current config..." && sleep 2
	[ -d "$NEOVIM_DIR.backup" ] && rm -rf "$NEOVIM_DIR.backup"
	[ -d $NEOVIM_DIR ] && mv $NEOVIM_DIR "$NEOVIM_DIR.backup"

	## Optional but recommended
	echo "Removing old cache..." && sleep 2
	[ -d "$HOME/.local/share/nvim" ] && rm -rf "$HOME/.local/share/nvim"
	[ -d "$HOME/.local/state/nvim" ] && rm -rf "$HOME/.local/state/nvim"
	[ -d "$HOME/.cache/nvim" ]       && rm -rf "$HOME/.cache/nvim"

	# Create config directory
	mkdir -p $NEOVIM_DIR
	git clone https://github.com/adityastomar67/LazyNV.git $NEOVIM_DIR

	## Run Neovim for the initial setup
	cd $HOME && nvim
}

_installST_() {
	echo "${blue}${bold}Installing Suckless Terminal...${reset}"

	_clone_ "$GITHUB_URL/.dotfiles.git" "$tmpDir/dots"
    cp -r "$tmpDir/dots/.config/st" "$HOME/.config/st"

    cd "$HOME/.config/st" || return

	sudo make clean install
	xrdb merge ./xresources

	if [ -f "$HOME/.temp_src" ]; then
		echo 'alias rel="xrdb merge pathToXresourcesFile && kill -USR1 $(pidof st)"' >> $HOME/.temp_src
	fi
}

_installDots_() {
	## Checking if Stow is Installed
	_pkgInstall_ "stow"
	_clone_ "$GITHUB_URL/.dotfiles.git" $HOME

	## Making Backups
	list="$HOME/.dotfiles/bin/file.txt"
	while IFS= read -r item; do
		mv "$item" "$item.backup"
	done <"$list"

	## Stowing dots
	cd "$HOME/.dotfiles" || exit
	stow .
}

_setWallpaper_() {
	URL="$GITHUB_URL/Wallpapers.git"
	CUR_DIR=$(pwd)
	_pkgInstall_ "feh"
	echo "Checkout Wallpapers @ ${underline}\"$URL\"${reset}"

	# Check if the directory exists already and delete it
	[ -d "$HOME/.config/wall" ] && rm -rf ~/.config/wall

	_clone_ $URL "$HOME/.config/wall/"
	COUNT=$(/usr/bin/ls $HOME/.config/wall | wc -l)

	# Move all the static wallpapers to `wall` directory and select the files with .png extension
	cd "$HOME/.config/wall" || exit
	mv $HOME/.config/wall/Static/* $HOME/.config/wall/.
	/usr/bin/ls | grep "wall[0-9]*.png" > list.txt

	# Move all the .png files to .jpg
	list="./list.txt"
	while IFS= read -r file ; do
	mv -- "$file" "${file%.png}.jpg"
	done < "$list"

	echo "Set random wallpaper or choose one?: "
    select wall in "choose" "random"; do
        if [ $wall ]; then
            break
        fi
    done

	if [ $wall == "random" ]; then
		count=$(command ls ~/.config/wall | grep -c "wall[0-9]*.jpg")
		feh --no-fehbg --bg-fill "$HOME/.config/wall/wall$((1 + RANDOM % $count)).jpg"
		echo "Random Wallpaper Applied!!"
	else
		read -p "Enter the number of wallpaper you wants to apply between 01 to $COUNT" WALL
		[ -f "$HOME/wall$WALL.jpg" ] && feh --no-fehbg --bg-fill "$HOME/wall$WALL.jpg"]
	fi

	# Remove unnecessary files and set wallpaper
	command rm -rf .git/ README.md Static list.txt

	cd $CUR_DIR
}

_installDeps_() {
	## Installing Basic Dependencies
	__basic_dep() {
		list="./requirements/list.pacman"
		while IFS= read -r app; do
			__pkg_install $app
		done <"$list"
	}

	## Installing Node Dependencies
	__node_dep() {
		list="./requirements/list.node"
		while IFS= read -r app; do
			npm i $app
		done <"$list"
	}

	## Installing Pip Dependencies
	__pip_dep() {
		list="./requirements/list.pip"
		while IFS= read -r app; do
			python3 -m pip install --user $app
		done <"$list"
	}

	## Installing Git Dependencies
	__git_dep() {
		list="./requirements/list.git"
		while IFS= read -r app; do
			${app}
		done <"$list"
	}

	## Calling Functions
	if [ $# -gt 0 ]; then
		case "$1" in
		-b)
			__basic_dep
			;;
		-n)
			__node_dep
			;;
		-g)
			__git_dep
			;;
		-p)
			__pip_dep
			;;
		-a)
			__basic_dep
			__git_dep
			__node_dep
			__pip_dep
			;;
		esac
	fi
}

##--> Arch Install Script <--##
_installArch_() {
	echo "Taking you to the${yellow}${bold}ARCH-I${reset}..."
	cd $HOME || exit
	curl -Lo arch_i.sh https://bit.ly/Arch-I
	chmod +x arch_i.sh
	./arch_i.sh
}

##--> Starting the execution <--##
_mainScript_ $1