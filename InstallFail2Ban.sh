#!/bin/bash

installFailToBan()
{
    command -v fail2ban >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] fail2ban command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install fail2ban
        if (($?)); then exit 9; fi
    }

    ############
    #  Fail2ban   #
    ############
    ecrirLog "Configuration Fail2ban"
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    if (($?)); then exit 50; fi
    sed -i "s/bantime  = 600/bantime  = $F2B_BAN_TIME/g" /etc/fail2ban/jail.local
    if (($?)); then exit 51; fi
    sed -i "s/maxretry = 5/maxretry = $F2B_RETRY/g" /etc/fail2ban/jail.local
    if (($?)); then exit 52; fi
    sed -i "s/port    = ssh/port    = $SSH_PORT/g" /etc/fail2ban/jail.local
    if (($?)); then exit 53; fi
    sed -i "s/destemail = root@localhost/destemail = $FAILTOBAN_MAIL_RECEVER/g" /etc/fail2ban/jail.local
    if (($?)); then exit 54; fi
    sed -i "s/sender = root@localhost/sender = $FAILTOBAN_MAIL_SENDER/g" /etc/fail2ban/jail.local
    if (($?)); then exit 55; fi
    sed -i "s/mta = sendmail/mta = mail/g" /etc/fail2ban/jail.local
    if (($?)); then exit 56; fi
    sed -i "s/action = %(action_)s/action = %(action_mwl)s/g" /etc/fail2ban/jail.local
    if (($?)); then exit 57; fi
    fail2ban-client reload
    if (($?)); then exit 58; fi
#questionOuiExit "Is every thing OK for now? fail to ban has been configured"
}


