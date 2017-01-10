# Create the vagrant user.
groupadd -g 1000 vagrant
useradd -g vagrant -m -u 1000 vagrant
echo vagrant:vagrant | chpasswd

# Give the vagrant user sudo privileges.
cat > /etc/sudoers.d/vagrant <<-EOF
	vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/vagrant

# Install the Vagrant insecure public SSH key.
mkdir /home/vagrant/.ssh
curl -LsSo /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod -R go-rwx /home/vagrant/.ssh

# Remove Pacman caches.
rm -r /var/cache/pacman/*

# Restore the sshd configuration we altered during installation back to default (disable root login with password).
mv /etc/ssh/sshd_config.orig /etc/ssh/sshd_config

# Clear /tmp.
find /tmp -mindepth 1 -delete

# Write zeroes to all free space to allow it to be reclaimed from the virtual disk image.
# dd will return an error code (device full) so hide it from `set -e`.
# Then expand the root filesystem to the full size of the device.
dd if=/dev/zero of=/zero bs=1M || true
rm /zero
swapoff -a

dd if=/dev/zero of=/dev/sdb seek=8 bs=1M || true
resize2fs /dev/sda1

# Remove the root password now that we're done with it.
usermod -p '*' root