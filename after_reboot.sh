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
printf ${CYAN}"Enter the username for your NON ROOT user\n>"
read username
username="${username,,}"

useradd -m -g users -G audio,video,network,wheel,storage,rfkill -s /bin/bash $username

while true; do
    printf ${LIGHTGREEN}"enter the password for your user %s\n>" $username
    read -s password
    printf ${LIGHTGREEN}"re-enter the password for %s\n>" "$username"
    read -s password_compare
    if [ "$password" = "$password_compare" ]; then
	echo "$username:$password" | chpasswd
        break
    else
        printf ${LIGHTRED}"passwords do not match, re enter them\n"
        printf ${WHITE}".\n"
        sleep 3
        clear
    fi
done

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

git clone https://aur.archlinux.org/paru-bin.git | cd paru-bin | makepkg -siy

printf %{CYAN}"Do you want to install our dwm rice? Y/N \n"

read q1

if [q1 == "Y"]; then
    ./deploy_rice.sh
else
    printf${LIGHTGREEN}"# ====================\nARCH IS READY?\n===================="
    printf ${WHITE}"# Your arch installation should now be ready for use!\n"

