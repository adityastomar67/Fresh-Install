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
gum style --foreground 212 --border-foreground 212 --border double --align center --width 50 --margin "1 2" --padding "2 4" 'Fresh Install' 'By - adityastomar67'

_GRUB_Install() {
	git clone https://github.com/catppuccin/grub.git /tmp/repos && cd "/tmp/repos/"
	sudo cp -r src/* /usr/share/grub/themes/
	
	TYPE=$(gum choose "catppuccin-latte" "catppuccin-frappe" "catppuccin-macchiato" "catppuccin-mocha")
	THEME="GRUB_THEME='/usr/share/grub/themes/$TYPE-grub-theme/theme.txt'"
	sed -r -i "s/GRUB_THEME=\"([/.-][a-z]\w+)*\"/$THEME/" /etc/default/grub
	
	sudo grub-mkconfig -o /boot/grub/grub.cfg
}



################  HELP  ####################
## For GRUB Theme
HELP_GRUB="https://github.com/catppuccin/grub"
