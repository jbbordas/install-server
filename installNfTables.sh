#!/bin/bash
# FireWall nftables installation and Configuration

installNfTables()
{
    command -v nft >/dev/null 2>&1 || {
        ecrirLog "nft command is not install. We are going to do it!" "INFO"
        # nft non installer, on l'install
        apt-get -yq install nftables
        if (($?)); then exitError "impossible d'installer nftable" "070"; fi
    }

    #############
    #    nftables     #
   #############
    ecrirLog "configuration nftable"
    echo "  
#!/usr/sbin/nft -f
#https://docs.snowme34.com/en/latest/reference/devops/debian-firewall-nftables-and-iptables.html
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        ct state invalid drop
        ct state new,related tcp flags & (fin|syn|rst|psh|ack|urg) != syn limit rate 2/second burst 3 packets  log prefix \"TCP INPUT without SYN \" drop
        tcp flags & (fin|syn|rst|psh|ack|urg) eq 0 limit rate 2/second burst 3 packets log prefix \"INPUT_NULL \" drop
        tcp flags & (fin|psh|urg) eq (fin|psh|urg) limit rate 2/second burst 3 packets log prefix \"INPUT_XMASS \" drop
       
        tcp dport ${SSH_PORT}  ct state new accept # change to your own ssh port
        ct state related,established accept

        # no ping floods:
        ip protocol icmp icmp type echo-request limit rate over 10/second burst 4 packets drop
        ip6 nexthdr icmpv6 icmpv6 type echo-request limit rate over 10/second burst 4 packets drop

        # ICMP & IGMP
        ip6 nexthdr icmpv6 icmpv6 type { echo-request, destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-reduction, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, nd-neighbor-solicit, nd-neighbor-advert, mld-listener-report } accept
        ip protocol icmp icmp type { echo-request, destination-unreachable, router-solicitation, router-advertisement, time-exceeded, parameter-problem } accept
        ip protocol igmp accept
        icmpv6 type { destination-unreachable, time-exceeded, parameter-problem } accept
        

        # avoid brute force on ssh, and your ssh port here
        tcp dport ${SSH_PORT} ct state new limit rate 15/minute accept # change to your own ssh port

        # http server
        tcp dport { http, https} ct state established,new accept
        udp dport { http, https} ct state established,new accept

        # some ports you like
        tcp dport { 123, 25,1212} ct state established,new accept
        udp dport { 123, 25,1212} ct state established,new accept

        ct state invalid drop
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
        tcp dport { http, https } ct state { established,new } accept
        udp dport { http, https } ct state { established,new } accept

    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}

"> firewall
    if (($?)); then exitError "impossible d'écrire le fichier de conf" "071"; fi
    cp /etc/nftables.conf /etc/nftables.conf.bak
    if (($?)); then exitError "impossible de copier le fichier de conf" "072"; fi
     mv firewall /etc/nftables.conf
    if (($?)); then exitError "impossible de bouger le fichier de conf" "073"; fi
    systemctl enable nftables
    if (($?)); then exitError "impossible d'activer nftable" "074"; fi
    systemctl start nftables
   if (($?)); then exitError "impossible de démarer le service nftable" "075"; fi

}

