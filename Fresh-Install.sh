#!/usr/bin/env bash
#  _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By      - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github  - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|
# Made for Arch Linux

# TODO: Functionality to imply yes to all questions
# TODO : Functionality to install packages from a file

# source ./bin/usage.sh

# Directories
mkdir -p /tmp/fresh-install

# Variaables
TEMP_DIR="/tmp/fresh-install"
NVIM_DIR="$HOME/.config/nvim"
GITHUB="https://www.github.com/adityastomar67"

[ -d $TEMP_DIR ] && rm -rf $TEMP_DIR

## Selection for Package Manager
if [[ $(uname) == "Linux" ]]; then
	PACKAGE_MANAGER=""
	if [ -x "$(command -v pacman)" ]; then
		PACKAGE_MANAGER="pacman"
	elif [ -x "$(command -v apt-get)" ]; then
		PACKAGE_MANAGER="apt-get"
	elif [ -x "$(command -v dnf)" ]; then
		PACKAGE_MANAGER="dnf"
	elif [ -x "$(command -v zypper)" ]; then
		PACKAGE_MANAGER="zypper"
	elif [ -x "$(command -v emerge)" ]; then
		PACKAGE_MANAGER="emerge"
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
	PACKAGE_MANAGER="brew"
fi

_cleanup() {
	[[ -d $TEMP_DIR ]] && rm -rf $TEMP_DIR
}

_print() {
	if [[ $(command -v gum) ]]; then
		echo $1 $2 | xargs gum
	else
		echo $2
	fi
}

__pkg_install() {
	LIST_OF_APPS=($(ls "/bin")+$(ls "/usr/bin"))
	IFS="|"
	if [[ "${IFS}"${LIST_OF_APPS[*]}"${IFS}" =~ "${IFS}$2${IFS}" ]]; then
		echo "$1, is installed. Checking next dependency..."
	else
		echo "$1 is not installed."
		echo "Installing $1"
		if [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
			sudo pacman -Sy "$1" --noconfirm
		elif [[ "$PACKAGE_MANAGER" =~ "apt-get" ]]; then
			sudo apt update
			sudo apt install "$1" -y
		elif [[ "$PACKAGE_MANAGER" =~ "dnf" ]]; then
			sudo dnf update -y
			sudo dnf install "$1" -y
		elif [[ "$PACKAGE_MANAGER" =~ "zypper" ]]; then
			sudo zypper ref
			sudo zypper install -n "$1"
		elif [[ "$PACKAGE_MANAGER" =~ "emerge" ]]; then
			emerge "$1"
		elif [[ "$PACKAGE_MANAGER" =~ "brew" ]]; then
			brew install "$1"
		fi
	fi
}

## Git Cloneing
__clone() {
	if [ -d "$2" ]; then
		echo "Directory $2 already exists"
		return
	fi
	git clone --quiet "$1" "$2"
}

## Check wether the go is installed or not
if [[ ! $(command -v go) ]]; then
	echo >&2 "Script require Go but it's not installed."
	read -p "Continue to install Go or Abort? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	CMD="curl -s https://go.dev/doc/install | grep \"rm -rf\" | sed -E 's/(\$ |<[\/a-zA-Z =\"-]*>)//g'"
	sudo sh "$CMD"
fi

## Installing Charmbracelet/gum for beautiful UI
if [[ ! $(command -v gum) ]]; then
	go install github.com/charmbracelet/gum@latest
fi

### HEADER
_Header() {
	gum style --foreground 212 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" 'Fresh Install' 'By - adityastomar67'
}

_Install_Dependencies() {
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
			__pkg_install $app
		done <"$list"
	}

	## Installing Pip Dependencies
	__pip_dep() {
		list="./requirements/list.pip"
		while IFS= read -r app; do
			__pkg_install $app
		done <"$list"
	}

	## Installing Git Dependencies
	__git_dep() {
		list="./requirements/list.git"
		while IFS= read -r app; do
			__pkg_install $app
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

_Install_ZSH() {
	_print "style --foreground 202 --border-foreground 114 --border rounded --align center --width 40 --margin \"0 2\" --padding \"1 2\"" "Installing ZSH Configs..."

	[[ $SHELL != *zsh ]] && gum style --foreground 202 --border none 'This is meant to be used with ZSH Shell'
	! cat /etc/shells | grep -qE "\/bin\/zsh" && gum style --foreground 202 --border none 'ZSH Shell not Installed' && cnfrm=$(gum confirm "Do You Want to install ZSH SHELL?")

	if [[ $cnfrm ]]; then
		__pkg_install zsh
	fi

	[ -d "$HOME/zsh" ] && rm -rf "$HOME/zsh"
	[ -d "$HOME/.oh-my-zsh" ] && rm -rf "$HOME/.oh-my-zsh"
	[ -d "$HOME/.zinit" ] && rm -rf "$HOME/.zinit"
	[ -f "$HOME/.zshrc" ] && rm -rf "$HOME/.zshrc"

	__clone "https://github.com/adityastomar67/.dotfiles.git" "$TEMP_DIR/dots"
	cp -r "$TEMP_DIR/dots/zsh" "$HOME/zsh"
	source "$HOME/zsh/.zshrc"
}

_Install_GRUB() {
	__clone "https://github.com/catppuccin/grub.git" "/tmp/repos" && cd "/tmp/repos/" || exit
	sudo cp -r src/* /usr/share/grub/themes/

	TYPE=$(gum choose "catppuccin-latte" "catppuccin-frappe" "catppuccin-macchiato" "catppuccin-mocha")
	THEME="GRUB_THEME='/usr/share/grub/themes/$TYPE-grub-theme/theme.txt'"
	sed -r -i "s/GRUB_THEME=\"([/.-][a-z]\w+)*\"/$THEME/" /etc/default/grub

	sudo grub-mkconfig -o /boot/grub/grub.cfg
}

_Install_Dots() {
	## Checking if Stow is Installed
	if [[ ! $(command -v stow) ]]; then
		sudo pacman -S stow --noconfirm
	fi

	## Making Backups
	list="./bin/text.txt"
	while IFS= read -r item; do
		mv "$item" "$item.backup"
	done <"$list"

	## Stowing dots
	cd "$HOME/.dotfiles" || exit
	stow .
}

_Install_Neovim() {
	gum style --foreground 202 --border-foreground 114 --border rounded --align center --width 40 --margin "0 2" --padding "1 2" 'Installing Neovim...'

	## Checking if Neovim is Installed
	if [[ ! $(command -v nvim) ]]; then
		gum style --foreground 202 --border none 'Choose between :'
		NVIM_VERSION=$(gum choose "Stable" "Nightly")
		printf "\nInstalling %s version...\n" "$NVIM_VERSION"

		if [[ "$NVIM_VERSION" == "Stable" ]]; then
			mkdir -p ~/tmp
			cd ~/tmp || exit
			curl -sLO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
			sudo chmod u+x nvim.appimage
			./nvim.appimage --appimage-extract
			./squashfs-root/AppRun --version
			sudo mv squashfs-root /
			sudo mv /squashfs-root/AppRun /usr/bin/nvim
			elsehttps://github.com/adityastomar67/nvdots
			mkdir -p ~/tmp
			cd ~/tmp || exit
			git clone --quiet --depth 1 --branch nightly https://github.com/neovim/neovim.git
			cd neovim || exit
			make CMAKE_BUILD_TYPE=RelWithDebInfo
			sudo make install
		fi
	else
		gum style --foreground 202 --border none 'Neovim is already installed. Installing configs...'
	fi

	## Installing Node Dependencies
	sudo npm install -g typescript typescript-language-server vscode-langservers-extracted vls @tailwindcss/language-server yaml-language-server @prisma/language-server emmet-ls neovim graphql-language-service-cli graphql-language-service-server @astrojs/language-server bash-language-server prettier

	## Installing Node Dependencies
	sudo pacman -S lua-language-server pyright deno rust-analyzer gopls shellcheck shfmt stylua autopep8 --noconfirm

	## Making Backup of current config
	[ -d "$NVIM_DIR" ] && mv $NVIM_DIR "$NVIM_DIR.backup"

	## Clonig my config from github plus my fork of friendly-snippets
	__clone "https://github.com/adityastomar67/nvdots.git" "$NVIM_DIR"
	__clone "https://github.com/adityastomar67/friendly-snippets.git" "$NVIM_DIR/bin/friendly-snippets"
	__clone "https://github.com/adityastomar67/LuaSnip-snippets.nvim.git" "$TEMP_DIR/snips" &&
		mv "$TEMP_DIR/snips/lua/luasnip_snippets" "$NVIM_DIR/bin/luasnippets"
}

# NOTE: Needs to be worked on!!
_Set_Wallpaper() {
	url="https://www.github.com/adityastomar67/Wallpapers/"
	__pkg_install feh
	gum style --foreground 202 --border none "Checkout Wallpapers @ \"$url\""

	choice=$(gum confirm "Open URL?")
	if [[ $(uname) == "Linux" && $choice ]]; then
		google-chrome-stable --no-sandbox $url
	elif [[ $(uname) == "Darwin" && $choice ]]; then
		open -a "Google Chrome" $url
	fi

	WALL=$(gum input --placeholder "Enter the Wallpaper Number: (or Type \"All\" to download full collection)")

	# For downloading all wallpapers
	if [[ $WALL == [aA] || $WALL == [aA][lL][lL] ]]; then
		[ -d "$HOME/.config/wall/Wallpapers" ] && rm -rf ~/.config/wall/Wallpapers
		mkdir -p "$HOME/.config/wall/"

		cd ~/.config/wall/ || exit
		if [ -f 'wall*' ]; then
			command rm wall*
		fi

		git clone https://github.com/adityastomar67/Wallpapers
		mv ~/.config/wall/Wallpapers/wall* .
		rm -rf ~/.config/wall/Wallpapers
		ls | grep "wall[0-9]*.png" >list.txt

		list="./list.txt"
		while IFS= read -r file; do
			mv -- "$file" "${file%.png}.jpg"
		done <"$list"

		command rm list.txt

		echo "Random Wallpaper Applied!!"
		count=$(command ls ~/.config/wall | grep -c "wall[0-9]*.jpg")
		feh --no-fehbg --bg-fill "$HOME/.config/wall/wall$((1 + RANDOM % $count)).jpg"
	else
		# curl -sL "https://github.com/adityastomar67/Wallpapers/raw/main/wall$WALL.(jpg|png)" -o wallpaper
		args="https://github.com/adityastomar67/Wallpapers/raw/main/wall$WALL.png"
		# curl -fs $args && echo "SUCCESS!" || echo "OH NO!"
		if [[ $(curl -fs $args) ]]; then
			curl -sL "https://github.com/adityastomar67/Wallpapers/raw/main/wall$WALL.png" --output "$HOME/wall.png"
		else
			curl -sL "https://github.com/adityastomar67/Wallpapers/raw/main/wall$WALL.jpg" --output "$HOME/wall.jpg"
		fi

		# Setting the Background
		[ -f "$HOME/wall$WALL.jpg" ] && feh --no-fehbg --bg-fill "$HOME/wall$WALL.jpg" || feh --no-fehbg --bg-fill "$HOME/wall$WALL.png"
	fi
}

## Starting the execution
if [ $# -gt 0 ]; then
	case "$1" in
	-v | --vim)
		_Install_Neovim
		;;
	-d | --dots)
		_Install_Dots
		;;
	-w | --wall)
		_Set_Wallpaper
		;;
	-z | --zsh)
		_Install_ZSH
		;;
	-g | --grub)
		_Install_GRUB
		;;
	?)
		echo "script usage: $(basename \$0) [-l] [-h] [-a somevalue]" >&2
		exit 1
		;;
	esac
else
	echo "No args"
fi

_cleanUp
gum style --foreground 202 --border none "Done! Enjoy your new setup!"
