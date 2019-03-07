#!/bin/bash
#change root password

changeRootPwd()
{
    if [ -n "${SSH_ROOT_NEW_PWD}" ]; then
        echo root:${SSH_ROOT_NEW_PWD} | chpasswd
        if (($?)); then exit 5; fi
        #ecrirLog "root:${SSH_ROOT_NEW_PWD} | chpasswd"
    else
        ecrirLog "Impossible de changer le mot de passe root car la variable est vide"
    fi

}

