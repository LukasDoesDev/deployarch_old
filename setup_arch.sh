#!/bin/bash

# Set colors
LIGHTGREEN='\033[1;32m'
LIGHTRED='\033[1;91m'
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'
BLUE='\033[1;34m'

# Set starting directory
cd ..
start_dir=$(pwd) # Should be equal to $HOME ?

printf ${WHITE}"### Running network test\n"
ping -c 4 archlinux.org
if [ "$?" != "0" ]; then
    printf ${LIGHTRED}"- Can't ping \"archlinux.org\"\n"
else
    printf ${LIGHTGREEN}"+ Can ping \"archlinux.org\"\n"
fi
printf ${WHITE}"Here is the output of the \"ifconfig\" command:\n"
ifconfig


timedatectl set-ntp true


printf ${WHITE}"### Getting storage devices\n"
fdisk -l >> devices
sed -e '\#Disk /dev/ram#,+5d' -i devices
sed -e '\#Disk /dev/loop#,+5d' -i devices

cat devices
while true; do
    printf ${CYAN}"Enter the device name you want to install arch on (ex, ${MAGENTA}sda${CYAN} for /dev/sda and ${MAGENTA}nvme0n1${CYAN} for /dev/nvme0n1)\n>"
    read disk
    disk="${disk,,}"
    
    printf ${CYAN}"Does this script need to add a \"p\" character before the partition number\nFor example this is needed for NVMe drives (Wrong: /dev/nvme0n11) (Correct: /dev/nvme0n1p1)\n\nEnter y to add the character or n to not add it\n>"
    read add_p
    if [ "$add_p" != "y" ] && [ "$add_p" != "n" ]; then
        printf ${LIGHTRED}"%s is an invalid answer, do it correctly" $add_p
        printf ${WHITE}".\n"
        sleep 2
	continue
    fi
    partition_count="$(grep -o $disk devices | wc -l)"
    disk_chk=("/dev/${disk}")
    if grep "$disk_chk" devices; then
        if [ "$add_p" = "y" ]; then
            printf "Would you like to use the default settings for \"%s\"? \n This will create a GPT partition scheme where\n%s1 = 2 MB bios_partition\n%s2 = 128 MB boot partition\n%s3 = 4 GB swap_partition\n%s4 = the rest of the hard disk\n\nEnter y to continue with the default settings or n to customize \n>" $disk_chk ${disk_chk}p ${disk_chk}p ${disk_chk}p ${disk_chk}p
        else
            printf "Would you like to use the default settings for \"%s\"? \n This will create a GPT partition scheme where\n%s1 = 2 MB bios_partition\n%s2 = 128 MB boot partition\n%s3 = 4 GB swap_partition\n%s4 = the rest of the hard disk\n\nEnter y to continue with the default settings or n to customize \n>" $disk_chk $disk_chk $disk_chk $disk_chk $disk_chk
        fi
        
        read auto_part_ans
        if [ "$auto_part_ans" = "y" ]; then
            wipefs -a $disk_chk
            parted -a optimal $disk_chk --script mklabel gpt
            
            mem_size=8192
            esp_size=550
            mem_offset=$(( $esp_size + $mem_size ))
            mem_offset_str=${mem_offset}"MiB"
            
            parted $disk_chk --script "EFI system partition" fat32 1MiB $esp_size
            parted $disk_chk --script set 1 esp on
            
            parted $disk_chk --script mkpart "swap partition" linux-swap $esp_size $mem_offset_str
            
            parted $disk_chk --script mkpart "root partition" ext4 $mem_offset_str 100%
            parted $disk_chk --script name 4 rootfs
            
            rm -rf devices
            clear
            sleep 2
            break
        elif [ "$auto_part_ans" = "n" ]; then
            wipefs -a $disk_chk
            cfdisk
            break
            printf ${CYAN}"Do you want to start the partitioning over?\n>"
            read restart_part
            if [ "$restart_part" = "y" ]; then
                printf ${LIGHTRED}"### Starting over\n"${WHITE}
            elif [ "$restart_part" = "n" ]; then
                break
            else
                printf ${LIGHTRED}"%s is an invalid answer, do it correctly" $restart_part
                printf ${WHITE}".\n"
                sleep 2
            fi
            continue
        else
            printf ${LIGHTRED}"%s is an invalid answer, do it correctly" $auto_part_ans
            printf ${WHITE}".\n"
            sleep 2
            continue
        fi
        
        if [ "$add_p" = "y" ]; then
            part_1=("${disk_chk}p1")
            part_2=("${disk_chk}p2")
            part_3=("${disk_chk}p3")
        else
            part_1=("${disk_chk}1")
            part_2=("${disk_chk}2")
            part_3=("${disk_chk}3")
        fi
        mkfs.fat -F32 $part_1
        
        mkswap $part_2
        swapon $part_2
        
        mkfs.ext4 $part_3
    else
        printf ${LIGHTRED}"%s is an invalid device, try again with a correct one\n" $disk_chk
        printf ${WHITE}".\n"
        sleep 5
        clear
        cat devices
    fi
done

printf ${CYAN}"Enter the username for your NON ROOT user\n>"
read username
kernelanswer="${kernelanswer,,}"
printf ${CYAN}"Enter the Hostname you want to use\n>"
read hostname
printf ${WHITE}"### Beginning installation\n"

printf ${WHITE}"### Mounting filesystems\n"
mount /dev/sda3 /mnt
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

printf ${WHITE}"### Installing base, base-devel, linux, linux-firmware and nano packages\n"
pacstrap /mnt base base-devel linux linux-firmware nano

printf ${WHITE}"### Generating fstab\n"
genfstab -U /mnt >> /mnt/etc/fstab

printf ${WHITE}"### Chrooting\n"

cd /mnt/
arch-chroot /mnt ./post_chroot.sh