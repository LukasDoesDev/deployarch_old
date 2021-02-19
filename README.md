# deployarch
deploys an arch machine

## Usage

### (WARNING) This installer is for UEFI

Do the following in your UEFI/BIOS settings:
 - Disable Secure Boot
 - Disable Launch CSM or Legacy Support
 - Set Boot Mode to UEFI
 - Enable USB Boot

Boot to the official installlation ISO and run the following commands:
```sh
loadkeys # <your keyboard layout, for me it's "fi">
curl -O https://codeload.github.com/LukasDoesDev/deployarch/zip/master
pacman -Sy unzip
unzip master
cd deployarch-master
./setup_arch.sh
```
And after that script has run reboot to the drive you installed Arch on, login to root and run these commands:
```sh
curl -O https://codeload.github.com/LukasDoesDev/deployarch/zip/master
pacman -Sy unzip
unzip master
cd deployarch-master
./after_reboot.sh
```
And after that you should have a working Arch installation.
