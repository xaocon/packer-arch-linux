#!/bin/bash

set -e

TARGET=/mnt

parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary ext4 0% 2GiB
mkfs.ext4 /dev/sda1
mount /dev/sda1 ${TARGET}

pacstrap ${TARGET} base

genfstab -p ${TARGET} >> ${TARGET}/etc/fstab
ln -s /usr/share/zoneinfo/Etc/UTC ${TARGET}/etc/localtime
ln -fs /run/systemd/resolve/resolv.conf ${TARGET}/etc/resolv.conf
hostname > ${TARGET}/etc/hostname

cat > ${TARGET}/etc/systemd/network/ethernet.network <<-EOF
	[Match]
	name=en*
	
	[Network]
	DHCP=yes
EOF

echo '==> Entering chroot and configuring system'
mv /dev/shm/install_config.sh ${TARGET}/
chmod +x ${TARGET}/install_config.sh
/usr/bin/arch-chroot ${TARGET} /install_config.sh
rm ${TARGET}/install_config.sh

echo '2048,,83,*' | sfdisk -f --no-reread /dev/sda || true

arch-chroot ${TARGET} grub-install --target=i386-pc /dev/sda

sed -i '/^GRUB_TIMEOUT=/s/=[0-9]\+$/=0/' ${TARGET}/etc/default/grub
arch-chroot ${TARGET} grub-mkconfig -o /boot/grub/grub.cfg

sed -i.orig '$aPermitRootLogin=yes' ${TARGET}/etc/ssh/sshd_config
arch-chroot ${TARGET} systemctl --no-reload enable sshd.socket
arch-chroot ${TARGET} pacman -Syu

reboot
