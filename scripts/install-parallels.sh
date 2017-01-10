# Preserve installer logs.
mv /var/log/pacman.log /var/log/pacman.log.preserve

# Install development tools.
pacman -Sy --noconfirm gcc linux-headers make

# Mount the ISO.
mount -o loop,ro /dev/shm/prl-tools-lin.iso /mnt

# The Parallels Tools installer doesn't really properly support Arch Linux. It expects dkms and partx to be
# installed, even though they're not really needed (kpartx is necessary only for `prlctl backup` functionality).
ln -s true /bin/dkms
ln -s true /bin/kpartx

# It also expects to install startup scripts into /etc/init.d which doesn't exist on Arch. OK, whatever.
mkdir /etc/init.d

# Install Parallels Tools.
/mnt/install --install-unattended

# Remove dummies.
rm /bin/dkms /bin/kpartx

# Unmount the ISO.
umount /mnt

# Remove development tools.
pacman -Rsn --noconfirm gcc linux-headers make

# Restore installer logs
mv /var/log/pacman.log.preserve /var/log/pacman.log