#!/bin/env bash

loadkeys "us"

timedatectl set-timezone America/Sao_Paulo

echo "Server = http://linorg.usp.br/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist 
echo "Server = http://archlinux.c3sl.ufpr.br/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist

sgdisk --zap-all /dev/nvme0n1
printf "n\n1\n\n+250M\nef00\nn\n2\n\n+25G\n8300\nn\n3\n\n\n8200\nw\ny\n" | gdisk /dev/nvme0n1

mkfs.vfat /dev/nvme0n1p1
mkfs.ext4 /dev/nvme0n1p2
mkswap /dev/nvme0n1p3
swapon /dev/nvme0n1p3

mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacstrap /mnt alsa-plugins alsa-utils arch-wiki-lite aspell aspell-en autofs avahi base base-devel bash bash-completion bc bluez bluez-utils cdrdao cdrtools cpio ctags cups cups-pdf deja-dup dhcpcd dialog dmidecode dnsmasq docker dosfstools e2fsprogs efibootmgr exfat-utils f2fs-tools ffmpeg ffmpegthumbnailer ffmpegthumbs firefox firefox-i18n-en-us foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-ppds fuse fuse-exfat gdm gedit-plugins ghostscript git gnome gnome-extra gnome-power-manager gnome-software gnome-tweak-tool go gpaste grub gsfonts gst-libav gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly gtk3-print-backends gutenprint gvfs gvfs-afc gvfs-goa gvfs-google gvfs-mtp htop hunspell hunspell-en_US iw jdk8-openjdk less lib32-mesa-libgl lib32-mesa-vdpau libdvdcss libdvdnav libreoffice-fresh libvdpau-va-gl linux linux-headers linux-firmware lzop man-db man-pages mesa mesa-libgl mlocate mtpfs nautilus-share netctl networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc noto-fonts-emoji nss-mdns ntfs-3g p7zip pavucontrol perl pkgstats pragha pulseaudio pulseaudio-alsa qbittorrent remmina rsync sudo system-config-printer texinfo tlp ttf-bitstream-vera ttf-dejavu ttf-fira-code ttf-hack ttf-liberation unrar unzip vim virtualbox virtualbox-guest-iso virtualbox-host-dkms vlc weston which wpa_supplicant xdg-user-dirs-gtk xf86-input-libinput xf86-video-intel xf86-video-nouveau xorg-apps xorg-server xorg-server-xwayland xorg-xinit xorg-xinput xorg-xkill z zip

genfstab -U -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
echo legion > /etc/hostname
echo "root:big1" | chpasswd
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

pacman -S --asdeps --needed cairo fontconfig freetype2

sed -i '/%wheel ALL=(ALL) NOPASSWD: ALL/s/^#//' /etc/sudoers

echo "" >> /etc/sudoers
echo 'Defaults !requiretty, !tty_tickets, !umask' >> /etc/sudoers
echo 'Defaults visiblepw, path_info, insults, lecture=always' >> /etc/sudoers
echo 'Defaults loglinelen=0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth' >> /etc/sudoers
echo 'Defaults passwd_tries=3, passwd_timeout=1' >> /etc/sudoers
echo 'Defaults env_reset, always_set_home, set_home, set_logname' >> /etc/sudoers
echo 'Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"' >> /etc/sudoers
echo 'Defaults timestamp_timeout=15' >> /etc/sudoers
echo 'Defaults passprompt="[sudo] password for %u: "' >> /etc/sudoers
echo 'Defaults lecture=never' >> /etc/sudoers

tee /etc/modprobe.d/blacklist-ideapad.conf <<< "blacklist ideapad_laptop"

useradd -m -g users -G wheel -s /bin/bash dilas
gpasswd -a dilas docker
gpasswd -a dilas vboxusers
echo "dilas:big1" | chpasswd

cp /etc/skel/.bashrc /home/dilas
cp -fv /etc/X11/xinit/xinitrc /home/dilas/.xinitrc
echo -e "exec gnome-session" >> /home/dilas/.xinitrc

chown -R dilas:users /home/dilas

timedatectl set-ntp true

systemctl enable avahi-daemon.service
systemctl enable tlp.service
systemctl enable tlp-sleep.service
systemctl enable org.cups.cupsd.service
systemctl enable gdm
systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl mask systemd-rfkill.service
systemctl mask systemd-rfkill.socket

tlp start


# rodar como usuario normal
# yay --noconfirm -S gnome-defaults-list
# yay --noconfirm -S jetbrains-toolbox
# yay --noconfirm -S visual-studio-code-bin
# yay --noconfirm -S postman-bin
# yay --noconfirm -S virtualbox-ext-oracle
# yay --noconfirm -S google-chrome
# yay --noconfirm -S ttf-mac-fonts
# yay --noconfirm -S ttf-ms-fonts

# cd /tmp
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si

# gsettings set org.gnome.software download-updates false
EOF