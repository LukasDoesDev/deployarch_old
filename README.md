# deployarch
deploys an arch machine

## Usage

On the official installlation ISO:
```sh
pacman -S git
git clone https://github.com/LukasDoesDev/deployarch.git
cd deployarch
chmod +x post_chroot.sh setup_arch.sh
./setup_arch.sh
```
And after that script has run, you can optionally unmount the partitions:
```sh
cd /
umount -R /mnt
```
Then reboot to the drive you installed arch on, login and run these commands:
```sh
curl -fsSL https://raw.githubusercontent.com/LukasDoesDev/deployarch/master/after_reboot.sh > /tmp/after_reboot.sh
chmod +x /tmp/after_reboot.sh
bash /tmp/after_reboot.sh
```
And after that you should have a working Arch installation.
