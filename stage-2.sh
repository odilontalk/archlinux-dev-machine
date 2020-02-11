#!/bin/env bash

sudo -s <<EOF
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

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacman -Sy
pacman --noconfirm -S alsa-plugins alsa-utils arch-wiki-lite aspell aspell-en autofs avahi bc bluez bluez-utils cdrdao cdrtools cpio ctags cups cups-pdf deja-dup dmidecode dnsmasq docker dosfstools exfat-utils f2fs-tools ffmpeg ffmpegthumbnailer ffmpegthumbs firefox firefox-i18n-en-us foomatic-db foomatic-db-engine foomatic-db-gutenprint-ppds foomatic-db-nonfree foomatic-db-nonfree-ppds foomatic-db-ppds fuse fuse-exfat gdm gedit-plugins ghostscript git gnome gnome-extra gnome-power-manager gnome-software gnome-tweak-tool go gpaste gsfonts gst-libav gst-plugins-bad gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly gtk3-print-backends gutenprint gvfs gvfs-afc gvfs-goa gvfs-google gvfs-mtp htop hunspell hunspell-en_US jdk8-openjdk lib32-mesa-libgl lib32-mesa-vdpau libdvdcss libdvdnav libreoffice-fresh libvdpau-va-gl lzop mesa mesa-libgl mlocate mtpfs nautilus-share networkmanager networkmanager-openconnect networkmanager-openvpn networkmanager-pptp networkmanager-vpnc noto-fonts-emoji nss-mdns ntfs-3g p7zip pavucontrol pkgstats pragha pulseaudio pulseaudio-alsa qbittorrent remmina rsync sudo system-config-printer tlp ttf-bitstream-vera ttf-dejavu ttf-fira-code ttf-hack ttf-liberation unrar unzip virtualbox virtualbox-guest-iso virtualbox-host-dkms vlc weston xdg-user-dirs-gtk xf86-input-libinput xf86-video-intel xf86-video-nouveau xorg-apps xorg-server xorg-server-xwayland xorg-xinit xorg-xinput xorg-xkill z zip
pacman -S --asdeps --needed cairo fontconfig freetype2

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
EOF

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

cd ~
gsettings set org.gnome.software download-updates false

yay --noconfirm -S gnome-defaults-list jetbrains-toolbox visual-studio-code-bin postman-bin virtualbox-ext-oracle google-chrome ttf-mac-fonts ttf-ms-fonts