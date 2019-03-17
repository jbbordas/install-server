#!/bin/bash
################
#      RkHunter          #
################
ecrirLog "configuration de rkhunter"
apt-get -yq install rkhunter
if (($?)); then exit 17; fi
rkhunter --update
if (($?)); then exit 18; fi
# Créer la base de données
rkhunter --propupd
if (($?)); then exit 18; fi
sed -i 's/CRON_DAILY_RUN=""/CRON_DAILY_RUN="yes"/g' /etc/default/rkhunter    
if (($?)); then exit 18; fi
sed -i "s/REPORT_EMAIL=\"root\"/REPORT_EMAIL=\"${RKHUNTER_MAIL_RECEVER}\"/g" /etc/default/rkhunter
if (($?)); then exit 19; fi
sed -i "s/^MAIL-ON-WARNING=.*/#MAIL-ON-WARNING=/g" /etc/rkhunter.conf
if (($?)); then exit 20; fi
sed -i "s/^#MAIL-ON-WARNING=.*/MAIL-ON-WARNING=$RKHUNTER_MAIL_RECEVER/" /etc/rkhunter.conf
if (($?)); then exit 20; fi
/etc/init.d/ntp restart
if (($?)); then exit 20; fi
rm /etc/localtime
if (($?)); then exit 21; fi
ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
if (($?)); then exit 22; fi
#questionOuiExit "Is every thing OK for now ntp has been installed and configured?"
