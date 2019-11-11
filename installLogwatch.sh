#!/bin/bash
################
#      LogWatch        #
################

installLogwatch()
{
    ecrirLog "configuration de logCheck" "INFO"
    apt-get -yq install logwatch
     if (($?)); then exitError "impossible d'installer logwatch" "130"; fi
    cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
    if (($?)); then exitError "impossible de copier la conf de logwatch" "131"; fi
    mkdir /var/cache/logwatch
    if (($?)); then exitError "impossible de crer le cach de logwatch" "132"; fi
    echo "LogDir = /var/log
 TmpDir = /var/cache/logwatch
 Output = mail
 Format = html
 Encode = none
 MailTo = $LOGWATCH_MAIL_RECEVER
 MailFrom = $LOGWATCH_MAIL_SENDER
 Range = yesterday
 Detail = Medium
 Service = All" > /etc/logwatch/conf/logwatch.conf
   if (($?)); then exitError "impossible d'écrire la conf de logwatch" "133; fi
}

