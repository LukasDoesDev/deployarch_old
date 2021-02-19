#!/bin/bash

# Set colors
LIGHTGREEN='\033[1;32m'
LIGHTRED='\033[1;91m'
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'
BLUE='\033[1;34m'

printf ${WHITE}"### Running network test\n"
ping -c 4 archlinux.org
if [ "$?" != "0" ]; then
    printf ${LIGHTRED}"- Can't ping \"archlinux.org\"\n"
else
    printf ${LIGHTGREEN}"+ Can ping \"archlinux.org\"\n"
fi
printf ${WHITE}"Here is the output of the \"ifconfig\" command:\n"
ifconfig

printf ${WHITE}"### Installing bash-completion\n"
pacman -S bash-completion

printf ${WHITE}"### Setting up non-root user\n"
./add_user.sh

printf ${WHITE}

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers


while true; do


    printf %{CYAN}"Do you want to install our rice? Y/N \n>"
    read use_rice
    printf ${WHITE}
    
    if [ "$use_rice" = "y" ]; then
	./deploy_rice.sh
    	break
    elif [ "$use_rice" = "n" ]; then
    	break
    else
        printf ${LIGHTRED}"%s is an invalid answer, do it correctly" $use_rice
        printf ${WHITE}".\n"
        sleep 2
    fi
done



printf ${LIGHTGREEN}"#====================#\n    ARCH IS READY! \n#====================#"
printf ${WHITE}"# Your arch installation should now be ready for use!\n"

printf ${WHITE}
