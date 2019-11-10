#!/bin/bash
################
#      NTP          #
################

installNtp()
{
    ecrirLog "configuration de NTP" "INFO"
    apt-get -yq install ntp
    if (($?)); then exitError "impossible d'installer ntp" "050"; fi
    cp /etc/ntp.conf /etc/ntp.conf.old
    if (($?)); then exitError "impossible de copier le fichier de configuration" "051"; fi
    echo "
######## serveur NTP
server ntp.free.fr prefer
server ntp.ubuntu.com prefer
server ntp2.jussieu.fr
server 0.fr.pool.ntp.org
server 0.europe.pool.ntp.org
">> /etc/ntp.conf
    if (($?)); then exitError "impossible d'écrire le fichier de conf" "052"; fi
    /etc/init.d/ntp restart
    if (($?)); then exitError "impossible de démarer ntp" "053"; fi
    rm /etc/localtime
    if (($?)); then exitError "impossible de supprimer le fichier locatime" "054"; fi
    ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
    if (($?)); then exitError "impossible de crée un lien simbolique" "055"; fi
    #questionOuiExit "Is every thing OK for now ntp has been installed and configured?"
}

