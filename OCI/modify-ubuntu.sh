# These commands are intended to be run on an AMD64 Ubuntu instance.
# The machine will reboot into the Flatcar installer
cd /boot/
sudo wget -q https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz
sudo wget -q https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz
sudo tee -a /etc/grub.d/40_custom <<EOF
menuentry 'Flatcar installer' --class gnu-linux --class gnu --class os {
        recordfail
        load_video
        gfxmode $linux_gfx_mode
        insmod gzio
        insmod part_msdos
        insmod diskfilter
        insmod ext2
        insmod gptsync
        insmod part_gpt
        echo 'Loading Flatcar vmlinuz'
        linux  /boot/flatcar_production_pxe.vmlinuz  initrd=flatcar_production_pxe_image.cpio.gz flatcar.first_boot=1 console=tty1 console=ttyS0 ignition.config.url=https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/sanjpill_sandbox/b/ignition-config/o/iscsi-ignition.json
        echo 'Loading initial ramdisk'
        initrd /boot/flatcar_production_pxe_image.cpio.gz
}
EOF
sudo tee /etc/default/grub.d/90-flatcar.cfg <<EOF
GRUB_RECORDFAIL_TIMEOUT=5
GRUB_TIMEOUT=5
GRUB_TERMINAL=serial
GRUB_TIMEOUT_STYLE=menu
GRUB_DEFAULT=3
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
EOF
sudo update-grub
sudo reboot
