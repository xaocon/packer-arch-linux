systemctl --no-reload enable systemd-networkd.service
systemctl --no-reload enable systemd-resolved.service
mkinitcpio -p linux

echo root:packer | chpasswd
pacman -S --noconfirm grub openssh sudo

# Create the vagrant user.
groupadd -g 1000 vagrant
useradd -g vagrant -m -u 1000 vagrant
echo vagrant:vagrant | chpasswd


# Install the Vagrant insecure public SSH key.
mkdir /home/vagrant/.ssh
curl -LsSo /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod -R go-rwx /home/vagrant/.ssh

# Give the vagrant user sudo privileges.
cat > /etc/sudoers.d/vagrant <<-EOF
	vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/vagrant
