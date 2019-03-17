#!/bin/bash
################
#      logcheck        #
################

installLogcheck()
{
    ecrirLog "configuration de logCheck"
    apt-get -yq install logcheck
    if (($?)); then exit 17; fi
    cp /etc/logcheck/logcheck.conf{,.ori}
    if (($?)); then exit 18; fi
    cp /etc/logcheck/logcheck.logfiles{,.ori}
    if (($?)); then exit 19; fi
    sed -i -r "s|^SENDMAILTO=.*$|SENDMAILTO=\"$LOGCHECK_MAIL_RECEVER\"|" /etc/logcheck/logcheck.conf    
    if (($?)); then exit 19; fi
}

