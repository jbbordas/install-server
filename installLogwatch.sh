#!/bin/bash
################
#      LogWatch        #
################

installLogwatch()
{
    ecrirLog "configuration de logCheck"
    apt-get -yq install logwatch
    if (($?)); then exit 17; fi
    cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
    if (($?)); then exit 18; fi
    mkdir /var/cache/logwatch
    if (($?)); then exit 19; fi
    echo "LogDir = /var/log
 TmpDir = /var/cache/logwatch
 Output = mail
 Format = html
 Encode = none
 MailTo = $LOGWATCH_MAIL_SENDER
 MailFrom = $LOGWATCH_MAIL_RECEVER
 Range = yesterday
 Detail = Medium
 Service = All" > /etc/logwatch/conf/logwatch.conf
    if (($?)); then exit 19; fi
}

