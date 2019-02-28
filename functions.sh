#!/bin/bash
#Usefull functions

questionOuiExit()
{
	echo -e "$1"
    echo -e "/!\ Write yes if you want to continue."
    read -r GO
    if [ "$GO" == "yes" ]; then
        return 0
    else
        exit 2
    fi/Users/admin/Desktop/GitHub/Serveur-backup/rootPwd.sh
}

ecrirLog()
{
	if [  !-z "${FICLOG}" ];
	 #  temporairement on log quand même en console
	    echo -e "$1"
		echo -e "$1" >> ${FICLOG}
	else
		echo -e "$1"
	fi
}
