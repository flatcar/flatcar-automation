# These commands are intended to be run on an Oracle Linux ARM instance
# Setting the GRUB default for some reason doesn't work, so the option needs to be selected using the serial console
cd /boot/
sudo wget -q https://alpha.release.flatcar-linux.net/arm64-usr/current/flatcar_production_pxe.vmlinuz
sudo wget -q https://alpha.release.flatcar-linux.net/arm64-usr/current/flatcar_production_pxe_image.cpio.gz
sudo tee -a /etc/grub.d/40_custom <<EOF
menuentry 'Flatcar installer' --class gnu-linux --class gnu --class os {
        load_video
        insmod gzio
        insmod part_msdos
        insmod diskfilter
        insmod ext2
        insmod part_gpt
        echo 'Loading Flatcar vmlinuz'
        linux  (\$root)/flatcar_production_pxe.vmlinuz  initrd=flatcar_production_pxe_image.cpio.gz flatcar.first_boot=1 console=tty1 console=ttyS0 ignition.config.url=https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/sanjpill_sandbox/b/ignition-config/o/iscsi-ignition.json
        echo 'Loading initial ramdisk'
        initrd (\$root)/flatcar_production_pxe_image.cpio.gz
}
EOF
sudo tee /etc/default/grub <<EOF
GRUB_TIMEOUT=5
GRUB_DEFAULT=4
GRUB_DISABLE_SUBMENU=true
GRUB_DISABLE_RECOVERY="true"
GRUB_ENABLE_BLSCFG=true
GRUB_TERMINAL="serial"
GRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"
GRUB_TIMEOUT_STYLE=menu
GRUB_RECORDFAIL_TIMEOUT=5
GRUB_CMDLINE_LINUX="crashkernel=auto LANG=en_US.UTF-8 console=ttyAMA1 console=ttyAMA0,115200 rd.luks=0 rd.md=0 rd.dm=0 rd.lvm.vg=ocivolume rd.lvm.lv=ocivolume/root rd.net.timeout.carrier=5 netroot=iscsi:169.254.0.2:::1:iqn.2015-02.oracle.boot:uefi rd.iscsi.param=node.session.timeo.replacement_timeout=6000 net.ifnames=1 nvme_core.shutdown_timeout=10 ipmi_si.tryacpi=0 ipmi_si.trydmi=0 ipmi_si.trydefaults=0 libiscsi.debug_libiscsi_eh=1 loglevel=4 ip=single-dhcp crash_kexec_post_notifiers"
EOF
sudo grub2-mkconfig | sudo tee /etc/grub2-efi.cfg
sudo reboot
