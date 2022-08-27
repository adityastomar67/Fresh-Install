#!/usr/bin/env bash
#  _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By      - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github  - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|
# Made for Arch Linux

# TODO: Functionality to imply yes to all questions
# TODO : Functionality to install packages from a file
# TODO: Quiet mode
# TODO: Verbose mode

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
	git clone "$1" "$2"
}

### Checks

## Check wether the go is installed or not
if [[ ! $(command -v go) ]]; then
	echo >&2 "Script require Go but it's not installed."
	read -p "Continue to install Go or Abort? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	CMD=$(curl -s https://go.dev/doc/install | grep "rm -rf" | sed -E 's/(\$ |<[\/a-zA-Z =\"-]*>)//g')
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

_GRUB_Install() {
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
	cd "HOME/.dotfiles" || exit
	stow .
}

_Install_Neovim() {
	## Checking if Neovim is Installed
	if [[ ! $(command -v nvim) ]]; then
		sudo pacman -S neovim --noconfirm
	fi

	## Making Backup of current config
	mv $HOME/.config/nvim $HOME/.config/nvim.backup

	__clone "https://github.com/adityastomar67/nvim-dots.git" "$HOME/.config/nvim"
	__clone "https://github.com/adityastomar67/friendly-snippets.git" "$HOME/.config/nvim/"
}

################  HELP  ####################
## For GRUB Theme
HELP_GRUB="https://github.com/catppuccin/grub"
