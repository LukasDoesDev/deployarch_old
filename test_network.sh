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
    printf ${LIGHTRED}"This is a serious error, the network is not working!\n"

    printf ${WHITE}
    exit 1
else
    printf ${LIGHTGREEN}"+ Can ping \"archlinux.org\"\n"
fi
printf ${WHITE}"Here is the output of the \"ip addr\" command:\n"
ip addr
