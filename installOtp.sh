#!/bin/bash
#install OTP

installOtp()
{
    apt-get install -yq  libpam-google-authenticator 
    if (($?)); then exit 13; fi

    # Activate OTP on login :
    echo "création OTP pour l'utilisateur ${SSH_USER}"
    touch /home/${SSH_USER}/${SSH_USER}.auth
    if (($?)); then exit 78; fi
    chmod 777 /home/${SSH_USER}/${SSH_USER}.auth
    if (($?)); then exit 79; fi
    su -c "google-authenticator --time-based  --window-size=3 --disallow-reuse  --step-size=40 --force --rate-limit=3 --rate-time=30 >/home/${SSH_USER}/${SSH_USER}.auth" ${SSH_USER}
    if (($?)); then exit 80; fi
    more /home/${SSH_USER}/${SSH_USER}.auth | mail ${SSH_MAIL_RECEVER} -s "$SSH_USER information connexion !!"
    if (($?)); then exit 81; fi
    chmod 700 /home/${SSH_USER}/${SSH_USER}.auth
    if (($?)); then exit 82; fi
    mv /home/${SSH_USER}/${SSH_USER}.auth ./${SSH_USER}.auth
    if (($?)); then exit 83; fi
    echo "Activate 2FA (One Time Password on login) :"
    echo "# Activate 2FA (One Time Password on login) :" >> /etc/pam.d/sshd
    echo "    auth required pam_google_authenticator.so" >> /etc/pam.d/sshd
    if (($?)); then exit 84; fi
#sed -i "s/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g" /etc/ssh/sshd_config
#if (($?)); then exit 84; fi
# Restart ssh :
#/etc/init.d/ssh restart
#if (($?)); then exit 85; fi

#ecrirLog "OTP was activated."

}



