printf ${CYAN}"Enter the username for the new user\n>"
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
