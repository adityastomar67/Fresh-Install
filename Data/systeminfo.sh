#!/usr/bin/env bash
# _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|     www -
#
# This script provides the consolidated details of a linux operaing system

# clear the screen
clear

# Unset Variables
unset sys_date tempvar os architecture kernelrelease internalip externalip nameserver loadaverage sysuptime

# Define Variable tempvar
tempvar=$(tput sgr0)

#Check System date
echo -e '\E[33m'"System Date :" "$tempvar $(date)"

# Check whether the system is connected to Internet or not
ping -c 1 google.com &>/dev/null && echo -e '\E[33m'"Internet: $tempvar Connected" || echo -e '\E[33m'"Internet: $tempvar Disconnected"

# Check OS Type
os=$(uname -o)
echo -e '\E[33m'"Operating System Type :" "$tempvar $os"

# Check OS Release Version and Name
cat /etc/*-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' >/tmp/osrelease
echo -n -e '\E[33m'"OS Name :" $tempvar && cat /tmp/osrelease | grep -v "VERSION" | cut -f2 -d "="
echo -n -e '\E[33m'"OS Version :" $tempvar && cat /tmp/osrelease | grep -v "NAME" | cut -f2 -d "="

# Check System Architecture
architecture=$(uname -m)
echo -e '\E[33m'"Architecture :" "$tempvar $architecture"

# Check Kernel Release
kernelrelease=$(uname -r)
echo -e '\E[33m'"Kernel Release :" "$tempvar $kernelrelease"

# Check hostname
echo -e '\E[33m'"Hostname :" "$tempvar $HOSTNAME"

# Check Internal IP
internalip=$(hostname -i)
echo -e '\E[33m'"Internal IP :" "$tempvar $internalip"

# Check External IP
externalip=$(
    curl -s ipecho.net/plain
    echo
)
echo -e '\E[33m'"External IP :" "$tempvar $externalip"

# Check DNS
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e '\E[33m'"Name Servers :" "$tempvar $nameservers"

# Check Logged In Users
who >/tmp/who
echo -e '\E[33m'"Logged In users :" $tempvar && cat /tmp/who

# Check RAM and SWAP Usages
free -g | grep -v + >/tmp/ramcache
echo -e '\E[33m'"Ram Usages :" $tempvar
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[33m'"Swap Usages :" $tempvar
cat /tmp/ramcache | grep -v "Mem"

# Check Disk Usages
df -h >/tmp/diskusage
echo -e '\E[33m'"Disk Usages :" $tempvar
cat /tmp/diskusage

# System statistics
top -n 1 -b | head -5 >/tmp/sysstats
echo -e '\E[33m'"System Statistics :" $tempvar
cat /tmp/sysstats

# Check System Uptime
sysuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e '\E[33m'"System Uptime Days/(HH:MM) :" $tempvar $sysuptime

# Check the ssh connections to the system
echo -e '\E[33m'"SSH connections made to the system :" $tempvar
w >/tmp/sshconn
cat /tmp/sshconn

# Unset Variables
unset tempvar os architecture kernelrelease internalip externalip nameserver loadaverage sysuptime

# Remove Temporary Files
rm /tmp/osrelease /tmp/who /tmp/ramcache /tmp/diskusage /tmp/sshconn /tmp/sysstats
