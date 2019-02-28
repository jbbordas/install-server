#!/bin/bash
#user create with add in sudo group
egrep "^$SSH_USER" /etc/passwd >/dev/null
if [ $? -ne 0 ]; then
	ecrirLog "[ WARN ] the User doesn't existe, we need to create it"
	adduser --disabled-password --gecos "" "$SSH_USER"
	if (($?)); then exit 11; fi
	echo "${SSH_USER}:${SSH_USER_PWD}" | chpasswd
	if (($?)); then exit 12-1; fi
	usermod -a -G sudo "$SSH_USER"
	if (($?)); then exit 12; fi
	ecrirLog "[ INFO ] the User $SSH_USER was created"
else
	ecrirLog "[ ERROR ] the User $SSH_USER can't be find"
	exit 13
fi
