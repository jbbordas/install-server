#!/bin/bash
###############
#     MAIL    #
###############
installMail()
{
    command -v mail >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] mail command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install mailutils
        if (($?)); then exit 10; fi
    }

    # fichier de conf de exim4
    ecrirLog "configuration de MAIL"
    mv /etc/exim4/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf.old
    if (($?)); then exit 14; fi
    echo "  
# /etc/exim4/update-exim4.conf.conf
#
# Edit this file and /etc/mailname by hand and execute update-exim4.conf
# yourself or use 'dpkg-reconfigure exim4-config'
#
# Please note that this is _not_ a dpkg-conffile and that automatic changes
# to this file might happen. The code handling this will honor your local
# changes, so this is usually fine, but will break local schemes that mess
# around with multiple versions of the file.
#
# update-exim4.conf uses this file to determine variable values to generate
# exim configuration macros for the configuration file.
#
# Most settings found in here do have corresponding questions in the
# Debconf configuration, but not all of them.
#
# This is a Debian specific file

dc_eximconfig_configtype='internet'
dc_other_hostnames='`hostname`; localhost; localhoste.localdomain'
dc_local_interfaces='127.0.0.1'
dc_readhost=''
dc_relay_domains=''
dc_minimaldns='false'
dc_relay_nets=''
dc_smarthost=''
CFILEMODE='644'
dc_use_split_config='false'
dc_hide_mailname=''
dc_mailname_in_oh='true'
dc_localdelivery='mail_spool'
"> /etc/exim4/update-exim4.conf.conf
    if (($?)); then exit 15; fi
    systemctl restart exim4
    if (($?)); then exit 16; fi
    #questionOuiExit "Is every thing OK for now mail has been install and configured?"
}


