#!/bin/bash

if [[ `id -u` -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

pacman -S git

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
