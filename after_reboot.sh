#!/bin/bash

# Set colors
LIGHTGREEN='\033[1;32m'
LIGHTRED='\033[1;91m'
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'
BLUE='\033[1;34m'

./test_network.sh

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
