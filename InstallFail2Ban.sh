#!/bin/bash
#https://wiki.meurisse.org/wiki/Fail2Ban#nftables

    ############
    #  Fail2ban   #
    ############
installFailToBan()
{
    command -v fail2ban >/dev/null 2>&1 || {
        ecrirLog "fail2ban command is not install. We are going to do it!" "INFO"
        # sudo non installer, on l'install
        apt-get -yq install fail2ban
        if (($?)); then exitError "impossible d'installer fail2ban" "080"; fi
    }
mkdir /etc/nftables/
echo "
#!/usr/sbin/nft -f
# Use ip as fail2ban doesn't support ipv6 yet
table inet fail2ban {
        chain input {
                # Assign a high priority to reject as fast as possible and avoid more complex rule evaluation
                type filter hook input priority 100;
        }
}">/etc/nftables/fail2ban.conf
 if (($?)); then exitError "impossible d'écrir le fichier de configuration de fail2ban" "081"; fi


echo "include \"/etc/nftables/fail2ban.conf\"">>/etc/nftables.conf
 if (($?)); then exitError "impossible de modifier la configuration de nftables" "082"; fi

nft -f /etc/nftables/fail2ban.conf
 if (($?)); then exitError "impossible d'activer fail2ban dans nftables" "083"; fi

echo "
[Init]
# Definition of the table used
nftables_family = inet
nftables_table  = fail2ban

# Drop packets 
blocktype       = drop

# Remove nftables prefix. Set names are limited to 15 char so we want them all
nftables_set_prefix =
">/etc/fail2ban/action.d/nftables-common.local
 if (($?)); then exitError "impossible de créer la conf nftables Failéban fail2ban" "084"; fi

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
 if (($?)); then exitError "impossible d'écrire le fichier de recidive fail2ban" "085"; fi


    ############
    #  Fail2ban   #
    ############
    ecrirLog "Configuration Fail2ban"
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    if (($?)); then exitError "impossible de copier le fichier jail.local de fail2ban" "086"; fi
    sed -i "s/bantime  = 600/bantime  = $F2B_BAN_TIME/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-1"; fi
    sed -i "s/maxretry = 5/maxretry = $F2B_RETRY/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-2"; fi
    sed -i "s/port    = ssh/port    = $SSH_PORT/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-3"; fi
    sed -i "s/destemail = root@localhost/destemail = $FAILTOBAN_MAIL_RECEVER/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-4"; fi
    sed -i "s/sender = root@localhost/sender = $FAILTOBAN_MAIL_SENDER/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-5"; fi
    sed -i "s/mta = sendmail/mta = mail/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-6"; fi
    sed -i "s/action = %(action_)s/action = %(action_mwl)s/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-7"; fi
    sed -i "s/banaction = iptables-multiport/banaction = nftables-multiport/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-8"; fi
    sed -i "s/banaction_allports = iptables-allports/banaction = nftables-multiports/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-9"; fi
    sed -i "s/chain = <known\/chain>s/chain = inputs/g" /etc/fail2ban/jail.local
     if (($?)); then exitError "impossible de modifier le fichier Jail.local de fail2ban" "087-10"; fi

    fail2ban-client reload
     if (($?)); then exitError "impossible de relancer fail2ban" "088"; fi
#questionOuiExit "Is every thing OK for now? fail to ban has been configured"
}


