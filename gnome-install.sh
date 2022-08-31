#!/bin/bash
# _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|     www -
#

# EXECUTE
# sudo chmod +x Fresh-Install.sh
# sudo ./Fresh-Install.sh | tee logfile.txt
# source /Fresh-Install.sh
{

	# set -exo pipefail

	#* paths
	LOG_SCRIPT=./log_script.txt
	GITCONFIG=/etc/gitconfig
	SSH_FOLDER=~/.ssh
	SSHCONFIG="$SSH_FOLDER/config"
	DOWNLOADS=~/Downloads
	BASHRC=~/.bashrc
	ZSHRC=~/.zshrc
	MOUSE_CONFIG=/usr/share/X11/xorg.conf.d/52-mymods.conf
	RBENV_DIR=~/.rbenv
	RUBY_BUILD_DIR="$RBENV_DIR/plugins/ruby-build"
	WALLPAPER_FOLDER="Wallpaper/"

	#* Set initial variables
	# applications=0
	Arch=""
	# badoption=0
	# cinnamon=0
	# CLIonly=0
	CurUbuntuRelease="21.04"
	CODE=""
	# development=0
	Distro=""
	error=0
	# Exit=0
	# fonts=0
	FULL_RELEASE=""
	# games=0
	# gnome=0
	GroupName=""
	HostArch=""
	# input=""
	# IPTablesRevert=0
	# kde=0
	# LibreOffice=0
	# lxde=0
	# mate=0
	MinUbuntuRelease="14.0"
	Msg=""
	# multimedia=0
	NAME="Unknown"
	# OK=0
	PkgMgr=""
	rc=0
	# reboot=0
	RELEASE=""
	# response="n"
	RPMlist=""
	PackageName=""
	# server=0
	# Sysctl=1
	verbose=0
	version="02.01"
	Virtual=0
	# xfce=0
	# Yes=0

	# Change these to match your screen resolution
	WIDTH=2560
	HEIGHT=1440

	{
		Dir="pwd"
		$Dir | tee "Data/directory.txt"
		value=$(cat Data/directory.txt)
	}

}

#* install some CLI & GUI administrative tools
AdminTools() {
	if [ $1 -eq 1 ]; then
		#! CLI Based
		RPMlist="mc screen vim-common vim-enhanced vim-filesystem vim-minimal fail2ban deltarpm lm_sensors terminator hddtemp util-linux-user pwgen dmidecode ddrescue screenfetch neofetch okular nmon inxi speedtest task dictd whois logwatch powertop atop htop iptraf-ng iotop iftop sysstat rpmorphan lshw clamav chkrootkit apcupsd nvme-cli"
		Msg="Installing some useful administration tools."
		PrintMsg
		InstallRPMList
	else
		#! GUI Based
		RPMlist="xfe vim-X11 tilix"
		Msg="Installing some GUI administration tools"
		PrintMsg
		InstallRPMList
	fi
}
#* To Check whether this is a VirtualBox, VMWare, or Physical Machine.
CheckMachine() {
	if dmesg | grep -i "VBOX HARDDISK" >/dev/null; then
		Virtual=1
		Msg="This is a virtual machine running under VirtualBox"
	elif dmesg | grep -i "vmware" >/dev/null; then
		Virtual=1
		Msg="This is a virtual machine running under VMWare"
	else
		Virtual=0
		Msg="Good....This is a physical machine, Not a VBOX or a Virtual Machine."
	fi
	PrintMsg
}
#* Common Tasks
CommonTask() {

	sudo apt update
	sudo apt upgrade -y

	#* Installing Curl
	sudo apt install curl

	#* Installing Yum
	sudo apt-get update -y
	sudo apt-get install -y yum

	#* Installing Git
	sudo apt install git

	#* Installing Neofetch
	sudo apt install neofetch

	#* Install wget if not present
	PackageName="wget"
	if ! PKGisInstalled; then
		Msg="Installing wget"
		PrintMsg
		RPMlist="wget"
		InstallRPMList
	else
		Msg="wget is already installed"
		PrintMsg
	fi
}
#* Install various common desktops including KDE Gnome, Xfce, and others. But ONLY by individual options.                                                  #
DE() {
	InstallCinnamon() {
		# Is it already installed?
		GroupName="Cinnamon Desktop"
		if ! GroupisInstalled; then
			# Install KDE for Ubuntu 18 and above
			Msg="Installing $GroupName."
			PrintMsg
			$PkgMgr -y groupinstall "$GroupName"
		else
			Msg="$GroupName is already installed."
			PrintMsg
		fi
	}
	InstallGnome() {
		# Determine which group name to use
		PackageName="gnome-session"
		if [ $NAME = "Ubuntu" ] && ! PKGisInstalled; then
			GroupName="GNOME"
		elif [ $NAME = "CentOS" ] && [ $RELEASE -eq 6 ] && ! PKGisInstalled; then
			GroupName="Desktop"
		elif [ $NAME = "CentOS" ] && [ $RELEASE -eq 7 ] && ! PKGisInstalled; then
			GroupName="GNOME Desktop"
		fi
		# do the actual installation
		Msg="Installing $GroupName -- GNOME Desktop"
		PrintMsg
		$PkgMgr groupinstall "$GroupName"
	}
	# InstallGnome40() {

	# }
	InstallKDE() {
		PackageName="kde-baseapps"
		# Install KDE for Ubuntu 18 and above
		if ! rpm -q $PackageName >/dev/null; then
			GroupName="KDE Plasma Workspaces"
			Msg="Installing $GroupName."
			PrintMsg
			$PkgMgr -y groupinstall "$GroupName"
		fi
	}
	InstallLXDE() {
		# Install LXDE for Ubuntu 18 and above
		# Is it already installed?
		PackageName="lxde-common"
		if ! PKGisInstalled; then
			# It is not installed so we will install it
			if [ $RELEASE -ge 18 ]; then
				# Install LXDE for Ubuntu 18+
				# Set the group name to be installed
				GroupName="LXDE Desktop"
				Msg="Installing $GroupName."
				PrintMsg
				$PkgMgr -y groupinstall "$GroupName"
			else
				# Install LXDE for Ubuntu 16 or 17
				GroupName="LXDE"
				Msg="Installing $GroupName."
				PrintMsg
				$PkgMgr -y groupinstall "$GroupName"
			fi
		fi
	}
	InstallMATE() {
		GroupName="MATE Desktop"
		PackageName="mate-session-manager"
		if [ $RELEASE -ge 18 ]; then
			# Is it already installed?
			if ! PKGisInstalled; then
				# Install MATE for Ubuntu 18 and above
				Msg="Installing $GroupName."
				PrintMsg
				$PkgMgr groupinstall "$GroupName"
			else
				Msg="$GroupName is already installed."
				PrintMsg
			fi
		else
			Msg="$GroupName is only supported on Ubuntu 18 and over."
			PrintMsg
		fi
	}
	InstallXfce() {
		# Install Xfce
		# Is it already installed?
		PackageName="xfce4-session"
		if ! PKGisInstalled; then
			# It is not installed so we will install it
			if [ $RELEASE -ge 18 ]; then
				# Install Xfce for Ubuntu 18+
				# Set the group name to be installed
				GroupName="Xfce Desktop"
				Msg="Installing $GroupName."
				PrintMsg
				$PkgMgr groupinstall "$GroupName"
			else
				# Install Xfce for Ubuntu 16 or 17
				GroupName="Xfce"
				Msg="Installing $GroupName."
				PrintMsg
				$PkgMgr groupinstall "$GroupName"
			fi
		fi
	}
	if [ $1 -eq 1 ]; then
		InstallCinnamon
	elif [ $1 -eq 2 ]; then
		InstallGnome
	elif [ $1 -eq 3 ]; then
		InstallXDE
	elif [ $1 -eq 4 ]; then
		InstallLXDE
	elif [ $1 -eq 5 ]; then
		InstallMATE
	elif [ $1 -eq 6 ]; then
		InstallXfce
	fi
}
#* Install fonts for compatibility and flexibility
Font() {
	Msg="Installing common and compatibility fonts."
	PrintMsg
	RPMlist="aajohan-comfortaa-fonts adf-accanthis-2-fonts adf-accanthis-3-fonts adf-accanthis-fonts adf-accanthis-fonts-common adf-gillius-fonts adf-gillius-fonts-common adf-tribun-fonts bitmap-fonts-compat bitstream-vera-fonts-common bitstream-vera-sans-fonts bitstream-vera-sans-mono-fonts bitstream-vera-serif-fonts cf-bonveno-fonts cf-sorts-mill-goudy-fonts chisholm-to-be-continued-fonts ctan-cm-lgc-fonts-common ctan-cm-lgc-roman-fonts ctan-cm-lgc-sans-fonts ctan-cm-lgc-typewriter-fonts darkgarden-fonts ecolier-court-fonts ecolier-court-fonts-common ecolier-court-lignes-fonts extremetuxracer-papercuts-fonts extremetuxracer-papercuts-outline-fonts freecol-imperator-fonts freecol-shadowedblack-fonts ghostscript-fonts gnu-free-fonts-common gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts impallari-lobster-fonts inkboy-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts liberation-sans-fonts liberation-serif-fonts libreoffice-opensymbol-fonts linux-libertine-fonts oldstandard-sfd-fonts scholarsfonts-cardo-fonts sil-abyssinica-fonts silkscreen-expanded-fonts silkscreen-fonts silkscreen-fonts-common sj-fonts-common sj-stevehand-fonts stix-fonts terminus-fonts terminus-fonts-console thibault-essays1743-fonts thibault-fonts-common thibault-isabella-fonts tlomt-junction-fonts tulrich-tuffy-fonts typemade-josefinsansstd-light-fonts ubuntu-title-fonts un-core-dotum-fonts un-core-fonts-common urw-fonts vlgothic-fonts vlgothic-fonts-common vlgothic-p-fonts vollkorn-fonts woodardworks-laconic-fonts woodardworks-laconic-shadow-fonts wqy-zenhei-fonts xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-Type1"
	InstallRPMList
	# Now update the font cache
	/usr/bin/fc-cache -fv

	Msg="Installing Fira Code - A Font for Programmers"
	PrintMsg
	sudo add-apt-repository universe
	sudo apt update
	sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
	sudo apt update
	sudo apt install fonts-firacode

}
#* To Get Information about System
GetInfo() {
	################################################################################
	#               Get some basic info and do a bit of setup                      #
	################################################################################
	#              Get Distribution and architecture 64/32 bit                     #
	################################################################################

	#* Get the host physical architecture
	HostArch=$(echo $HOSTTYPE | tr [:lower:] [:upper:])
	Msg="The Host Physical Architecture is $HostArch"
	# PrintMsg

	#-------------------------------------------------------------------------------------------------------------------------------------------------------------#
	# Get some information from the *-release file. We care about this to give us Ubuntu version number and because some group names change between release levels.
	#-------------------------------------------------------------------------------------------------------------------------------------------------------------#

	# Switch to /etc for grabbing Details
	cd /etc || return

	# Start by looking for Ubuntu
	if lsb_release -a | grep -i Ubuntu >/dev/null; then
		# This is Ubuntu
		NAME="Ubuntu"
		# Define the Distribution
		Distro=$(grep PRETTY_NAME os-release | awk -F= '{print $2}')
		# Get the full release number
		FULL_RELEASE=$(grep VERSION_ID os-release | awk -F= '{print $2}')
		# Get The OS's CodeName
		CODE=$(grep VERSION_CODENAME os-release | awk -F= '{print $2}')
		# The Release version is the same as the full release number, i.e., no minor versions for Ubuntu
		RELEASE=$FULL_RELEASE

		#---------------------------------------------------------------------------------------------------------------------------------------------#
		# Verify Ubuntu release is equal or above than $MinUbuntuRelease. This is due to the lack of Ubuntu and its repositories prior to that release.
		#---------------------------------------------------------------------------------------------------------------------------------------------#
		# if [ $RELEASE ] <$MinUbuntuRelease; then
		#    error=2
		#    Quit
		# fi
	else
		Msg="Unsupported OS: $NAME"
		PrintMsg
		error=2
		Quit $error
	fi

	#* Now lets find whether Distro is 32 or 64 bit
	if arch | grep -i x86_64 >/dev/null; then
		# Just the bits
		Arch="64"
	else
		# Just the bits
		Arch="32"
	fi

	# Switch back to Original Directory
	cd "$value" || return

	#* Now lets find out about Package Manager
	PkgMgr="sudo $(cd Data && ./pkgmngrcheck.sh | cut -d " " -f3)"
}
#* Configure GIT
GitConfig() {
	read -p "YOUR_NAME" GITHUB_NAME
	read -p "YOUR_GITHUB_EMAIL" GITHUB_MAIL
	read -p "YOUR_USERNAME" GITHUB_USER

	sudo rm $GITCONFIG
	sudo touch $GITCONFIG
	sudo chmod 777 $GITCONFIG
	echo -e "[user]" >>$GITCONFIG
	echo -e "  name = $GITHUB_NAME" >>$GITCONFIG

	echo -e "  email = $GITHUB_MAIL" >>$GITCONFIG
	echo -e "[core]" >>$GITCONFIG
	echo -e "  editor = vim -f" >>$GITCONFIG
	echo -e "[alias]" >>$GITCONFIG
	echo -e "  df = diff" >>$GITCONFIG
	echo -e "  st = status" >>$GITCONFIG
	echo -e "  cm = commit" >>$GITCONFIG
	echo -e "  ch = checkout" >>$GITCONFIG
	echo -e "  br = branch" >>$GITCONFIG
	echo -e "  lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative" >>$GITCONFIG
	echo -e "    ctags = !.git/hooks/ctags" >>$GITCONFIG
	echo -e "[color]" >>$GITCONFIG
	echo -e "  branch = auto" >>$GITCONFIG
	echo -e "  diff = auto" >>$GITCONFIG
	echo -e "  grep = auto" >>$GITCONFIG
	echo -e "  interactive = auto" >>$GITCONFIG
	echo -e "  status = auto" >>$GITCONFIG
	echo -e "  ui = 1" >>$GITCONFIG
	echo -e "[branch]" >>$GITCONFIG
	echo -e "  autosetuprebase = always" >>$GITCONFIG
	echo -e "[github]" >>$GITCONFIG
	echo -e "  user = $GITHUB_USER" >>$GITCONFIG

	ssh-keygen -t rsa -b 4096 -C "$GITHUB_MAIL" -N "" -f $SSH_FOLDER/id_rsa_github
	echo ""
	echo ""
	echo "**********************"
	echo "CONFIGURE GIT USER"
	echo ""
	echo "Adicione a public ssh key em 'https://github.com/settings/ssh':"
	echo ""
	cat $SSH_FOLDER/id_rsa_github.pub
	echo ""
	echo "**********************"

	touch $SSHCONFIG
	echo -e "#Github (default)" >>$SSHCONFIG
	echo -e "  Host github" >>$SSHCONFIG
	echo -e "  HostName github.com" >>$SSHCONFIG
	echo -e "  User git" >>$SSHCONFIG
	echo -e "  IdentityFile $SSH_FOLDER/id_rsa_github" >>$SSHCONFIG
}
#* Configure GitLab
GitLabConfig() {
	read -p "YOUR_GITLAB_DOMAIN" GITLAB_HOSTNAME
	read -p "YOUR_GITLAB_EMAIL" GITLAB_MAIL

	ssh-keygen -t rsa -b 4096 -C "$GITLAB_MAIL" -N "" -f $SSH_FOLDER/id_rsa_gitlab
	echo ""
	echo ""
	echo "**********************"
	echo "CONFIGURE GITLAB USER"
	echo ""
	echo "Adicione a public ssh key ao GitLab:"
	echo ""
	cat $SSH_FOLDER/id_rsa_gitlab.pub
	echo ""
	echo "**********************"

	touch $SSHCONFIG
	echo -e "#Gitlab" >>$SSHCONFIG
	echo -e "  Host gitlab" >>$SSHCONFIG
	echo -e "  HostName $GITLAB_HOSTNAME" >>$SSHCONFIG
	echo -e "  User git" >>$SSHCONFIG
	echo -e "  IdentityFile $SSH_FOLDER/id_rsa_gitlab" >>$SSHCONFIG
}
#* Print the GPL license header
gpl() {
	clear
	echo
	echo "                                          ################################################################################"
	echo "                                          #  Copyright (C) 2019, 2020  Aditya Singh Tomar.                               #"
	echo "                                          #  https://github.com/adityastomar67                                           #"
	echo "                                          #                                                                              #"
	echo "                                          #  This program is free software; you can redistribute it and/or modify it     #"
	echo "                                          #  under the terms of the GNU General Public License as published by the free  #"
	echo "                                          #  Software Foundation; either version 2 of the License, or (at your opinion)  #"
	echo "                                          #  any later version.                                                          #"
	echo "                                          #                                                                              #"
	echo "                                          #  This program is distributed in the hope that it will be useful, but WITHOUT #"
	echo "                                          #  ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or       #"
	echo "                                          #  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for   #"
	echo "                                          #  more details.                                                               #"
	echo "                                          #                                                                              #"
	echo "                                          #  You should have received a copy of the GNU General Public License           #"
	echo "                                          #  along with this program; if not, write to the given Email address below -   #"
	echo "                                          #  Email - adityastomar67@gmail.com                                            #"
	echo "                                          ################################################################################"
	echo
}
#* Help Section and Main Screen
Help() {
	clear
	echo "                                            #################################################################################################"
	echo "                                            #             Fresh-Install.sh: Installs useful Administrative Tools and Programs.              #"
	echo "                                            #                                                                                               #"
	echo "                                            #      This script is installed by the Fresh-Install RPM package. It is                         #"
	echo "                                            #      intended for use with Ubuntu $MinUbuntuRelease and above. It has been tested up                       #"
	echo "                                            #      through Ubuntu $CurUbuntuRelease.                                                                    #"
	echo "                                            #      This program installs the RPMFusion free and non-free repositories for Ubuntu if         #"
	echo "                                            #      they are not already. It also installs all current updates.                              #"
	echo "                                            #                                                                                               #"
	echo "                                            #                                  Syntax: ./Fresh-Install.sh                                   #"
	echo "                                            #################################################################################################"
	echo "                                            #      Options:                                                                                 #"
	echo "                                            #      1.    All: Install Applications, Admin Tools, Languages and fonts.                       #"
	echo "                                            #-----------------------------------------------------------------------------------------------#"
	echo "                                            #      2.    Install various GUI desktop applications.                                          #"
	echo "                                            #      3.    Install various CLI applications.                                                  #"
	echo "                                            #      4.    Install more desktop fonts from repository.                                        #"
	echo "                                            #      5.    Set Wallpapers.                                                                    #"
	echo "                                            #      6.    Git & GitLab Configuration.                                                        #"
	echo "                                            #      7.    Install Differnt type Terminals.                                                   #"
	echo "                                            #      8.    Install Differnt Terminal Shells.                                                  #"
	echo "                                            #-----------------------------------------------------------------------------------------------#"
	echo "                                            #      9.   Install Programming Languages.                                                      #"
	echo "                                            #-----------------------------------------------------------------------------------------------#"
	echo "                                            #                       ###### Options to install Desktop Environments ######                   #"
	echo "                                            #      10.   Install Cinnamon Desktop.                                                          #"
	echo "                                            #      11.   Install Gnome Desktop.                                                             #"
	echo "                                            #      12.   Install KDE Plasma desktop.                                                        #"
	echo "                                            #      13.   Install LXDE desktop.                                                              #"
	echo "                                            #      14.   Install MATE desktop.                                                              #"
	echo "                                            #      15.   Install Xfce desktop.                                                              #"
	echo "                                            #-----------------------------------------------------------------------------------------------#"
	echo "                                            #                             ###### Miscellaneous Options  ######                              #"
	echo "                                            #      G.    Print the GPL License header.                                                      #"
	echo "                                            #      Q.    Quit the Program.                                                                  #"
	echo "                                            #################################################################################################"
	echo "                                                                   This BASH program is distributed under the GPL V2."
}
#* Install the RPMs in a list
InstallRPMList() {
	Msg="Installing packages: $RPMlist"
	PrintMsg
	$PkgMgr install $RPMlist
	# Null out the list of RPMs
	RPMlist=""
}
#* For Installing Different Programming Languages
Lang() {
	#* for installing C++
	CPP() {
		sudo apt install g++
		sudo apt install build-essential
	}

	#* for installing JAVA
	JAVA() {
		#! JDK
		sudo apt update
		sudo apt install default-jdk -y
		#! JRE
		sudo apt update
		sudo apt install default-jre -y
		#! Oracle JAVA
		sudo apt install software-properties-common
		sudo add-apt-repository ppa:linuxuprising/java
		sudo apt update
		sudo apt install oracle-java11-installer
		#! Test JAVA
		java –version

		# ! echo "How to Set JAVA_HOME Environment Variable"
		# ? echo "The JAVA_HOME environment variable determines the location of your Java installation. "
		# ? echo "The variable helps other applications access Java’s installation path easily."
		# ? echo "1. To set up the JAVA_HOME variable, you first need to find where Java is installed."
		# ? echo "Use the following command to locate it:"
		sudo update-alternatives --config java
		# ? echo "Set up Java Home Varialbe Enviornment."
		# ? echo "The Path section shows the locations, which are in this case:"
		# ? echo "/usr/lib/jvm/java-11-openjdk-amd64/bin/java (where OpenJDK 11 is located)"
		# ? echo "/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java (where OpenJDK 8 is located)"
		# ? echo "2. Once you see all the paths, copy one of your preferred Java version."
		# ? echo "3. Then, open the file /etc/environment with any text editor. In this example, we use Nano:"
		sudo nano /etc/environment
		# ? echo "4. At the end of the file, add a line which specifies the location of JAVA_HOME in the following manner:"
		# ? echo "JAVA_HOME=”/your/installation/path/”"
	}

	#* for Installing Python
	Python() {
		sudo apt update
		sudo apt install software-properties-common
		sudo add-apt-repository ppa:deadsnakes/ppa
		sudo apt update
		sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
		read -p "Get Pyhton Version First and Type it Here :" version
		sudo apt install python$version
	}

	#* for Installing Node
	Node() {
		sudo apt install nodejs
		node -v # or node –version
		sudo apt install npm
		npm -v # or npm –version
	}

	#* for Installing MySQL
	MySQL() {
		verbose=1
	}
	read -p $'1. C++\n2. Java\n3. Python\n4. Node\n5. MySql' choiceOpt
	if [ $choiceOpt -eq 1 ]; then
		CPP
	elif [ $choiceOpt -eq 2 ]; then
		JAVA
	elif [ $choiceOpt -eq 3 ]; then
		Python
	elif [ $choiceOpt -eq 4 ]; then
		Node
	elif [ $choiceOpt -eq 5 ]; then
		MySQL
	fi
}
#* Mods for Command Line
MOD() {
	BashSnippet() {
		echo "Installing Bash Snippets..."
		cd Bash-Snippets/ || exit
		chmod +x install.sh
		./install.sh
	}
	LScript() {
		echo "Installing Lazy Script..."
		cd lscript/ || exit
		chmod +x install.sh
		./install.sh
	}
	BASHRC() {
		cp ~/.bashrc ~/.bashrc.bak #To Take a backup of current file.
		cp .bashrc ~/
		# cp ~/.bashrc.bak ~/.bashrc   #To restore backuped file.
		echo "Changes will be shown after restarting terminal"
	}
	ZSHRC() {
		cp ~/.zshrc ~/.zshrc.bak #To Take a backup of current file.
		cp .zshrc ~/
		# cp ~/.zshrc.bak ~/.zshrc   #To restore backuped file.
		echo "Changes will be shown after restarting terminal"
	}
	FISH() {
		cp ~/.fish ~/.fish.bak #To Take a backup of current file.
		cd rcFiles/ || exit
		cp /.fish ~/
		# cp ~/.fish.bak ~/.fish   #To restore backuped file.
		echo "Changes will be shown after restarting terminal"
	}
	if [ $1 -eq 1 ]; then
		BashSnippet
	elif [ $1 -eq 2 ]; then
		LScript
	elif [ $1 -eq 3 ]; then
		BASHRC
	elif [ $1 -eq 4 ]; then
		ZSHRC
	elif [ $1 -eq 5 ]; then
		FISH
	fi
}
#* Determines whether a given package is installed. Returns 0 if true and 1 if false.
PKGisInstalled() {
	# See if the RPM exists
	if rpm -q $PackageName >/dev/null; then
		Msg="Package $PackageName is installed"
		rc=0
	else
		Msg="Package $PackageName is NOT installed"
		rc=1
	fi
	PrintMsg
	return $rc
}
#* For Installing Programs
Program() {
	ForAll() {
		Chrome
		Vscode
		VLC
		JetBrains
		AndroidStudio
		7ZIP
		Gimp
		Dropbox
		Torrent
		Spotify
		GParted
		Postman
		Skype
		SQLite
		ULauncher
		GNOMETweaks
	}
	Chrome() {
		if [ $Arch == "64" ]; then
			Msg="Installing Google Chrome Web browser."
			PrintMsg
			wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
			sudo dpkg -i google-chrome-stable_current_amd64.deb
			#// $PkgMgr install -y google-chrome-stable
		else
			Msg="Cannot install Google Chrome Web browser on a 32-bit version of Linux."
			PrintMsg
		fi
	}
	Vscode() {
		Msg="Installing VS Code "
		PrintMsg
		sudo apt update
		sudo apt install software-properties-common apt-transport-https wget
		wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
		sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
		sudo apt update
		sudo apt install code
	}
	VLC() {
		#! for Stable Version
		Stable() {
			sudo add-apt-repository ppa:videolan/stable-daily
			sudo apt-get update
			sudo apt-get install vlc
		}
		#! for Unstable Version
		Unstable() {
			sudo add-apt-repository ppa:videolan/master-daily
			sudo apt-get update
			sudo apt-get install vlc
		}
		read -p $'(1)Stable Version \n (2)Unstable Version' choice
		if [ $choice == "i" ]; then
			Stable
		else
			Unstable
		fi
	}
	JetBrains() {
		Msg="Installing IntelliJ Products "
		PrintMsg
		read -p "Want to Continue(Y/N) :" choiceYN
		while [ "$choiceYN" == 'y' -o "$choiceYN" == 'Y' ]; do
			read -p $'1. IntelliJ\n2. PyCharm\n3. Clion\n4. PhpStorm\n5. All\n6. Exit' choiceOpt
			if [ "$choiceOpt" -eq 1 ]; then
				$PkgMgr install intellij-idea-ultimate --classic
			elif [ "$choiceOpt" -eq 2 ]; then
				$PkgMgr install pycharm-professional --classic
			elif [ "$choiceOpt" -eq 3 ]; then
				$PkgMgr install clion --classic
			elif [ "$choiceOpt" -eq 4 ]; then
				$PkgMgr install phpstorm --classic
			elif [ "$choiceOpt" -eq 5 ]; then
				$PkgMgr install intellij-idea-ultimate --classic
				$PkgMgr install pycharm-professional --classic
				$PkgMgr install clion --classic
				$PkgMgr install phpstorm --classic
				break
			elif [ "$choiceOpt" -eq 6 ]; then
				break
			fi
		done

	}
	AndroidStudio() {
		Msg="Installing Android Studio "
		PrintMsg
		sudo add-apt-repository ppa:maarten-fonville/android-studio
		sudo apt update
		sudo apt install android-studio
	}
	7ZIP() {
		sudo apt install 7zip p7zip-full
		sudo apt install "7zip rar extension" p7zip-rar
	}
	Gimp() {
		sudo apt install Gimp gimp
	}
	Dropbox() {
		$PkgMgr install Dropbox nautilus-dropbox
	}
	Torrent() {
		$PkgMgr install qBitTorrent qbittorrent
	}
	Spotify() {
		$PkgMgr install Spotify spotify
	}
	GParted() {
		sudo apt install GParted gparted
	}
	Postman() {
		$PkgMgr install Postman postman
	}
	Skype() {
		$PkgMgr install Skype skype --classic
	}
	SQLite() {
		sudo apt install SQLite sqlite3 libsqlite3-dev
	}
	ULauncher() {
		sudo add-apt-repository ppa:agornostal/ulauncher
		sudo apt update
		sudo apt install ulauncher
	}
	GNOMETweaks() {
		sudo add-apt-repository universe
		sudo apt install gnome-tweak-tool
	}

	Msg="Installing Programs "
	PrintMsg
	read -p "Want to Continue(Y/N) :" choiceYN
	while [ "$choiceYN" == 'y' -o "$choiceYN" == 'Y' ]; do

		read -p $'1. Chrome\n2. VS Code\n3. VLC\n4. JetBrains\n5.Android Studio\n6. 7 Zip\n7. Gimp\n8. Dropbox\n9.Torrent\n10. Spotify\n11. Gparted\n12. Postman\n13. Skype\n14. SQLite\n15. ULauncher\n16. GNOME Tweaks\n17. All\n18. Exit' choiceOpt

		if [ $choiceOpt -eq 1 ]; then
			Chrome
		elif [ $choiceOpt -eq 2 ]; then
			Vscode
		elif [ $choiceOpt -eq 3 ]; then
			VLC
		elif [ $choiceOpt -eq 4 ]; then
			JetBrains
		elif [ $choiceOpt -eq 5 ]; then
			AndroidStudio
		elif [ $choiceOpt -eq 6 ]; then
			7ZIP
		elif [ $choiceOpt -eq 7 ]; then
			Gimp
		elif [ $choiceOpt -eq 8 ]; then
			Dropbox
		elif [ $choiceOpt -eq 9 ]; then
			Torrent
		elif [ $choiceOpt -eq 10 ]; then
			Spotify
		elif [ $choiceOpt -eq 11 ]; then
			GParted
		elif [ $choiceOpt -eq 12 ]; then
			Postman
		elif [ $choiceOpt -eq 13 ]; then
			Skype
		elif [ $choiceOpt -eq 14 ]; then
			SQLite
		elif [ $choiceOpt -eq 15 ]; then
			ULauncher
		elif [ $choiceOpt -eq 16 ]; then
			GNOMETweaks
		elif [ $choiceOpt -eq 17 ]; then
			ForAll
			break
		elif [ $choiceOpt -eq 18 ]; then
			break
		fi
	done
}
#* Display verbose messages in a common format
PrintMsg() {
	if [ $verbose == 1 ] && [ -n "$Msg" ]; then
		echo $Msg
		# Set the message to null
		Msg=""
	fi
}
#* Quit nicely with messages as appropriate
Quit() {
	if [ $rc != 0 ]; then
		echo "Program terminated with error ID $error"
	else
		if [ $verbose = 1 ]; then
			echo "Program terminated normally"
			rc=0
		fi
	fi

	exit $rc
}
#* For setting up Wallpaper
SetWallpaper() {
	# read -p "1. For Wallpaper only.\n2. For LockScreen only\n3. For Both." choiceOpt #IT doesn't gives new line
	read -p $'1. For Wallpaper only.\n2. For LockScreen only\n3. For Both.' choiceOpt #It works for new line

	if [ $choiceOpt -eq 1 ]; then
		echo " Choose Your Wallpaper from Given!! "
		echo
		echo "1. MacOS Dynamic."
		echo "2. Kali Wallpaper."
		echo "3. Windows Wallpaper"
		echo "4. Nature"
		echo "5. Hottie"
		echo "6. Bing Random"
		echo
		read -p "Enter Your Choice :" choice
		if [ $choice -eq 1 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/mojave.xml
		elif [ $choice -eq 2 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall01.png
		elif [ $choice -eq 3 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall02.png
		elif [ $choice -eq 4 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall03.jpg
		elif [ $choice -eq 5 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall04.jpg
		else
			downloadRandomImage() {
				# Download a random image for this resolution
				FILENAME=$(cd "$WALLPAPER_FOLDER" &&
					curl --remote-header-name --location --remote-name \
						--silent --write-out "%{filename_effective}" \
						"https://picsum.photos/$WIDTH/$HEIGHT?grayscale")
				# Return the path of the downloaded file
				echo "$WALLPAPER_FOLDER/$FILENAME"
			}

			DESKTOP_IMAGE=$(downloadRandomImage)
			gsettings set org.gnome.desktop.background picture-uri "file://$DESKTOP_IMAGE"
		fi
	elif [ $choiceOpt -eq 2 ]; then
		echo " Choose Your Wallpaper from Given!! "
		echo
		echo "1. MacOS Dynamic."
		echo "2. Kali Wallpaper."
		echo "3. Windows Wallpaper"
		echo "4. Nature"
		echo "5. Hottie"
		echo "6. Bing Random"
		echo
		read -p "Enter Your Choice :" choice
		if [ $choice -eq 1 ]; then
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/mojave.xml
		elif [ $choice -eq 2 ]; then
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall01.jpeg
		elif [ $choice -eq 3 ]; then
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall02.jpeg
		elif [ $choice -eq 4 ]; then
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall03.jpeg
		elif [ $choice -eq 5 ]; then
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall04.jpeg
		else
			downloadRandomImage() {
				# Download a random image for this resolution
				FILENAME=$(cd "$WALLPAPER_FOLDER" &&
					curl --remote-header-name --location --remote-name \
						--silent --write-out "%{filename_effective}" \
						"https://picsum.photos/$WIDTH/$HEIGHT?grayscale")
				# Return the path of the downloaded file
				echo "$WALLPAPER_FOLDER/$FILENAME"
			}
			LOCKSCREEN_IMAGE=$(downloadRandomImage)
			gsettings set org.gnome.desktop.screensaver picture-uri "file://$LOCKSCREEN_IMAGE"
		fi
	elif [ $choiceOpt -eq 3 ]; then
		echo " Choose Your Wallpaper from Given!! "
		echo
		echo "1. MacOS Dynamic."
		echo "2. Kali Wallpaper."
		echo "3. Windows Wallpaper"
		echo "4. Nature"
		echo "5. Hottie"
		echo "6. Bing Random"
		echo
		read -p "Enter Your Choice :" choice
		if [ $choice -eq 1 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/mojave.xml
			gsettings set org.gnome.desktopscreensaverd picture-uri file:////Wallpaper/mojave.xml
		elif [ $choice -eq 2 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall01.jpeg
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall01.xml
		elif [ $choice -eq 3 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall02.jpeg
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall02.xml
		elif [ $choice -eq 4 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall03.jpeg
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall03.xml
		elif [ $choice -eq 5 ]; then
			gsettings set org.gnome.desktop.background picture-uri file:////Wallpaper/wall04.xml
			gsettings set org.gnome.desktop.screensaver picture-uri file:////Wallpaper/wall04.jpeg
		else
			downloadRandomImage() {
				# Download a random image for this resolution
				FILENAME=$(cd "$WALLPAPER_FOLDER" &&
					curl --remote-header-name --location --remote-name \
						--silent --write-out "%{filename_effective}" \
						"https://picsum.photos/$WIDTH/$HEIGHT?grayscale")
				# Return the path of the downloaded file
				echo "$WALLPAPER_FOLDER/$FILENAME"
			}

			DESKTOP_IMAGE=$(downloadRandomImage)
			gsettings set org.gnome.desktop.background picture-uri "file://$DESKTOP_IMAGE"

			LOCKSCREEN_IMAGE=$(downloadRandomImage)
			gsettings set org.gnome.desktop.screensaver picture-uri "file://$LOCKSCREEN_IMAGE"
		fi
	fi
}
#* For Installing Different Types of Shells
Shell() {
	ZSH() {
		sudo apt update
		sudo apt upgrade
		sudo apt install zsh
		#// sudo apt-get install powerline fonts-powerline
		#// git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
		#// cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
		#// git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
		#//source ~/.zshrc
		chsh -s $(which zsh) #! For MAking it Default
		read -p "Do You Want Customized ZSH(Y/N)?" choice
		# if [ $choice -eq 1 ]; then   #It Works
		if [ $choice == 'Y' -o $choice == 'y' ]; then #(-eq doesn't work with alphabets)
			MOD 4
		fi
	}
	Fish() {
		sudo apt update
		sudo apt install fish
		chsh -s $(which fish) #! For MAking it Default
		read -p "Do You Want Customized FISH Shell(Y/N)?" choice
		if [ $choice == 'Y' -o $choice == 'y' ]; then
			MOD 5
		fi
	}
	TCSH() {
		sudo apt update
		sudoapt install tcsh
		chsh -s $(which tcsh) #! For MAking it Default
	}
	KSH() {
		sudo apt update
		sudo install ksh
		chsh -s $(which ksh) #! For MAking it Default
	}
	read -p $'1. ZSH\n2. FISH\n3. TCSH\n4. KSH' choiceOpt
	if [ $choiceOpt -eq 1 ]; then
		ZSH
	elif [ $choiceOpt -eq 2 ]; then
		Fish
	elif [ $choiceOpt -eq 3 ]; then
		TCSH
	elif [ $choiceOpt -eq 4 ]; then
		KSH
	fi
}
#* To Show Information about the System
ShowInfo() {
	echo
	Msg="DISTRIBUTION = $Distro"
	PrintMsg
	Msg="NAME = $NAME"
	PrintMsg
	Msg="RELEASE = $RELEASE"
	PrintMsg
	Msg="FULL RELEASE = $FULL_RELEASE"
	PrintMsg
	Msg="CODE NAME = $CODE"
	PrintMsg
	echo
}
#* For Installing Different Types of Terminals
Terminals() {
	HyperTerminal() {
		wget https://releases.hyper.is/download/deb
		sudo apt install ./hyper_3.0.2_amd64.deb -y
		#! for making it default terminal
		sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /opt/Hyper/hyper 50
	}
	Alacritty() {
		sudo curl https://sh.rustup.rs -sSf | sh
		apt-get install cmake libfreetype6-dev libfontconfig1-dev xclip
		cd Downloads
		git clone https://github.com/jwilm/alacritty.git
		cd alacritty
		cargo build --release
		#! echo "Once the compilation process is complete, the binary will be saved in ./target/release/alacritty directory."
		#! echo "Copy the binary to a directory in your PATH and on a desktop."
	}
	Tilda() {
		sudo apt-get install tilda
	}
	Tilix() {
		sudo apt-get update -y
		sudo apt-get install -y tilix
	}

	read -p $'1. Hyper Terminal\n2. Alarcritty\n3. Tilda\n4. Tilix' choiceOpt
	if [ $choiceOpt -eq 1 ]; then
		HyperTerminal
	elif [ $choiceOpt -eq 2 ]; then
		Alacritty
	elif [ $choiceOpt -eq 3 ]; then
		Tilda
	elif [ $choiceOpt -eq 4 ]; then
		Tilix
	fi
}

#* ----------------------------------------------------------------------------Main Program---------------------------------------------------------------------*#

{
	clear
	echo "Checking if the System is Compatible with the Program or Not"
	#* Set verbose on for this sanity checking
	verbose=1

	#* Check for Linux
	if [[ "$(uname -s)" != "Linux" ]]; then
		Msg="This script is for Linux only -- OS detected: $(uname -s)."
		PrintMsg
		error=1
		Quit
	fi

	CheckMachine

	#* Check for root
	if [ $(id -u) != 0 ]; then
		Msg="You must be root to run this program"
		PrintMsg
		error=3
		Msg="If You wish to use this Program, Please run it Again with sudo command!!"
		PrintMsg
		##### sudo $value/Fresh-Install.sh
		Quit
	fi

	GetInfo
	# ShowInfo
	sleep 5

	read -p $'\nDo You Want Full Info about Your PC?(Y/N)' yn
	if [ $yn == "Y" -o $yn == "y" ]; then
		sudo chmod +x systeminfo.sh
		sudo ./systeminfo.sh
		echo $'\n\n\nHit [ENTER] To Continue!'
		while read answer; do
			if [ -z "$answer" ]; then
				break
			fi
		done
	else
		read -p $'\nShould We START our Program then?(Y/N) :' continueYN
		if [ $continueYN == "N" -o $continueYN == "n" ]; then
			Quit
		fi
	fi

	#* Now turn verbose back off so that the -v option will take precedence after the input options are processed below.
	verbose=0

	echo $'\nCompleting Some Coommon Tasks...Dont Worry...LOL.\n'
	CommonTask
	echo $'\n\nChores Completed...'
	echo "Will Begin our Program in...5 sec"
	sleep 5

	Help
	read -p "Enter Your Choice :" choiceYN
	while [ $choiceYN == 'y' -o $choiceYN == 'Y' ]; do
		Help
		read -p "Enter Your Choice From the above options :" choice
		if [ $choice == 1 ]; then
			echo "hi"
		elif [ $choice == 2 ]; then
			AdminTools 2
		elif [ $choice == 3 ]; then
			AdminTools 1
		elif [ $choice == 4 ]; then
			Font
		elif [ $choice == 5 ]; then
			SetWallpaper
		elif [ $choice == 6 ]; then
			read -p $'1. Git Config\n2. GitLab Config' Choose
			if [ $Choose -eq 1 ]; then
				GitConfig
			else
				GitLabConfig
			fi
		elif [ $choice == 7 ]; then
			Terminals
		elif [ $choice == 8 ]; then
			Shell
		elif [ $choice == 9 ]; then
			Lang
		elif [ $choice == 10 ]; then
			DE 1
		elif [ $choice == 11 ]; then
			DE 2
		elif [ $choice == 12 ]; then
			DE 3
		elif [ $choice == 13 ]; then
			DE 4
		elif [ $choice == 14 ]; then
			DE 5
		elif [ $choice == 15 ]; then
			DE 6
		elif [ $choice == 'G' -o $choice == 'g' ]; then
			gpl
		elif [ $choice == 'Q' -o $choice == 'q' ]; then
			clear
			echo "ThankYou For Using the Program."
			break
		fi
	done
	Quit

}

# -------------------------------------------------------------------------------TESTING-----------------------------------------------------------------------

# cd /etc
# $Dir
# PkgMgr="sudo $(cd Data && ./pkgmngrcheck.sh | cut -d " " -f3)"
# echo $PkgMgr
