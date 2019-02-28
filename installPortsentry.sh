#!/bin/bash
command -v portsentry >/dev/null 2>&1 || {
ecrirLog "[ WARN ] portsentry command is not install. We are going to do it!"
# sudo non installer, on l'install
apt-get -yq install portsentry
if (($?)); then exit 9; fi
}

###############
# Portsentry  #
###############
ecrirLog "configuration Portsentry"
# Add white-listed IPs to ignore list:
for i in "${PORTSENTRY_IGNORE[@]}"; do
echo $i >> /etc/portsentry/portsentry.ignore
if (($?)); then exit 37; fi
done

# Change mode to auto (more efficient):
sed -i 's/TCP_MODE="tcp"/TCP_MODE="atcp"/g' /etc/default/portsentry
if (($?)); then exit 38; fi
sed -i 's/UDP_MODE="udp"/UDP_MODE="audp"/g' /etc/default/portsentry
if (($?)); then exit 39; fi

# Enable scanports detection:
sed -i 's/BLOCK_TCP="0"/BLOCK_TCP="2"/g' /etc/portsentry/portsentry.conf
if (($?)); then exit 40; fi
sed -i 's/BLOCK_UDP="0"/BLOCK_UDP="2"/g' /etc/portsentry/portsentry.conf
if (($?)); then exit 41; fi

# Enable DNS
sed -i 's/RESOLVE_HOST = "0"/RESOLVE_HOST = "1"/g' /etc/portsentry/portsentry.conf
if (($?)); then exit 42; fi

#Configuration for the external commande
sed -i 's/#KILL_RUN_CMD_FIRST = "0"/KILL_RUN_CMD_FIRST = "1"/g' /etc/portsentry/portsentry.conf
if (($?)); then exit 43; fi

sed -i 's&#KILL_RUN_CMD="/some/path/here/script $TARGET$ $PORT$ $MODE$"&KILL_RUN_CMD="/etc/portsentry/commands/notify.sh $TARGET$ $PORT$ $MODE$"&g' /etc/portsentry/portsentry.conf
if (($?)); then exit 44; fi

mkdir /etc/portsentry/commands
if (($?)); then exit 45; fi
cat > /etc/portsentry/commands/notify.sh <<- EOM
#!/bin/bash
mail_from="portsentry@save.cloud.whita.net"
mail_to="admin@whita.net"
# grep into /etc/services to check which port was scanned
MODE=\${3/[sa]/}         # get rid of s and a
SERVICEINFO=\`grep "[[:space:]]\$2/\$MODE" /etc/services\`
# can we get some info about the attacker?
FINGERINFO=\`/usr/sbin/safe_finger -l @\$1 2>/dev/null\`
cat <> /var/lib/portsentry/notify.log
PortSentry: \$1 scanned \$HOSTNAME:\$2/\$3
Someone @\$1 scanned on host \$HOSTNAME
the service (from /etc/services): 
\$SERVICEINFO
additional information (from reverse finger):
\$FINGERINFO
EOF
echo"PortSentry: $1 scanned $HOSTNAME:$2/$3
Someone @$1 scanned on host $HOSTNAME
the service (from /etc/services): 
$SERVICEINFO
additional information (from reverse finger):
$FINGERINFO" | mail -s "[portsentry] - A scan has been spotted on \`hostname --fqdn\`" $mail_to 
EOM

if (($?)); then exit 46; fi
# Redirect portsentry logs to a dedicated log file:
echo -e ":msg,contains,\"portsentry \" /var/log/portsentry.log" >> /etc/rsyslog.d/portsentry.conf
if (($?)); then exit 47; fi
service rsyslog restart
if (($?)); then exit 48; fi
# Restart service:
systemctl restart portsentry
if (($?)); then exit 49; fi
#questionOuiExit "Is every thing OK for now? Portsentry has been configured"

