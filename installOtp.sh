#!/bin/bash
#install OTP

installOtp()
{
    apt-get install -yq  libpam-google-authenticator 
    if (($?)); then exitError  "Impossible d'installer google authentificator." "140"; fi

    # Activate OTP on login :
    ecrirLog "création OTP pour l'utilisateur ${SSH_USER}" "WARN"
    touch /home/${SSH_USER}/${SSH_USER}.auth
    if (($?)); then exitError  "Impossible de creer le fichier de l'utilisateur" "141"; fi
    chmod 777 /home/${SSH_USER}/${SSH_USER}.auth
     if (($?)); then exitError  "Impossible de donner les droits au fichier de l'utilisateur" "142"; fi
    su -c "google-authenticator --time-based  --window-size=3 --disallow-reuse  --step-size=40 --force --rate-limit=3 --rate-time=30 >/home/${SSH_USER}/${SSH_USER}.auth" ${SSH_USER}
    if (($?)); then exitError  "Impossible de lancer Google-Authenticator" "143"; fi
    more /home/${SSH_USER}/${SSH_USER}.auth | mail ${SSH_MAIL_RECEVER} -s "$SSH_USER information connexion !!"
     if (($?)); then exitError  "Impossible d'envoyer l'Email à al'utilisateur" "144"; fi
    chmod 700 /home/${SSH_USER}/${SSH_USER}.auth
    if (($?)); then exitError  "Impossible de donner les droits au fichier de l'utilisateur" "145"; fi
    mv /home/${SSH_USER}/${SSH_USER}.auth ./${SSH_USER}.auth
    if (($?)); then exitError  "Impossible de déplaver le fichier de l'utilisateur" "146"; fi
    ecrirLog "Activate 2FA (One Time Password on login) :" "DEBUG"
    echo "# Activate 2FA (One Time Password on login) :" >> /etc/pam.d/sshd
    if (($?)); then exitError  "Impossible modifier sshd" "147"; fi
 #   echo " auth required pam_google_authenticator.so" >> /etc/pam.d/sshd
 #   if (($?)); then exitError  "Impossible modifier sshd" "147-1"; fi
#sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g" /etc/ssh/sshd_config
#if (($?)); then exitError  "Impossible modifier la conf de sshd" "148"; fi
# Restart ssh :
#/etc/init.d/ssh restart
#if (($?)); then exitError  "Impossible de redemarrer sshd" "148"; fi

#ecrirLog "OTP was activated." "WARN"

}



