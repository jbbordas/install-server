#!/bin/bash
################
#      NTP          #
################

ecrirLog()
{
	if [  !-z "${FICLOG}" ];
	then
	 #  temporairement on log quand même en console
	    echo -e "$1"
		echo -e "$1" >> ${FICLOG}
	else
		echo -e "$1"
	fi
}

ecrirLog "configuration de NTP"
apt-get -yq install ntp
if (($?)); then exit 17; fi
cp /etc/ntp.conf /etc/ntp.conf.old
if (($?)); then exit 18; fi
echo "
######## serveur NTP
server ntp.free.fr prefer
server ntp.ubuntu.com prefer
server ntp2.jussieu.fr
server 0.fr.pool.ntp.org
server 0.europe.pool.ntp.org
">> /etc/ntp.conf
if (($?)); then exit 19; fi
/etc/init.d/ntp restart
if (($?)); then exit 20; fi
rm /etc/localtime
if (($?)); then exit 21; fi
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
if (($?)); then exit 22; fi
#questionOuiExit "Is every thing OK for now ntp has been installed and configured?"
