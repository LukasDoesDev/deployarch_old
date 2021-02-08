# deployarch
deploys an arch machine

## Usage
```sh
curl -fsSL https://raw.githubusercontent.com/LukasDoesDev/deployarch/master/setup_arch.sh > /tmp/setup_arch.sh
chmod +x /tmp/setup_arch.sh
bash /tmp/setup_arch.sh
```
And after that script has run, you can optionally unmount the partitions:
```sh
umount -R /mnt
```
Then, login and run these commands:
```sh
curl -fsSL https://raw.githubusercontent.com/LukasDoesDev/deployarch/master/after_reboot.sh > /tmp/after_reboot.sh
chmod +x /tmp/after_reboot.sh
bash /tmp/after_reboot.sh
```
And after that you should have a working Arch installation.
