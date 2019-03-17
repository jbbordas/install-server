#!/bin/bash
    ################
    # security update  #
    ################
installSecurityUpdate()
{

    apt-get -yq install cron-apt
    if (($?)); then exit 9; fi

     grep security /etc/apt/sources.list > /etc/apt/security.sources.list
     if (($?)); then exit 9; fi
     echo "
APTCOMMAND=/usr/bin/apt-get
OPTIONS=\"-o quiet=1 -o Dir::Etc::SourceList=/etc/apt/security.sources.list\"
MAILTO=\"$UPDATE_SECURITY_MAIL_RECEVER\"
MAILON=\"always\"
" >> /etc/cron-apt/config
    if (($?)); then exit 9; fi
    sed -i 's/dist-upgrade -d -y -o APT::Get::Show-Upgraded=true/dist-upgrade -y -o APT::Get::Show-Upgraded=true/g' /etc/apt/apt.conf.d/50unattended-upgrades 
    if (($?)); then exit 9; fi
}



