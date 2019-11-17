#!/bin/bash
################
#      RkHunter       #
#https://howto.biapy.com/fr/debian-gnu-linux/systeme/securite/installer-rootkit-hunter-sur-debian#
################
installRkhunter()
{
ecrirLog "configuration de rkhunter" "INFO"
#installation
if [ -n "$(command apt-cache pkgnames libmd5-perl)" ]; then
  command apt-get -y install rkhunter libmd5-perl
  if (($?)); then exitError  "Impossible d'intaller RKHUNTER" "150"; fi
else
  command apt-get -y install rkhunter libdigest-md5-file-perl
  if (($?)); then exitError  "Impossible d'intaller RKHUNTER" "150-1"; fi
fi
#Ignorez les faux positifs déclenchés par les dossiers et fichiers systèmes cachés:
command sed -i -e 's|^[#]*\(ALLOWHIDDENDIR=/dev/.udev\)$|\1|' \ 
                       -e 's|^[#]*\(ALLOWHIDDENDIR=/dev/.static\)$|\1|' \ 
                       -e 's|^[#]*\(ALLOWHIDDENDIR=/dev/.initramfs\)$|\1|' \  
                  "/etc/rkhunter.conf"
 if (($?)); then exitError  "Impossible de modifier la conf de RKHUNTER" "151"; fi
 #Si votre système utilise Java, ignorez le dossier associé:
if [ -e "/etc/.java" ]; then
  command sed -i -e 's|^[#]*\(ALLOWHIDDENDIR=/etc/.java\)$|\1|' \
         "/etc/rkhunter.conf"
   if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-1"; fi
fi
#Si votre système utilise le raid logiciel, ignorez le dossier associé:
if [ -x "/sbin/mdadm" ]; then
  command sed -i -e 's|^[#]*\(ALLOWHIDDENDIR=/dev/.mdadm\)$|\1|' \
         "/etc/rkhunter.conf"
  if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-2"; fi
fi
#Si votre système utilise l'utilitaire hdparm, ignorez les fichiers associés:
if [ -x "/sbin/hdparm" ]; then
  command sed -i -e 's|^[#]*\(RTKT_FILE_WHITELIST="\)\(.*\)$|\1/etc/init.d/.depend.boot /etc/init.d/hdparm\2|' \
         "/etc/rkhunter.conf"
   if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-3"; fi
fi
#Si votre système de dispose pas du fichier /proc/modules, désactivez le test concerné:
if [ ! -e "/proc/modules" ]; then
 command sed -i -e 's|^[#]*\(DISABLE_TESTS="\)\(.*\)$|\1os_specific \2|' \
 "/etc/rkhunter.conf"
 if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-4"; fi
fi
#Ignorez les fichiers block temporaires:
command sed -i -e '0,/ALLOWHIDDENFILE/{//a\
ALLOWHIDDENFILE=/dev/.tmp-block-*
;}' \
           "/etc/rkhunter.conf"
if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-5"; fi
#Autorisez la présence des informations de configuration réseau:
if [ -e "/dev/shm/network/ifstate" ]; then
  command sed -i -e '0,/ALLOWDEVFILE/{//a\
ALLOWDEVFILE=/dev/shm/network/ifstate
;}' \
           "/etc/rkhunter.conf"
if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-6"; fi
fi
#La distribution Debian mettant en place des patchs de sécurité sans mettre à jour les numéros de version des applications, nous ajoutons les applications concernées en liste blanche:
if [ -n "$(command apt-cache show ssh | command grep "5.1p1")" ]; then
  command sed -i -e 's|^[#]*\(APP_WHITELIST=\).*$|\1"exim:4.69 gpg:1.4.9 openssl:0.9.8g sshd:5.1p1"|' \
      "/etc/rkhunter.conf"
      if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-7"; fi
fi
if [ -n "$(command apt-cache show ssh | command grep "5.5p1")" ]; then
  command sed -i -e 's|^[#]*\(APP_WHITELIST=\).*$|\1"gpg:1.4.10 openssl:0.9.8o sshd:5.5p1"|' \
      "/etc/rkhunter.conf"
      if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-8"; fi
fi
#Si votre système autorise les connexions de l'utilisateur root en SSH, désactivez l'alerte associée:
SSH_ROOT_ALLOWED=no
TEST_ROOT_ALLOWED=$(/bin/grep -i "PermitRootLogin.*yes" /etc/ssh/sshd_config)
if [ -n "$TEST_ROOT_ALLOWED" ]; then
  SSH_ROOT_ALLOWED=yes
fi
command sed -i \
            -e "s|^[#]*\\(ALLOW_SSH_ROOT_USER=\\).*$|\\1${SSH_ROOT_ALLOWED}|" \
         "/etc/rkhunter.conf"
  if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-9"; fi
  #Rootkit Hunter permet de maintenir une base de signatures des fichiers système basées sur les informations fournies par le gestionnaire de paquets Debian. Cette base est ensuite utilisée pour vérifier si les fichiers systèmes critiques ont subit une modification par un tiers. De telles modifications sont souvent le signe d'une infection. Activez cette fonctionnalité à l'aide de la commande:
command sed -i -e 's|^[#]*\(HASH_FUNC=\).*$|\1md5sum|' \
            -e 's|^[#]*\(PKGMGR=\).*$|\1DPKG|' \
    "/etc/rkhunter.conf"
  if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-10"; fi    
 #Activez la mise à jour automatique de la base des signatures après chaque utilisation d'apt-get:   
if [[ ! -e '/etc/apt/apt.conf.d/90rkhunter' ]]; then
 command echo '// Update rkhunter file signatures databases after running dpkg. DPkg::Post-Invoke { "if [ -x /usr/bin/rkhunter ]; then if [ $(/usr/bin/rkhunter --help | /bin/grep "propupd" | /usr/bin/wc -l) -gt 0 ]; then /usr/bin/rkhunter --propupd; fi; fi"; };' > '/etc/apt/apt.conf.d/90rkhunter'
  if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-11"; fi    
fi
[[ -e '/etc/default/rkhunter' ]] && command sed -i -e 's/^APT_AUTOGEN=.*$/APT_AUTOGEN="yes"/' '/etc/default/rkhunter'
if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-12"; fi 
#changer l'adresse mail de l'envois des rapports
command sed -i "s/REPORT_EMAIL=\"root\"/REPORT_EMAIL=\"${RKHUNTER_MAIL_RECEVER}\"/g" /etc/default/rkhunter
 if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-13"; fi 
sed -i "s/^#MAIL-ON-WARNING=.*/MAIL-ON-WARNING=${RKHUNTER_MAIL_RECEVER}/" /etc/rkhunter.conf
if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "151-14"; fi 
 #Mettez à jour la base des signatures:   
command rkhunter --propupdate
 if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "152"; fi 
# Mettez à jour la base des menaces de Rootkit Hunter (par la suite elle est mise à jour chaque semaine):
command rkhunter --update
 if (($?)); then exitError  "Impossible de modifier la conf RKHUNTER" "153"; fi 

#on lance la comande pour vérifier que tout est OK:
command rkhunter --configfile /etc/rkhunter.conf --report-warnings-only --checkall
 if (($?)); then exitError  "Impossible d'intaller RKHUNTER" "154"; fi
}
