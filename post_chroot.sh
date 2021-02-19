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
printf ${CYAN}"Enter your language in this form: \"<locale> <charset>\" where <locale> is one of the locales placed in /usr/share/i18n/locales and <charset> is one of the charsets placed in /usr/share/i18n/charmaps (ex, \"en_US UTF-8\")\n>"
read lang1

printf ${CYAN}"Enter your language in this form: \"<locale>\" where <locale> is one of the locales placed in /usr/share/i18n/locales (ex, \"en_US\")\n>"
read lang2

echo LANG=${lang2} > /etc/locale.conf
echo "${lang1}" >> /etc/locale.gen

echo KEYMAP=fi > /etc/vconsole.conf

locale-gen

printf ${CYAN}"Enter the hostname you want to use\n>"
read newHostname

echo $newHostname > /etc/hostname

echo "127.0.0.1	localhost" >> /etc/hosts
echo "::1	        localhost" >> /etc/hosts



pacman -Sy networkmanager

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
printf ${WHITE}"# After you've rebooted and logged into the root user please see the README to see what commands to run:\n"

exit
