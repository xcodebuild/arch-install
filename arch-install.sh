#!/bin/bash

# Modify this file for yourself,then comment next line 

echo "You must open this script file to configure!" && exit

#-----------------------------------------------------------------------------
ARCH_ROOT=/mnt

ARCH_TARGET_ROOT=/dev/sda?

ARCH_TARGET_DEV=/dev/sd?

ARCH_HOSTNAME="ArchLinux"

ARCH_ROOT_PASSWORD=root

ARCH_NEW_USER_NAME=user

ARCH_NEW_USER_PASSWORD=user

#-----------------------------------------------------------------------------

set -x # Show the message of each command
#MODULE FUNCTIONS{{{ 

arch_chroot () { #{{{
arch-chroot $ARCH_ROOT /bin/bash -c "${1}"
}
#}}}

#}}}

# file system
mkfs -t ext4  $ARCH_TARGET_ROOT

# mount file system
mount $ARCH_TARGET_ROOT $ARCH_ROOT

# pacman base
pacstrap -i $ARCH_ROOT base grub-bios
sleep 2

# fstab
genfstab -U -p $ARCH_ROOT >> $ARCH_ROOT/etc/fstab
sleep 2

# Set timezone and hwclock
arch_chroot 'hwclock --systohc --utc'
sleep 2

# Set hostname
arch_chroot 'echo $ARCH_HOSTNAME > /etc/hostname'
sleep 2

# DHCP start
arch_chroot 'systemctl enable dhcpcd.service'
sleep 2

# locale
echo "LANG=zh_CN.UTF-8" > /etc/locale.conf
sleep 2

# locale-gen
arch_chroot 'sed -i \
-e "/^#en_US ISO-8859-1/s/#//" \
-e "/^#en_US.UTF-8 UTF-8/s/#//" \
-e "/^#zh_CN.UTF-8 UTF-8/s/#//" \
-e "/^#zh_CN BIG5/s/#//" \
/etc/locale.gen'
arch_chroot 'locale-gen'
sleep 2

# users and passwd
arch_chroot 'useradd -m -G users,wheel -s /bin/bash freeman'
arch_chroot 'echo "$ARCH_NEW_USER_NAME:$ARCH_NEW_USER_PASSWORD" > 
passwd.txt'
arch_chroot 'echo "root:ARCH_ROOT_PASSWORD" >> passwd.txt'
arch_chroot 'chpasswd < passwd.txt'
arch_chroot 'rm passwd.txt'
sleep 2

# mkinitcpio
arch_chroot 'mkinitcpio -p linux'
sleep 2

# grub
arch_chroot 'grub-mkconfig -o /boot/grub/grub.cfg'
arch_chroot 'grub-install $ARCH_TARGET_DEV'
sleep 2

#rm $ARCH_ROOT/vbox_arch_chroot.sh
umount $ARCH_ROOT/
reboot
