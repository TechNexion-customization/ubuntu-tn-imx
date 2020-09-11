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
yes "Y" | apt install openssh-server iw wpasupplicant hostapd util-linux procps iproute2 haveged dnsmasq iptables net-tools bluez ppp ntp ntpdate bridge-utils can-utils v4l-utils 
yes "Y" | apt install bash-completion docker.io network-manager ifupdown

# apt-get source adding
cat <<END > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp
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

sudo systemctl disable getty@tty1.service
sudo systemctl enable rc-local.service

echo "${COL_GREEN}Add swap partition...Default size is 256MB${COL_NORMAL}"
dd if=/dev/zero of=/swapfile bs=1M count=256
chmod 600 /swapfile
mkswap /swapfile

mkdir -p /lib/modules/
echo -e "source /etc/profile.d/weston.sh" >> /root/.bashrc

# clear the patches
rm -rf var/cache/apt/archives/*
