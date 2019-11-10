#!/bin/bash
#user create with add in sudo group

installUser()
{
    egrep "^$SSH_USER" /etc/passwd >/dev/null
    if [ $? -ne 0 ]; then
        ecrirLog "the User doesn't existe, we need to create it" "INFO"
        adduser --disabled-password --gecos "" "$SSH_USER"
        if (($?)); then exitError "création utilisateur $SSH_USER impossible" "030"; fi
        echo "${SSH_USER}:${SSH_USER_PWD}" | chpasswd
        if (($?)); then exitError "impossible de changer le mot de passe de l'utilisateur $SSH_USER" "031"; fi
        usermod -a -G sudo "$SSH_USER"
        if (($?)); then exitError "Impossible d'ajouter l'utilisateur $SSH_USER au groupe SUDO" "032"; fi
        ecrirLog "the User $SSH_USER was created" "INFO"
    else
        exitError "l'utilisateur $SSH_USER à déja été créé" "033"
   fi
}

