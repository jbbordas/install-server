#!/bin/bash
#https://wiki.meurisse.org/wiki/Fail2Ban#nftables
installFailToBan()
{
    command -v fail2ban >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] fail2ban command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install fail2ban
        if (($?)); then exit 9; fi
    }
mkdir /etc/nftables/
echo "
#!/usr/sbin/nft -f

# Use ip as fail2ban doesn't support ipv6 yet
table ip fail2ban {
        chain input {
                # Assign a high priority to reject as fast as possible and avoid more complex rule evaluation
                type filter hook input priority 100;
        }
}">/etc/nftables/fail2ban.conf

echo "include \"/etc/nftables/fail2ban.conf\"">>/etc/nftables.conf
nft -f /etc/nftables/fail2ban.conf

echo "
[Init]
# Definition of the table used
nftables_family = ip
nftables_table  = fail2ban

# Drop packets 
blocktype       = drop

# Remove nftables prefix. Set names are limited to 15 char so we want them all
nftables_set_prefix =
">/etc/fail2ban/action.d/nftables-common.local

echo "
# Jail for more extended banning of persistent abusers
# !!! WARNINGS !!! 
# 1. Make sure that your loglevel specified in fail2ban.conf/.local
#    is not at DEBUG level -- which might then cause fail2ban to fall into
#    an infinite loop constantly feeding itself with non-informative lines
# 2. If you increase bantime, you must increase value of dbpurgeage
#    to maintain entries for failed logins for sufficient amount of time.
#    The default is defined in fail2ban.conf and you can override it in fail2ban.local
[recidive]
enabled   = true
logpath   = /var/log/fail2ban.log
banaction = nftables-allports
bantime   = 86400 ; 1 day
findtime  = 86400 ; 1 day 
maxretry  = 3 
protocol  = 0-255
" >/etc/fail2ban/jail.d/recidive.conf

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
    sed -i "s/banaction = iptables-multiports/banaction = nftables-multiports/g" /etc/fail2ban/jail.local
      if (($?)); then exit 57; fi
    sed -i "s/chain = <known/chain>s/chain = inputs/g" /etc/fail2ban/jail.local
    if (($?)); then exit 57; fi

    fail2ban-client reload
    if (($?)); then exit 58; fi
#questionOuiExit "Is every thing OK for now? fail to ban has been configured"
}


