#!/bin/bash
# _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|     www - 
#

declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get

for f in "${!osInfo[@]}"
do
    if [[ -f $f ]];then
        echo Package manager: ${osInfo[$f]}
    fi
done