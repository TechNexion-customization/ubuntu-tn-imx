#!/bin/bash

COL_GREEN="\e[1;32m"
COL_NORMAL="\e[m"

echo "${COL_GREEN}Technexion customized minimal rootfs staring...${COL_NORMAL}"
echo "${COL_GREEN}creating ubuntu sudoer account...${COL_NORMAL}"
cd /
echo technexion > /etc/hostname
echo -e "127.0.1.1\ttechnexion" >> /etc/hosts
echo -e "nameserver\t8.8.8.8" >> /etc/hosts

(echo "root"; echo "root";) | passwd
(echo "ubuntu"; echo "ubuntu"; echo;) | adduser ubuntu
usermod -aG sudo ubuntu

echo "${COL_GREEN}apt-get server upgrading...${COL_NORMAL}"

touch /etc/apt/sources.list
# apt-get source adding
cat <<END > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports/ jammy main
deb http://ports.ubuntu.com/ubuntu-ports/ jammy universe
deb http://ports.ubuntu.com/ubuntu-ports/ jammy multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-backports main
deb http://ports.ubuntu.com/ubuntu-ports/ jammy-security main
END


# apt-get source update and installation
yes "Y" | apt-get update
yes "Y" | apt-get upgrade
yes "Y" | apt install openssh-server iw wpasupplicant hostapd util-linux procps iproute2 haveged dnsmasq iptables net-tools ppp ntp ntpdate bridge-utils can-utils v4l-utils usbutils
yes "Y" | apt install bash-completion ifupdown resolvconf alsa-utils gpiod cloud-utils udhcpc feh modemmanager software-properties-common bluez blueman


#install docker-ce
#yes "Y" | apt install gnupg apt-transport-https ca-certificates curl software-properties-common
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=armhf] https://download.docker.com/linux/ubuntu bionic stable"
#yes "Y" | apt-get update
#apt-cache policy docker-ce
#yes "Y" | apt install docker-ce

# audio setting
cat <<END > /home/ubuntu/.asoundrc
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


# GUI desktop support
yes "Y" | apt install xfce4 slim fluxbox onboard xterm xfce4-screenshooter rfkill alsa-utils minicom  strace firefox libssl1.1

# Install ubuntu-restricted-extras
echo steam steam/license note '' | sudo debconf-set-selections
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections # auto accepted eula agreements
yes "Y" | apt install ttf-mscorefonts-installer
echo ubuntu-restricted-extras msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections # auto accepted eula agreements
yes "Y" | apt install ubuntu-restricted-extras

#cd /usr/share/xsessions
#cp -a xfce.desktop ubuntu.desktop
#echo 3 | update-alternatives --config x-session-manager
#sync

yes "Y" | apt remove xfce4-screensaver xscreensaver gnome-terminal
yes "Y" | apt-get autoremove


# xfce4 auto login
#rm /etc/gdm3/custom.conf
#touch /etc/gdm3/custom.conf
#cat <<END > /etc/gdm3/custom.conf
#[daemon]
#AutomaticLoginEnable = true
#AutomaticLogin = ubuntu
#user-session=xfce
#
#[security]
#
#[xdmcp]
#
#[chooser]
#
#[debug]
#
#END

mkdir -p /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/
chown ubuntu:ubuntu /home/ubuntu/.config/
touch /home/ubuntu/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
cat <<END > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="empty"/>
    <property name="IconThemeName" type="empty"/>
    <property name="DoubleClickTime" type="empty"/>
    <property name="DoubleClickDistance" type="empty"/>
    <property name="DndDragThreshold" type="empty"/>
    <property name="CursorBlink" type="empty"/>
    <property name="CursorBlinkTime" type="empty"/>
    <property name="SoundThemeName" type="empty"/>
    <property name="EnableEventSounds" type="empty"/>
    <property name="EnableInputFeedbackSounds" type="empty"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="empty"/>
    <property name="Antialias" type="empty"/>
    <property name="Hinting" type="empty"/>
    <property name="HintStyle" type="empty"/>
    <property name="RGBA" type="empty"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="empty"/>
    <property name="ColorPalette" type="empty"/>
    <property name="FontName" type="string" value="Sans 15"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="empty"/>
    <property name="KeyThemeName" type="empty"/>
    <property name="ToolbarStyle" type="empty"/>
    <property name="ToolbarIconSize" type="empty"/>
    <property name="MenuImages" type="empty"/>
    <property name="ButtonImages" type="empty"/>
    <property name="MenuBarAccel" type="empty"/>
    <property name="CursorThemeName" type="empty"/>
    <property name="CursorThemeSize" type="empty"/>
    <property name="DecorationLayout" type="empty"/>
  </property>
</channel>
END

chown ubuntu:ubuntu /home/ubuntu/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

touch /usr/bin/tn_init_xfce.sh
chmod a+x /usr/bin/tn_init_xfce.sh
cat <<END > /usr/bin/tn_init_xfce.sh
##########################
# Author: Wig Cheng      #
# Date: 12/14/2020       #
##########################

#!/bin/bash
export DISPLAY=:0.0

MMC_DEV=\$(lsblk | grep mmcblk | head -1 |  awk '{print \$1}')
ROOTFS_SIZE=\$(lsblk | grep "\$MMC_DEV"p2 | awk '{print \$4}' | awk -F. '{print \$1}')

if [ "\$ROOTFS_SIZE" -lt 3 ]; then

  sleep 5

  feh -x -F -Z /etc/xdg/tn-standby.jpg &
  sleep 5
  yes "Y" | sudo apt-get install xfce4
  sync
  (echo "n"; echo "p"; echo "3"; echo; echo; echo "w") | sudo fdisk /dev/"\$MMC_DEV"
  sudo mkfs.ext4 /dev/"\$MMC_DEV"p3
  sync
  (echo "d"; echo "3"; echo "d"; echo "2"; echo "n"; echo "p"; echo "2"; echo "81920"; echo; echo "w") | sudo fdisk /dev/"\$MMC_DEV"
  sudo resize2fs /dev/"\$MMC_DEV"p2
  sync

  sudo systemctl enable tn_init.service
  sudo depmod
  sync

  sudo reboot
fi

xset s off
xset dpms 0 0 0
xset -dpms s off

blueman-applet &
sleep 3
sudo rfkill unblock 0
sudo rfkill unblock 1
sync
sudo systemctl start bluetooth
sudo hciconfig hci0 up

END

mkdir -p /home/ubuntu/.config/autostart/
touch /home/ubuntu/.config/autostart/tn-xfce4.desktop
chown ubuntu:ubuntu /home/ubuntu/.config/autostart/tn-xfce4.desktop

cat <<END > /home/ubuntu/.config/autostart/tn-xfce4.desktop
[Desktop Entry]
Type=Application
Name=TN init
Exec=tn_init_xfce.sh
Terminal=false
END

yes "Y" | apt install --reinstall network-manager-gnome

sudo systemctl daemon-reload
#sudo systemctl disable getty@tty1.service
sudo chmod a+x /usr/bin/system_init

# disable qca bluetooth service when boot
sudo systemctl disable bluetooth

# let network-manager handle all network interfaces
touch /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
sed -i 's/managed=false/managed=true/' /etc/NetworkManager/NetworkManager.conf

# disable type password everytime using ubuntu user
sed -i 's/sudo\tALL=(ALL:ALL) ALL/sudo\tALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

# zram swap size
echo "${COL_GREEN}Add swap partition...Default size is one-fourth of total memory${COL_NORMAL}"
yes "Y" | apt install zram-config
sed -i 's/totalmem\ \/\ 2/totalmem\ \/\ 4/' /usr/bin/init-zram-swapping


# vpu requirement
yes "Y" | apt install libjpeg62 frei0r-plugins libdevil-dev libfmt-dev
yes "Y" | apt install --reinstall libgdk-pixbuf2.0-0
yes "Y" | apt install gstreamer1.0-x gstreamer1.0-tools gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-alsa

# fluxbox init configuration
mkdir -p /home/ubuntu/.fluxbox/
echo "session.screen0.toolbar.visible:                   false" >> /home/ubuntu/.fluxbox/init

sudo ln -sn /usr/lib/arm-linux-gnueabihf/gstreamer-1.0 /usr/lib/gstreamer-1.0
sudo ln -sn /usr/lib/arm-linux-gnueabihf/dri /usr/lib/dri
sudo ln -sn /usr/lib/arm-linux-gnueabihf/imx-mm /usr/lib/imx-mm

# remove bug existing applications
rm -rf /usr/share/applications/xfce-display-settings.desktop

mkdir -p /lib/modules/

# clear the patches
rm -rf /var/cache/apt/archives/*
sync
