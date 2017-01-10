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