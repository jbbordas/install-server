#!/bin/bash
################
#      CLAMAV       #
#https://tommygingras.com/installation-et-configuration-dun-antivirus-clamav/#
################
installClamAv()
{
ecrirLog "configuration de ClamAv" "INFO"
#installation
apt-get install -q -y clamav clamav-daemon
if (($?)); then exitError  "Impossible d'intaller clamav" "160"; fi
# Mise à jour de la base de données
service clamav-freshclam stop
if (($?)); then exitError  "Impossible de mettre a jour clamav" "161"; fi
freshclam
if (($?)); then exitError  "Impossible de mettre a jour clamav" "161-1"; fi
service clamav-freshclam start
if (($?)); then exitError  "Impossible de relancer clamav" "161-2"; fi
/etc/init.d/clamav-daemon start
if (($?)); then exitError  "Impossible de relancer clamav" "161-3"; fi
#ecriture du fichier de conf
echo '#!/bin/bash' > /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162"; fi
echo "LOGFILE=\"/var/log/clamav/clamav-$(date +'%Y-%m-%d').log\";" >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-1"; fi
echo 'EMAIL_MSG="Please see the log file attached.";' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-2"; fi
echo "EMAIL_FROM=\"${CLAMAV_MAIL_SENDER}\";" >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-2"; fi
echo "EMAIL_TO=\"${CLAMAV_MAIL_RECEVER}\";" >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-3"; fi
echo 'DIRTOSCAN="/";' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-4"; fi
echo 'for S in ${DIRTOSCAN}; do' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-5"; fi
echo 'DIRSIZE=$(du -sh "$S" 2>/dev/null | cut -f1);' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-6"; fi
echo 'echo "Starting a daily scan of "$S" directory.' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-7"; fi
echo 'Amount of data to be scanned is "$DIRSIZE".";' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-8"; fi
echo 'clamscan --exclude-dir="^/sys" -ri "$S" >> "$LOGFILE";' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-8"; fi
echo '# get the value of "Infected lines"' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-9"; fi
echo 'MALWARE=$(tail "$LOGFILE"|grep Infected|cut -d" " -f3);' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-10"; fi
echo '# if the value is not equal to zero, send an email with the log file attached' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-11"; fi
echo 'if [ "$MALWARE" -ne "0" ];then' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-12"; fi
echo '# using heirloom-mailx below' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-13"; fi
echo 'echo "$EMAIL_MSG"|mail -a "$LOGFILE" -s "Malware Found" -r "$EMAIL_FROM" "$EMAIL_TO";' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-14"; fi
echo 'fi' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-15"; fi
echo 'done' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-16"; fi
echo 'exit 0' >> /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible d''ecrire le fichier de conf CRON" "162-17"; fi
chmod 0755 /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible de modifier les drois du fichier de conf CRON" "163"; fi
#On test le script quotidien, si un élément est trouvé alors il envoi un courriel. Sinon rien n'est envoyé.
#Les logs se situe : /var/log/clamav/clamav-YEAR-MONTH-DAY.log"
bash /etc/cron.daily/clamscan_daily
if (($?)); then exitError  "Impossible de lancer CLAMAV" "164"; fi
}