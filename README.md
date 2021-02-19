# deployarch
deploys an arch machine

## Usage

On the official installlation ISO:
```sh
curl -O https://codeload.github.com/LukasDoesDev/deployarch/zip/master
pacman -Sy unzip
unzip master
cd deployarch-master
./setup_arch.sh
```
And after that script has run, you can optionally unmount the partitions:
```sh
cd /
umount -R /mnt
```
Then reboot to the drive you installed arch on, login and run these commands:
```sh
curl -O https://codeload.github.com/LukasDoesDev/deployarch/zip/master
pacman -Sy unzip
unzip master
cd deployarch-master
./after_reboot.sh
```
And after that you should have a working Arch installation.
