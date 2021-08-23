#! /bin/bash
# _____              _          ___           _        _ _       _
# |  ___| __ ___  ___| |__      |_ _|_ __  ___| |_ __ _| | |  ___| |__       By - Aditya Singh Tomar
# | |_ | '__/ _ \/ __| '_ \ _____| || '_ \/ __| __/ _` | | | / __| '_ \      Contact - adityastomar67@gmail.com
# |  _|| | |  __/\__ \ | | |_____| || | | \__ \ || (_| | | |_\__ \ | | |     github - @adityastomar67
# |_|  |_|  \___||___/_| |_|    |___|_| |_|___/\__\__,_|_|_(_)___/_| |_|     www -
#
function nounistall
{
	echo -e "I knew you are still lazy :D :D "
	sleep 2
	echo -e "If you want any feature to be added, contact me on FB"
	sleep 2
	echo -e " "
	echo -e "Aris"
	sleep 1
	exit
}
echo -e "Do you really want to uninstall the Lazy script from your system?(y/n)(Enter=no): "
read CHUN
if [ "$CHUN" = "y" ]
then
	echo -e "If you have any problems please contact me first."
	echo -e "Do you still wanna get rid of me?(y/n)(Enter=no): "
	read CHCHUN
	if [ "$CHCHUN" = "y" ]
	then
		echo -e "Ok, uninstalling everything that has to do with lscript on your system"
		sleep 4
		rm -r /bin/lscript
		echo -e "Done."
		sleep 1
		echo -e "You need to manually delete the lscript folder from your /root/ directory though..."
		sleep 2
		echo -e "Press any key to exit..."
		read
		exit
	else
		nounistall
	fi
else
	nounistall
fi
