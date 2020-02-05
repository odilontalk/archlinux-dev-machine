#!/bin/env bash

loadkeys "us"

timedatectl set-timezone America/Sao_Paulo
timedatectl set-ntp true

echo "Server = http://archlinux.c3sl.ufpr.br/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

sgdisk --zap-all /dev/nvme0n1
printf "n\n1\n\n+250M\nef00\nn\n2\n\n+10G\n8300\nn\n3\n\n\n8200\nw\ny\n" | gdisk /dev/nvme0n1

mkfs.vfat /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

pacstrap /mnt base base-devel linux linux-headers linux-firmware man-db man-pages texinfo less bash bash-completion vim perl which e2fsprogs

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo legion > /etc/hostname
pacman --noconfirm -S iw wpa_supplicant netctl dhcpcd dialog
echo "root:big1" | chpasswd
pacman --noconfirm -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF
