#!/bin/bash

################
#   shellinabox  #
################
installNgInx()
{
    ecrirLog "Configuration Shellinabox" "INFO"
    apt-get install shellinabox nginx -y
     if (($?)); then exitError "impossible d'installer NGINX ou Shellinabox" "090"; fi
    cat > /etc/default/shellinabox <<- EOM
# sample config
# Should shellinaboxd start automatically
SHELLINABOX_DAEMON_START=1

# TCP port that shellinboxd's webserver listens on
SHELLINABOX_PORT=4200

# Parameters that are managed by the system and usually should not need
# changing:
# SHELLINABOX_DATADIR=/var/lib/shellinabox
# SHELLINABOX_USER=shellinabox
# SHELLINABOX_GROUP=shellinabox

# Any optional arguments (e.g. extra service definitions).  Make sure
# that that argument is quoted.
#
#   Beeps are disabled because of reports of the VLC plugin crashing
#   Firefox on Linux/x86_64.
#   localhost-only makes shellinabox to be browsed by the localhost only.

SHELLINABOX_ARGS="--no-beep --disable-ssl --localhost-only"
#SHELLINABOX_ARGS="--no-beep -s /terminal:LOGIN --disable-ssl --localhost-only"
EOM
     if (($?)); then exitError "impossible de creer le fichier de conf de Shellinabox" "091"; fi

    /etc/init.d/shellinabox restart
     if (($?)); then exitError "impossible de redemarrer Shellinabox" "092"; fi

    ecrirLog "configuration letsEncrypt" "INFO"
    cat > /etc/nginx/snippets/letsencrypt.conf <<- EOM
location ^~ /.well-known/acme-challenge/ {
default_type "text/plain";
allow all;
#root /var/www/letsencrypt;
root /var/www/html;
}
EOM
     if (($?)); then exitError "impossible d'écrire le fichier de conf pour letsencrypt" "093"; fi
    cat > /etc/nginx/sites-enabled/${DNSNAME}.conf <<- EOM
# Default server configuration
server {
listen 80 default_server;
listen [::]:80 default_server;
server_name SERVER_DNS_TO_CHANGE;
include /etc/nginx/snippets/letsencrypt.conf;
location / {
return 301 https://\$server_name\$request_uri;
}
}
EOM
     if (($?)); then exitError "impossible d'installer NGINX ou Shellinabox" "094"; fi
     sed -i "s/server_name SERVER_DNS_TO_CHANGE;/server_name ${DNSNAME}/g" /etc/nginx/sites-enabled/${DNSNAME}.conf
     if (($?)); then exitError "impossible de finir la conf du fichier nginx du serveur" "094-1"; fi
     
    rm /etc/nginx/sites-enabled/default
    if (($?)); then exitError "impossible de supprimer le fichier default" "095"; fi
    cat > /var/www/html/index.html <<- EOM
<html><head><title>Vous Etes Perdu ?</title></head><body><h1>Perdu sur l&rsquo;Internet ?</h1><h2>Pas de panique, on va vous aider
</h2><strong><pre>    * <----- vous &ecirc;tes ici</pre></strong></body></html>
EOM
    if (($?)); then exitError "impossible d'écrire le fichier HTML" "096"; fi
    /etc/init.d/nginx restart
    if (($?)); then exitError "impossible de redemarer serveur" "097"; fi

#installation de letsencrypt pour ssl
    apt-get install certbot -y
    if (($?)); then exitError "impossible d'installer certbot" "100"; fi
    certbot certonly -n -a webroot --webroot-path=/var/www/html -d ${DNSNAME} --email $SSH_MAIL_RECEVER --agree-tos
    if (($?)); then exitError "impossible de lancer certbot" "101"; fi
    #generation clef pour securisation ssl delfihelman
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    if (($?)); then exitError "impossible de générer les clé de sécurités" "102"; fi
    cat > /etc/nginx/snippets/ssl-params.conf <<- EOM
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/ssl/certs/dhparam.pem;
EOM
    if (($?)); then exitError "impossible d'écrire le fichier de paramettre SSL" "103"; fi
    cat > /etc/nginx/snippets/letsencrypt.conf <<- EOM
location ^~ /.well-known/acme-challenge/ {
default_type "text/plain";
allow all;
#root /var/www/letsencrypt;
root /var/www/html;
}
EOM
     if (($?)); then exitError "impossible d'écrire le fichier de conf Letsencrypt" "104"; fi
    cat > /etc/nginx/sites-enabled/${DNSNAME}.conf <<- EOM
# Default server configuration
server {
listen 80 default_server;
listen [::]:80 default_server;
server_name SERVER_DNS_TO_CHANGE_1;
include /etc/nginx/snippets/letsencrypt.conf;
location / {
return 301 https://\$server_name\$request_uri;
}
}
# SSL configuration
server {
server_name SERVER_DNS_TO_CHANGE_2;
listen 443;
ssl on;
ssl_certificate /etc/letsencrypt/live/SERVER_DNS_TO_CHANGE/cert.pem;
ssl_certificate_key /etc/letsencrypt/live/SERVER_DNS_TO_CHANGE/privkey.pem;
include snippets/ssl-params.conf;
access_log off;
error_log off;
location /RequestDenied {
return 418;
}
root /var/www/html;

location /shell/ {
proxy_pass http://127.0.0.1:4200/;
proxy_redirect default;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
client_max_body_size 10m;
client_body_buffer_size 128k;
proxy_connect_timeout 90;
proxy_send_timeout 90;
proxy_read_timeout 90;
proxy_buffer_size 4k;
proxy_buffers 4 32k;
proxy_busy_buffers_size 64k;
proxy_temp_file_write_size 64k;
}

location /munin/ {
auth_basic "Administrator Login";
auth_basic_user_file /var/www/.htpasswd;
root /var/www;
}
location /munin/static/ {
alias /etc/munin/static/;
expires modified +1w;
}
}
EOM
    if (($?)); then exitError "impossible d'écrire le fichier de conf nginx" "105"; fi
    sed -i "s/server_name SERVER_DNS_TO_CHANGE_1;/server_name ${DNSNAME};/g" /etc/nginx/sites-enabled/${DNSNAME}.conf
    if (($?)); then exitError "impossible de modifier le fichier de conf nginx" "105_1"; fi
    sed -i "s/server_name SERVER_DNS_TO_CHANGE_2;/server_name ${DNSNAME};/g" /etc/nginx/sites-enabled/${DNSNAME}.conf
    if (($?)); then exitError "impossible de modifier le fichier de conf nginx" "105_2"; fi
    sed -i "s/ssl_certificate_key /etc/letsencrypt/live/SERVER_DNS_TO_CHANGE/privkey.pem;/ssl_certificate_key /etc/letsencrypt/live/${DNSNAME}/privkey.pem;/g" /etc/nginx/sites-enabled/${DNSNAME}.conf
    if (($?)); then exitError "impossible de modifier le fichier de conf nginx" "105_3"; fi
    sed -i "s/ssl_certificate /etc/letsencrypt/live/SERVER_DNS_TO_CHANGE/cert.pem;/ssl_certificate /etc/letsencrypt/live/${DNSNAME}/cert.pem;/g" /etc/nginx/sites-enabled/${DNSNAME}.conf
    if (($?)); then exitError "impossible de modifier le fichier de conf nginx" "105_4"; fi

    /etc/init.d/nginx restart
    if (($?)); then exitError "impossible de relancer nginx" "106"; fi


    #################
    #  MUNIN MAITRE  #
    #################
#https://blog.nicolargo.com/2012/01/installation-et-configuration-de-munin-le-maitre-des-graphes.html
    ecrirLog "configuration MUNIN"
    apt-get -yq install munin munin-node munin-plugins-extra apache2-utils libwww-perl
    if (($?)); then exitError "impossible d'installer MUNIN" "110"; fi
    ln -s /var/cache/munin/www /var/www/munin
    if (($?)); then exitError "impossible de créer un lien pour MUNIN" "111"; fi
    /etc/init.d/munin-node restart
    iif (($?)); then exitError "impossible de redemarrer MUNIN" "112"; fi
    htpasswd -cb /var/www/.htpasswd  ${SSH_USER} ${SSH_USER_PWD}
   if (($?)); then exitError "impossible de créer le htpasswprd pour MUNIN" "113"; fi
    ln -s /usr/share/munin/plugins/nginx_status /etc/munin/plugins/nginx_status
   if (($?)); then exitError "impossible de créer un lien pour MUNIN" "114"; fi
    ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/nginx_request
    if (($?)); then exitError "impossible de créer un lien pour MUNIN" "115"; fi
#ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/exim_mailqueue
#if (($?)); then exit 74; fi
#ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/exim_mailqueue_alt
#if (($?)); then exit 75; fi
#ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/exim_mailstats
#if (($?)); then exit 76; fi
ln -s /usr/share/munin/plugins/nginx_request /etc/munin/plugins/fail2ban
if (($?)); then exitError "impossible de créer un lien pour MUNIN" "116"; fi

}

