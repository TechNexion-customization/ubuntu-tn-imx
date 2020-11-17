#!/bin/bash

TOP=${PWD}

# generate minimum rootfs
gen_pure_rootfs() {

  if [ ! -d rootfs_overlay ] ; then
    wget -c -t 0 --timeout=60 --waitretry=60 ftp://ftp.technexion.net/development_resources/NXP/ubuntu/proprietary/imx8-focol-proprietary.tar.gz
    tar zxvf imx8-focol-proprietary.tar.gz
    rm ./imx8-focol-proprietary.tar.gz
  fi

  mkdir rootfs

  echo "generate ubuntu rootfs... default version: focal LTS"
  sudo debootstrap --arch=arm64 --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign focal ${TOP}/rootfs
  sudo cp /usr/bin/qemu-aarch64-static ${TOP}/rootfs/usr/bin
  sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage
  sudo cp ${TOP}/qemu_install.sh ${TOP}/rootfs/usr/bin/
  sudo cp -rv ${TOP}/deb/ ${TOP}/rootfs/opt/

  sync

  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/qemu_install.sh; /usr/bin/qemu_install.sh gui"
  sync

  # fs-overlay
  sudo cp -a ${TOP}/rootfs_overlay/usr/bin/* ${TOP}/rootfs/usr/bin/
  sudo cp -a ${TOP}/rootfs_overlay/usr/lib/aarch64-linux-gnu/* ${TOP}/rootfs/usr/lib/aarch64-linux-gnu/
  sudo cp -a ${TOP}/rootfs_overlay/usr/lib/weston ${TOP}/rootfs/usr/lib/
  sudo cp -a ${TOP}/rootfs_overlay/usr/include/* ${TOP}/rootfs/usr/include/
  sudo cp -a ${TOP}/rootfs_overlay/usr/share/* ${TOP}/rootfs/usr/share/
  sudo cp -a ${TOP}/rootfs_overlay/usr/libexec/* ${TOP}/rootfs/usr/libexec/

  sudo cp -a ${TOP}/rootfs_overlay/etc/alternatives/* ${TOP}/rootfs/etc/alternatives/
  sudo cp -a ${TOP}/rootfs_overlay/etc/profile.d/* ${TOP}/rootfs/etc/profile.d/
  sudo cp -a ${TOP}/rootfs_overlay/etc/rc.local ${TOP}/rootfs/etc/rc.local
  sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/rc-local.service ${TOP}/rootfs/etc/systemd/system/rc-local.service

  if [[ "$@" == "pico-imx8mm" ]] || [[ "$@" == "edm-g-imx8mp" ]] || [[ "$@" == "axon-imx8mp" ]] ; then
    sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc0.service ${TOP}/rootfs/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc0.service
  elif [[ "$@" == "edm-imx8m" ]]; then
    sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc1.service ${TOP}/rootfs/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc1.service
  fi

  sudo cp -a ${TOP}/rootfs_overlay/etc/bluetooth ${TOP}/rootfs/etc/
  sudo cp -a ${TOP}/rootfs_overlay/etc/dbus-1/* ${TOP}/rootfs/etc/dbus-1/

  sudo mkdir -p ${TOP}/rootfs/etc/xdg/weston/
  sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/weston/* ${TOP}/rootfs/etc/xdg/weston/

  sudo cp -rv ${TOP}/rootfs_overlay/lib/firmware/* ${TOP}/rootfs/lib/firmware/
  sudo cp -rv ${TOP}/rootfs_overlay/lib/systemd/* ${TOP}/rootfs/lib/systemd/
  sudo cp -rv ${TOP}/rootfs_overlay/lib/udev/* ${TOP}/rootfs/lib/udev/

  sync

  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "sudo ldconfig"

  sudo rm -rf ${TOP}/rootfs/usr/bin/qemu_install.sh
  sudo rm -rf ${TOP}/rootfs/opt/deb/

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
}

gen_pure_rootfs "$1"
