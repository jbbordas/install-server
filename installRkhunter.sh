#!/bin/bash
################
#      RkHunter       #
#https://tommygingras.com/installation-et-configuration-de-rkhunter/#
################
installRkhunter()
{
ecrirLog "configuration de rkhunter" "INFO"
#installation
apt-get -y install rkhunter
if (($?)); then exitError  "Impossible d'intaller RKHUNTER" "150"; fi
# Créer la base de données
rkhunter --propupd
if (($?)); then exitError  "Impossible de creer la bdd de RKHUNTER" "151"; fi
sed -i "s/^MAIL-ON-WARNING=.*/#MAIL-ON-WARNING=/g" /etc/rkhunter.conf
if (($?)); then exitError  "Impossible de modifier la conf de rkhunter" "152"; fi
sed -i "s/^#MAIL-ON-WARNING=.*/MAIL-ON-WARNING=${RKHUNTER_MAIL_RECEVER}/" /etc/rkhunter.conf
f (($?)); then exitError  "Impossible de modifier la conf de rkhunter" "152-1"; fi
echo "
SCRIPTWHITELIST=/usr/bin/egrep
SCRIPTWHITELIST=/usr/bin/which
SCRIPTWHITELIST=/usr/bin/fgrep
SCRIPTWHITELIST=/usr/bin/lwp-request" >>/etc/rkhunter.conf
if (($?)); then exitError  "Impossible de modifier la conf de rkhunter" "152-2"; fi

crontab -l > mycron 
echo "0 4 * * * /usr/bin/rkhunter --cronjob --update --quiet" >> mycron
crontab mycron
if (($?)); then exitError  "Impossible de modifier crontab pour rkhunter" "153"; fi


# Mettez à jour la base des menaces de Rootkit Hunter (par la suite elle est mise à jour chaque semaine):
 rkhunter --update
 if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "153"; fi 

#on lance la comande pour vérifier que tout est OK:
rkhunter --configfile /etc/rkhunter.conf --report-warnings-only --checkall
 if (($?)); then exitError  "Impossible de lancer RKHUNTER" "154"; fi
}
