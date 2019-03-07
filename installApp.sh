#!/bin/bash
installApplication()
{
    #install sudo, setcap, tar, python-twisted if needed
    command -v sudo >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] sudo command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install sudo
        if (($?)); then exit 7; fi
    }

    command -v setcap >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] setcap command is not install. We are going to do it!"
        # libcap2-bin non installer, on l'install
        apt-get -yq install libcap2-bin
        if (($?)); then exit 8; fi
    }

    command -v tar >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] tar command is not install. We are going to do it!"
        # sudo non installer, on l'install
       apt-get -yq install tar
        if (($?)); then exit 9; fi
    }

    command -v python-twisted >/dev/null 2>&1 || {
        ecrirLog "[ WARN ] tar command is not install. We are going to do it!"
        # sudo non installer, on l'install
        apt-get -yq install python-twisted
        if (($?)); then exit 10; fi
    }

}



