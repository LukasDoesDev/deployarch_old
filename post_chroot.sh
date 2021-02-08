#!/bin/bash

# Set colors
LIGHTGREEN='\033[1;32m'
LIGHTRED='\033[1;91m'
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'
BLUE='\033[1;34m'

while true; do
  printf ${WHITE}"### Setting timezone\n"
  printf ${CYAN}"Enter your timezone in this format: Region/City\n(ex, Europe/Helsinki, America/New_York, Asia/Singapore, Australia/Sydney)\n(https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)\n>"
  read timezone

  ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
  
  if [ "$?" = "0" ]; then
      break
  else
    printf ${LIGHTRED}"Error while setting timezone, please enter it again\n"
    sleep 2
  fi
done

hwclock --systohc

printf ${WHITE}"### Setting locales, keyboard etc\n"
printf ${CYAN}"Enter your language (ex, "en_US.UTF-8 UTF-8") (Remember to add the encoding type such as "UTF-8" after "en_US.UTF-8" to the end (with a space))\n>"
read lang1

printf ${CYAN}"Enter your language (ex, "en_US.UTF-8")\n>"
read lang2

echo LANG=en_US.UTF-8 > /etc/locale.conf
echo en_US.UTF-8 >> /etc/locale.gen

echo KEYMAP=fi > /etc/vconsole.conf

locale-gen

printf ${CYAN}"Enter the hostname you want to use\n>"
read hostname

echo $HOSTNAME > /etc/hostname

echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1	        localhost" >> /etc/hosts
echo "127.0.0.1	${HOSTNAME}.localdomain	${HOSTNAME} ${HOSTNAME}.local" >> /etc/hosts



pacman -S networkmanager

systemctl enable NetworkManager

while true; do
    printf ${LIGHTGREEN}"enter the password for your root user\n>"
    read -s password
    printf ${LIGHTGREEN}"re-enter the password for your root user\n>"
    read -s password_compare
    if [ "$password" = "$password_compare" ]; then
    echo "root:$password" | chpasswd
        break
    else
        printf ${LIGHTRED}"Passwords do not match, re enter them"
        printf ${WHITE}".\n"
        sleep 3
        clear
    fi
done



pacman -S grub efibootmgr

grub-install --target=x86_64-efi --efi-directory=/boot/efi

grub-mkconfig -o /boot/grub/grub.cfg

printf ${LIGHTGREEN}"# =========================\n"
printf ${LIGHTGREEN}"# REBOOT NEEDED\n"
printf ${LIGHTGREEN}"# =========================\n"
printf ${WHITE}"# You can now optionally unmount the partitions with\n"
printf ${WHITE}"umount -R /mnt\n"
printf ${WHITE}"# And you need to reboot\n"
printf ${WHITE}"reboot\n"
printf ${WHITE}"# After you've rebooted please run the following command:\n"
printf ${WHITE}"curl -fsSL https://raw.githubusercontent.com/LukasDoesDev/dotfiles/master/after_reboot.sh | bash\n"

exit
