#!/bin/bash

# Set colors
LIGHTGREEN='\033[1;32m'
LIGHTRED='\033[1;91m'
WHITE='\033[1;97m'
MAGENTA='\033[1;35m'
CYAN='\033[1;96m'
BLUE='\033[1;34m'

# Set starting directory
script_dir=$(pwd)
cd ..
start_dir=$(pwd) # Should be equal to $HOME ?

${script_dir}/test_network.sh
if [ "$?" != "0" ]; then
    exit 1
fi

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
            printf "Would you like to use the default settings for \"%s\"? \n This will create a GPT partition scheme where\n%s1 = 550 MiB boot partition\n%s2 = 8192 MiB swap partition\n%s3 = the rest of the hard disk\n\nEnter y to continue with the default settings or n to customize \n>" $disk_chk ${disk_chk}p ${disk_chk}p ${disk_chk}p
        else
            printf "Would you like to use the default settings for \"%s\"? \n This will create a GPT partition scheme where\n%s1 = 550 MiB boot partition\n%s2 = 8192 MiB swap partition\n%s3 = the rest of the hard disk\n\nEnter y to continue with the default settings or n to customize \n>" $disk_chk $disk_chk $disk_chk $disk_chk
        fi
        
        read auto_part_ans
        if [ "$auto_part_ans" = "y" ]; then
            wipefs -a $disk_chk
            parted -a optimal $disk_chk --script mklabel gpt
            
            mem_size=8192
            esp_size=550
            mem_offset=$(( $esp_size + $mem_size ))
            mem_offset_str=${mem_offset}"MiB"
            
            parted $disk_chk --script mkpart ESP fat32 1MiB ${esp_size}MiB
            parted $disk_chk --script set 1 esp on
            
            parted $disk_chk --script mkpart swap linux-swap ${esp_size}MiB $mem_offset_str
            
            parted $disk_chk --script mkpart root ext4 ${mem_offset_str} 100%
            
            rm -rf devices
            
            sleep 2
            
        elif [ "$auto_part_ans" = "n" ]; then
            wipefs -a $disk_chk
            cfdisk
            
            printf ${CYAN}"Do you want to start the partitioning over?\n>"
            read restart_part
            if [ "$restart_part" = "y" ]; then
                printf ${LIGHTRED}"### Starting over\n"${WHITE}
                continue
            elif [ "$restart_part" = "n" ]; then
                printf ""
            else
                printf ${LIGHTRED}"%s is an invalid answer, do it correctly" $restart_part
                printf ${WHITE}".\n"
                sleep 2
                continue
            fi
            
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
        break
    else
        printf ${LIGHTRED}"%s is an invalid device, try again with a correct one\n" $disk_chk
        printf ${WHITE}".\n"
        sleep 5
        clear
        cat devices
    fi
done

printf ${WHITE}"### Beginning installation\n"

printf ${WHITE}"### Mounting filesystems\n"
mkdir /mnt/arch
echo p3: $part_3
echo p1: $part_1
mount --source ${part_3} --target /mnt/arch
mkdir /mnt/arch/boot
mkdir /mnt/arch/boot/efi
mount --source ${part_1} --target /mnt/arch/boot/efi

printf ${WHITE}"### Installing base, base-devel, linux, linux-firmware and nano packages\n"
pacstrap /mnt/arch base base-devel linux linux-firmware nano

printf ${WHITE}"### Generating fstab\n"
genfstab -U /mnt/arch >> /mnt/arch/etc/fstab

printf ${WHITE}"### Chrooting\n"

cp ${script_dir}/post_chroot.sh /mnt/arch

cd /mnt/arch
arch-chroot /mnt/arch /post_chroot.sh
