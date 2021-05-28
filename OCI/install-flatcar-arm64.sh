# This script is rather awful, due to Flatcar's ARM UEFI support not working
# with OCI's bare metal instances.

# First get the EFI partition from the Oracle Linux installation
sudo mount /dev/sda1 /mnt
sudo cp -ax /mnt/EFI .
sudo umount /mnt

# Download the v2857.0.0 with iSCSI support
# IMPORTANT: if you change the version number here, you'll need to change the
# verity hash in the GRUB config below.
wget http://alpha.release.flatcar-linux.net/arm64-usr/2857.0.0/flatcar_production_image.bin.bz2
bunzip2 flatcar_production_image.bin.bz2

# We need to unmap the Oracle volumes twice, because they get remapped in the
# middle of the flatcar-install run which fails the first time and succeeds the
# second one.
sudo dmsetup remove /dev/mapper/ocivolume-oled
sudo dmsetup remove /dev/mapper/ocivolume-root
sudo flatcar-install -d /dev/sda -f flatcar_production_image.bin
sudo dmsetup remove /dev/mapper/ocivolume-oled
sudo dmsetup remove /dev/mapper/ocivolume-root
sudo flatcar-install -d /dev/sda -f flatcar_production_image.bin

# This sets the grub config in the OEM partition, it's not really used
# because this is read by Flatcar's GRUB and we're using Oracle's GRUB.
OEM_DEV=$(sudo blkid -t "LABEL=OEM" -o device /dev/sda*)
sudo mount ${OEM_DEV} /mnt
sudo tee /mnt/grub.cfg <<EOF
set linux_append="\$linux_append flatcar.autologin=tty1 flatcar.autologin=ttyS0 console=tty1 console=ttyS0 netroot=iscsi:169.254.0.2::::iqn.2015-02.oracle.boot:uefi rd.iscsi.initiator=iqn.2015-02.oracle.boot:uefi ignition.config.url=http://169.254.169.254/openstack/latest/user_data" 
EOF
sudo umount /mnt/

# We now use the EFI/redhat directory that we backed up, but modify the grub
# config to use the Flatcar boot config. As we don't have our GRUB, we need to
# set the verity hash manually. This hash needs to be obtained from another
# Flatcar. For example by booting the qemu image for that Flatcar version and
# checking the cmdline.
# So, if the version number above gets changed, the verity hash here needs to
# be updated.
sudo mount /dev/sda1 /mnt
sudo cp -ax EFI/redhat/ /mnt/EFI/
cp /mnt/flatcar/grub/grub.cfg.tar .
tar -xvf grub.cfg.tar 
sed -i 's,^set linux_append=.*$,set linux_append="flatcar.autologin=tty1 flatcar.autologin=ttyS0 console=tty1 console=ttyS0 netroot=iscsi:169.254.0.2::::iqn.2015-02.oracle.boot:uefi rd.iscsi.initiator=iqn.2015-02.oracle.boot:uefi ignition.config.url=http://169.254.169.254/openstack/latest/user_data",' grub.cfg
sed -i 's/verity.usr=PARTUUID=$usr_uuid"/verity.usr=PARTUUID=$usr_uuid verity.usrhash=d229bade16edec572bb52d3bbf200c13a1a5436fc3644dfba31a14c197fbf2f2"/' grub.cfg
sudo cp grub.cfg /mnt/EFI/redhat/grub.cfg
sudo umount /dev/sda1

# The machine is now ready to be used as a base image
sudo poweroff
