#!/bin/bash
# FireWall installation and Configuration

installIpTable()
{
    command -v iptables >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] iptables command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install iptables
        if (($?)); then exit 9; fi
    }

    #############
    #    iptables     #
   #############
    ecrirLog "configuration iptables"
    echo "  
#!/bin/sh
#https://www.jgachelin.fr/vps-ovh-debian-8-gestion-de-la-securite/

### BEGIN INIT INFO
# Provides:             firewall
# Required-Start:       $remote_fs $syslog
# Required-Stop:        $remote_fs $syslog
# Default-Start:        2 3 4 5 
# Default-Stop:         0 1 6
# Short-Description:    Start iptables rules
# Description:          Start iptables rules
### END INIT INFO
# Vider les tables et règles
iptables -t filter -F  # Flush existing rules.
iptables -t filter -X # Delete user defined rules.

# Bloquer tout le trafic
iptables -t filter -P INPUT DROP # Drop all input connections.
iptables -t filter -P FORWARD DROP # Drop all output connections.
iptables -t filter -P OUTPUT DROP # Drop all forward connections.

# Conserver les connexions en cours
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT # Don't break established connections.
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT # Don't break established connections.

# Localhost
iptables -t filter -A INPUT -i lo -j ACCEPT  # Allow input on loopback.
iptables -t filter -A OUTPUT -o lo -j ACCEPT # Allow input on loopback.

# DNS In/Out 
# do you have a DNS ?
# if not, you just need Out
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j ACCEPT 
iptables -A INPUT -p udp --dport 53 -j ACCEPT


# Note: RFC 792 states that all hosts MUST respond to ICMP ECHO requests.
# Blocking these can make diagnosing of even simple faults much more tricky.
# Real security lies in locking down and hardening all services, not by hiding.
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT 
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT 
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT 
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT 
iptables -A INPUT -p icmp --icmp-type destination-unreachable -j ACCEPT 
iptables -A INPUT -p icmp --icmp-type source-quench -j ACCEPT 
iptables -A INPUT -p icmp --icmp-type time-exceeded -j ACCEPT 
iptables -A INPUT -p icmp --icmp-type parameter-problem -j ACCE

# Drop all incoming malformed NULL packets
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Drop syn-flood attack packets
iptables -A INPUT -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

# Drop incoming malformed XMAS packets
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

"> firewall
    if (($?)); then exit 31; fi
    for i in "${PORT_OPEN[@]}"; do
        echo "iptables -A INPUT -p tcp --dport $i -j ACCEPT                          # Set specified rules." >> firewall
        if (($?)); then exit 32; fi
        echo "iptables -A OUTPUT -p tcp --dport $i -j ACCEPT                          # Set specified rules." >> firewall
        if (($?)); then exit 33; fi
    done

    chmod +x firewall
    if (($?)); then exit 33; fi
    mv firewall /etc/init.d/firewall
    if (($?)); then exit 34; fi
    /etc/init.d/firewall
    if (($?)); then exit 35; fi
    update-rc.d firewall defaults
    if (($?)); then exit 36; fi

#questionOuiExit "Is every thing OK for now? Ipatables has been configured"

}

