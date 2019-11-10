#!/bin/bash
###############
#     SSH     #
###############

installSsh()
{
    ecrirLog "configuration SSH" "INFO"
     # Change ssh port
    sed -i "s/#Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config       
    if (($?)); then exitError "impossible d'executer la commande sed" "060"; fi
    # Change ssh port for other cases
    sed -i "s/Port 22/Port $SSH_PORT/g" /etc/ssh/sshd_config  
    if (($?)); then exitError "impossible d'executer la commande sed" "061"; fi
    # Desactivate root login
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config      
    if (($?)); then exitError "impossible d'executer la commande sed" "062"; fi

    # Tell sshd which users are alllowed to log in :
    echo  "
# Users allowed to use ssh :
AllowUsers "$SSH_USER"
">> /etc/ssh/sshd_config
    if (($?)); then exitError "impossible d'écrire le fichier sshd_config" "063"; fi

    echo "SSH_MAIL_RECEVER=$SSH_MAIL_RECEVER">> /etc/bash.bashrc
    if (($?)); then exitError "impossible d'ecrire le fichier bash.bashrc" "063"; fi
    VARI=$(cat <<IEE
echo 'NOTIFICATION - Acces SSH :' \`hostname\` 'le:' \`date +'%d/%m/%Y'\` \`who | grep -v localhost\` | mail -s "[ \`hostname\` ] NOTIFICATION - Acces SSH le: \`date +'%Y/%m/%d'\` \`whoami\`" $SSH_MAIL_RECEVER
IEE
)
    echo $VARI >> /etc/bash.bashrc
    if (($?)); then exitError "impossible d'ecrir le fichier bash.bashrc"  "064"; fi

    echo "
alias ls='ls $LS_OPTIONS --color=auto'
alias ll='ls $LS_OPTIONS -al --color=auto'
alias vi='vim'
">> /etc/bash.bashrc
    if (($?)); then  exitError "impossible d'ecrir le fichier bash.bashrc"  "065"; fi
    # Restart ssh :
    systemctl restart ssh
    if (($?)); then exitError "impossible de demarrer ssh" "066"; fi
    #questionOuiExit "Is every thing OK for now? Ssh has been configured"
}

