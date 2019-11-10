#!/bin/bash
#change root password

changeRootPwd()
{
    if [ -n "${SSH_ROOT_NEW_PWD}" ]; then
        echo root:${SSH_ROOT_NEW_PWD} | chpasswd
        if (($?)); then exitError "Impossible de modifier le mot de passe ROOT" "010"; fi
        #ecrirLog "root:${SSH_ROOT_NEW_PWD} | chpasswd"
    else
        ecrirLog "Impossible de changer le mot de passe root car la variable est vide" "WARNING"
    fi

}

