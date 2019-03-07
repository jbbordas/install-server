#!/bin/bash
#
# -- securize_server.sh --
#
# INTRODUCTION:
#--------------
#
# This script install and configure a set of tools in order to increase the 
# security level of your server :
#  1- It tweaks ssh :
#      - Change default port
#      - Remove root hability to log in
#      - Restrict allowed users to a specified list
#  2- Configure a basic firewall with iptables.
#  6- Install and configure fail2ban.
#
# HOW TO USE THIS SCRIPT :
#-------------------------
#
# 1- Adapt variables.
# 3- Execute the script.
#
# NOTES :
#--------
#
# To add :
# - ssh double authent

#Where do you want to pu the log file
#if null the log will be only in the output
FICLOG=/var/log/install.log

#set Git parameter
GIT_USERNAME=username
GIT_MAIL=email@domain.ltd

# Set the port you want to use for ssh :
SSH_PORT=1212

# Set user Root chansing password 
#Won't be change if null:
SSH_ROOT_NEW_PWD="newPassword!"

# Set user that will have the right to log in through ssh :
SSH_USER="userssh"
SSH_USER_PWD="passwordssh"

#set the email adresse for ssh connexion notification
SSH_MAIL_RECEVER="email@domaine.ltd" 

# Set ban time in seconds (default to 1h):
F2B_BAN_TIME=600

# Set max retries before ban (default to 3):
F2B_RETRY=4

# Set the ports you need to be open :
PORT_OPEN[0]=80     # HTTP
PORT_OPEN[1]=443    # HTTPS
PORT_OPEN[2]=123    # NTP
PORT_OPEN[3]=25     # SMTP
PORT_OPEN[4]=$SSH_PORT     # SSH : used for honeypotting


# Portsentry ignore IPs:
PORTSENTRY_IGNORE[0]=8.8.8.8
PORTSENTRY_IGNORE[1]=8.8.4.4


###################################################################################
#                                     /!\                                         #
#   /!\  Unless you know exactly what you're doing, do not change anything  /!\   #
#                                     /!\                                         #
###################################################################################

ecrirLog()
{
	if [  -n "${FICLOG}" ];
	then
	 #  temporairement on log quand même en console
	    echo -e "$1"
		echo -e "$1" >> ${FICLOG}
	else
		echo -e "$1"
	fi
}


export DEBIAN_FRONTEND=noninteractive
# Check is linux is Debian based:
if [ ! -f /etc/debian_version ]; then
ecrirLog "[ ERR ] This script has been writen for Debian-based distros."
exit 1
fi

# Check if root or sudo:
if [[ $(id -u) -ne 0 ]] ; then 
ecrirLog  '[ ERR ]Please run me as root or with sudo'
exit 2
fi

apt-get -yq update 
if (($?)); then exit 3; fi
apt-get -yq upgrade
if (($?)); then exit 4; fi

#intallation de Gith et récupération du reste des scripts:
apt-get install -yq git   
git init
# Identity Name
git config --global user.name "${GIT_USERNAME}"
# Identity Email
git config --global user.email "${GIT_MAIL}"

git clone https://github.com/jbbordas/install-server.git install

chmod -R 744 install/
if (($?)); then exit 5; fi

#Change root Password
./install/rootPwd.sh
changeRootPwd()
#Install application if needed sudo, setcap, tar, python
./install/installApp.sh
installApplication()

#create User 
./install/installUser.sh
installUser()

#install mail, and configure it
./install/installMail.sh
installMail

#Install and configure NTP
./install/installNtp.sh

#Configure SSH
./install/installSsh.sh

#install firewall and configure it
./install/installIptables.sh

#install portsentry and configure it
#@TODO: change mail in variable
./install/installPortsentry.sh

#install fail2ban and configure it
#@TODO: change mail in variable
./install/InstallFail2Ban.sh

./install/installNgixShellinaboxMunin.sh

./install/installOtp.sh

###############
#  Finishing  #
###############

ecrirLog "Everything is installed."


#echo " "
#echo -e "IMPORTANT:"
#echo -e "----------"
#echo " "
#echo -e "Before closing this session, open a second one and try to connect to this server."
#echo -e "If the connection is successfull, then you can close safelly."
ecrirLog " don't forget to check is your server can't be use for spam: http://www.spamhelp.org/shopenrelay/shopenrelaytest.php." 
exit 0