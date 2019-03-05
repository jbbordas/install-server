#!/bin/bash
#change root password

ecrirLog()
{
	if [  !-z "${FICLOG}" ];
	then
	 #  temporairement on log quand même en console
	    echo -e "$1"
		echo -e "$1" >> ${FICLOG}
	else
		echo -e "$1"
	fi
}

if [  !-z "${SSH_ROOT_NEW_PWD}" ];
echo root:${SSH_ROOT_NEW_PWD} | chpasswd
if (($?)); then exit 5; fi
#ecrirLog "root:${SSH_ROOT_NEW_PWD} | chpasswd"
else
ecrirLog "Impossible de changer le mot de passe root car la variable est vide"
fi

#questionOuiExit "Is ROOT PWD change?"
