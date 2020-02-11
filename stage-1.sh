#!/bin/env bash

# Pacman mirror
echo "Server = http://archlinux.c3sl.ufpr.br/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist

# Disk partitioning
wipefs -a /dev/nvme0n1
printf "n\n1\n\n+250M\nef00\nn\n2\n\n+18G\n8300\nn\n3\n\n\n8200\nw\ny\n" | gdisk /dev/nvme0n1

# Root filesystem
mkfs.ext4 /dev/nvme0n1p2
mount /dev/nvme0n1p2 /mnt

# Boot filesystem
mkfs.vfat /dev/nvme0n1p1
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

# Swap
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3

# Install base packages
pacstrap /mnt base base-devel bash bash-completion dhcpcd dialog e2fsprogs efibootmgr git grub iw less linux-firmware linux-lts linux-lts-headers man-db man-pages netctl perl sudo texinfo vim which wpa_supplicant

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Change to root filesystem
arch-chroot /mnt /bin/bash <<EOF
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "legion" > /etc/hostname
useradd -m -g users -G wheel -s /bin/bash dilas
echo "root:big1" | chpasswd
echo "dilas:big1" | chpasswd
sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers
tee /etc/modprobe.d/blacklist-ideapad.conf <<< "blacklist ideapad_laptop"
echo "Server = http://archlinux.c3sl.ufpr.br/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
git clone https://github.com/odilontalk/archlinux-dev-machine.git /home/dilas/archlinux-dev-machine
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF