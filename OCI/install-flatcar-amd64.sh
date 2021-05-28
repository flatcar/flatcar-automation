# We need at least v2857.0.0 to have iSCSI support
wget http://alpha.release.flatcar-linux.net/amd64-usr/2857.0.0/flatcar_production_image.bin.bz2
bunzip2 flatcar_production_image.bin.bz2 
sudo flatcar-install -d /dev/sda -f flatcar_production_image.bin

# Modify the GRUB config to include the netroot volume, the iscsi initiator
# name and the openstack address for configuration.
OEM_DEV=$(sudo blkid -t "LABEL=OEM" -o device /dev/sda*)
sudo mount ${OEM_DEV} /mnt
sudo tee /mnt/grub.cfg <<EOF
set linux_append="$linux_append flatcar.autologin=tty1 flatcar.autologin=ttyS0 console=tty1 console=ttyS0 netroot=iscsi:169.254.0.2::::iqn.2015-02.oracle.boot:uefi rd.iscsi.initiator=iqn.2015-02.oracle.boot:uefi ignition.config.url=http://169.254.169.254/openstack/latest/user_data"
EOF
sudo umount /mnt/
sudo poweroff

# After the poweroff, the image can be created from the installed machine, before the first boot happens.
