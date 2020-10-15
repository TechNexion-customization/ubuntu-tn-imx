#!/bin/bash

COL_GREEN="\e[1;32m"
COL_NORMAL="\e[m"

echo "${COL_GREEN}Technexion customized minimal rootfs staring...${COL_NORMAL}"
echo "${COL_GREEN}creating ubuntu sudoer account...${COL_NORMAL}"
cd /
echo technexion > /etc/hostname
echo -e "127.0.1.1\ttechnexion" >> /etc/hosts

(echo "root"; echo "root";) | passwd
(echo "ubuntu"; echo "ubuntu"; echo;) | adduser ubuntu
usermod -aG sudo ubuntu

echo "${COL_GREEN}apt-get server upgrading...${COL_NORMAL}"
# apt-get source adding
cat <<END > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports/ focal main
deb http://ports.ubuntu.com/ubuntu-ports/ focal universe
deb http://ports.ubuntu.com/ubuntu-ports/ focal multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ focal-backports main
deb http://ports.ubuntu.com/ubuntu-ports/ focal-security main
END

# apt-get source update and installation
yes "Y" | sudo apt-get update
yes "Y" | sudo apt-get upgrade
yes "Y" | apt install openssh-server iw wpasupplicant hostapd util-linux procps iproute2 haveged dnsmasq iptables net-tools ppp ntp ntpdate bridge-utils can-utils v4l-utils 
yes "Y" | apt install bash-completion docker.io ifupdown resolvconf alsa-utils gpiod cloud-utils libpolkit-agent-1-0 libpolkit-gobject-1-0 policykit-1 udhcpc

# network configuration
cat <<END > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
END

# audio setting
cat <<END > /root/.asoundrc
pcm.!default {
  type plug
  slave {
    pcm "hw:0,0"
  }
}

ctl.!default {
  type hw
  card 0
}
END

# weston
yes "Y" | apt install libinput10 libpixman-1-0 libxkbcommon0 libpng16-16 libfontconfig1 libxcb-shm0 libxcb-render0 libxrender1 libthai0 libharfbuzz0b libcolord2

# chromium
yes "Y" | apt install libnss3 libwebpdemux2 libxslt1.1

# QT5
yes "Y" | apt install libdouble-conversion3

#docker part
groupadd docker
usermod -aG docker ubuntu

# weston desktop support
yes "Y" | apt install libinput10 libpixman-1-0 libxkbcommon0 libpng16-16 libfontconfig1 libxcb-shm0 libxcb-render0 libxrender1 libthai0 libharfbuzz0b libcolord2 libpangocairo-1.0-0

# gstreamer-1.0 dependency
yes "Y" | apt install libdc1394-22 libmodplug1 libsoup2.4-1 librsvg2-2 libopenmpt0 libmpcdec6 libzbar0 libbs2b0 libvpx6 libv4l-0 libavfilter7 libvo-aacenc0 libgdk-pixbuf2.0-0 
yes "Y" | apt install libde265-0 libmms0 libmjpegutils-2.1-0 libvo-amrwbenc0 libwildmidi2 libmpeg2encpp-2.1-0 libvisual-0.4-0 libsrt1 libtag1-dev libcaca0 libavfilter7
yes "Y" | apt install libcodec2-0.9 libxdamage1 libshout3 libchromaprint1 libusrsctp1 libjack0 libsbc1 libmplex2-2.1-0 libavc1394-0 libsoundtouch1 libfluidsynth2 libshout3 libdca0
yes "Y" | apt install libofa0 libsrtp2-1 libdv4 libkate1 libwebrtc-audio-processing1 libaa1 libnice10 libcurl4-gnutls-dev libdvdnav4 libiec61883-0 libgraphene-1.0-0 libspandsp2 libfaad2


# dpkg install latest network-manager and modem-manager for 5gnr module
# mmcli
dpkg -i /opt/deb/5gnr/mm/libmbim-glib4_1.24.4-0.1_arm64.deb
dpkg -i /opt/deb/5gnr/mm/libmbim-proxy_1.24.4-0.1_arm64.deb
dpkg -i /opt/deb/5gnr/mm/libmm-glib0_1.14.2-0.1_arm64.deb
dpkg -i /opt/deb/5gnr/mm/libqmi-glib5_1.26.4-0.1_arm64.deb
dpkg -i /opt/deb/5gnr/mm/libqmi-proxy_1.26.4-0.1_arm64.deb
dpkg -i /opt/deb/5gnr/mm/modemmanager_1.14.2-0.1_arm64.deb
dpkg -i /opt/deb/5gnr/mm/libqmi-utils_1.26.4-0.1_arm64.deb

# nmcli
dpkg -i /opt/deb/5gnr/nm/libbluetooth3_5.55-0ubuntu1_arm64.deb
dpkg -i /opt/deb/5gnr/nm/libndp0_1.7-0ubuntu1_arm64.deb
dpkg -i /opt/deb/5gnr/nm/libselinux1_3.1-2_arm64.deb
dpkg -i /opt/deb/5gnr/nm/libjansson4_2.13.1-1ubuntu1_arm64.deb
dpkg -i /opt/deb/5gnr/nm/libnm0_1.26.2-1ubuntu1_arm64.deb
dpkg -i /opt/deb/5gnr/nm/libteamdctl0_1.31-1_arm64.deb
dpkg -i /opt/deb/5gnr/nm/network-manager_1.26.2-1ubuntu1_arm64.deb

sudo systemctl daemon-reload
sudo systemctl disable getty@tty1.service
sudo systemctl enable rc-local.service

# enable qca bluetooth service when boot
# sudo systemctl  enable serial-qcabtfw@ttymxc0

# let network-manager handle all network interfaces
touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
sed -i 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf

# disable type password everytime using ubuntu user
sed -i 's/sudo\tALL=(ALL:ALL) ALL/sudo\tALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

# zram swap size
echo "${COL_GREEN}Add swap partition...Default size is one-fourth of total memory${COL_NORMAL}"
yes "Y" | apt install zram-config
sed -i 's/totalmem\ \/\ 2/totalmem\ \/\ 4/' /usr/bin/init-zram-swapping


mkdir -p /lib/modules/
echo -e "source /etc/profile.d/weston.sh" >> /root/.bashrc

# clear the patches
rm -rf var/cache/apt/archives/*
sync
