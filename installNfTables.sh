#!/bin/bash
# FireWall nftables installation and Configuration

installNfTables()
{
    command -v nft >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] nft command is not install. We are going to do it!"
        # nft non installer, on l'install
        apt-get -yq install nftables
        if (($?)); then exit 9; fi
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

        iifname lo accept
        ct state invalid drop
        ct state new,related tcp flags & (fin|syn|rst|psh|ack|urg) != syn limit rate 2/second burst 3 packets  log prefix \"TCP INPUT without SYN \" drop
        tcp flags & (fin|syn|rst|psh|ack|urg) eq 0 limit rate 2/second burst 3 packets log prefix \"INPUT_NULL \" drop
        tcp flags & (fin|psh|urg) eq (fin|psh|urg) limit rate 2/second burst 3 packets log prefix \"INPUT_XMASS \" drop
       

        tcp dport ${SSH_PORT}  ct state new accept # change to your own ssh port
        ct state established,related accept

        # no ping floods:
        ip protocol icmp icmp type echo-request limit rate over 10/second burst 4 packets drop
        ip6 nexthdr icmpv6 icmpv6 type echo-request limit rate over 10/second burst 4 packets drop

        # ICMP & IGMP
        ip6 nexthdr icmpv6 icmpv6 type { echo-request, destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-reduction, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, nd-neighbor-solicit, nd-neighbor-advert, mld-listener-report } accept
        ip protocol icmp icmp type { echo-request, destination-unreachable, router-solicitation, router-advertisement, time-exceeded, parameter-problem } accept
        ip protocol igmp accept

        # avoid brute force on ssh, and your ssh port here
        tcp dport ${SSH_PORT} ct state new limit rate 15/minute accept # change to your own ssh port

        # http server
        tcp dport { http, https} ct state established,new accept
        udp dport { http, https} ct state established,new accept

        # some ports you like
        tcp dport { NTP, SMTP} ct state established,new accept
        udp dport { NTP, SMTP} ct state established,new accept

        ct state invalid drop

        # uncomment to enable log, choose one
        #log flags all counter drop
        #log prefix \"[nftables] Input Denied: \" flags all counter drop
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
        tcp dport { http, https } ct state { established,new } accept
        udp dport { http, https } ct state { established,new } accept
        # for dockers
        # dockers have plenty of networks, so it may be required to change accordingly
        #iifname eth0 oifname docker0 ct state { established,new,related } accept
        #oifname eth0 ct state { established,new,related } accept
        # uncomment to enable log
        #log prefix \"[nftables] Forward Denied: \" flags all counter drop
    }
    chain output {
        type filter hook output priority 0; policy accept;
    }
}

"> firewall
    cp /etc/nftables.conf /etc/nftables.conf.bak
     mv firewall /etc/nftables.conf
    if (($?)); then exit 34; fi
     ecrirLog "lancement des iptables"
    systemctl enable nftables
    if (($?)); then exit 35; fi
    systemctl start nftables
   if (($?)); then exit 36; fi

#questionOuiExit "Is every thing OK for now? Ipatables has been configured"

}

