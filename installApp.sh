#!/bin/bash
installApplication()
{
    #install sudo, setcap, tar, python-twisted if needed
    command -v sudo >/dev/null 2>&1 || {
        ecrirLog "sudo command is not install. We are going to do it!" "INFO"
        # sudo non installer, on l'install
        apt-get -yq install sudo
        if (($?)); then exitError "intallation de sudo impossible" "20"; fi
    }

    command -v setcap >/dev/null 2>&1 || {
        ecrirLog "setcap command is not install. We are going to do it!" "INFO"
        # libcap2-bin non installer, on l'install
        apt-get -yq install libcap2-bin
        if (($?)); then exitError "intallation de libcap2 impossible" "21"; fi
    }

    command -v tar >/dev/null 2>&1 || {
        ecrirLog " tar command is not install. We are going to do it!" "INFO"
        # sudo non installer, on l'install
       apt-get -yq install tar
        if (($?)); then exitError "impossible d'installer TAR" "22"; fi
    }

    command -v python-twisted >/dev/null 2>&1 || {
        ecrirLog "python command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install python-twisted
        if (($?)); then exitError "impossible d'installer python" "23"; fi
    }

}



