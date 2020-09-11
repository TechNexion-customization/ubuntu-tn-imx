#!/bin/bash

TOP=${PWD}

# generate minimum rootfs
gen_pure_rootfs() {
  wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/technexion-android/android_restricted_extra/raw/master/imx8-focol-proprietary.tar.gz
  tar zxvf imx8-focol-proprietary.tar.gz
  rm ./imx8-focol-proprietary.tar.gz
  mkdir rootfs
  sudo debootstrap --arch=arm64 --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign focal ${TOP}/rootfs
  sudo cp /usr/bin/qemu-aarch64-static ${TOP}/rootfs/usr/bin
  sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage
  sudo cp ${TOP}/qemu_install.sh ${TOP}/rootfs/usr/bin/
  sync

  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/qemu_install.sh; /usr/bin/qemu_install.sh gui"
  sync

  # fs-overlay
  sudo cp -a ${TOP}/rootfs_overlay/usr/bin/* ${TOP}/rootfs/usr/bin/
  sudo cp -a ${TOP}/rootfs_overlay/usr/lib/aarch64-linux-gnu/* ${TOP}/rootfs/usr/lib/aarch64-linux-gnu/
  sudo cp -a ${TOP}/rootfs_overlay/usr/lib/weston ${TOP}/rootfs/usr/lib/
  sudo cp -a ${TOP}/rootfs_overlay/usr/include/* ${TOP}/rootfs/usr/include/
  sudo cp -a ${TOP}/rootfs_overlay/usr/share/* ${TOP}/rootfs/usr/share/

  sudo cp -a ${TOP}/rootfs_overlay/etc/alternatives/* ${TOP}/rootfs/etc/alternatives/
  sudo cp -a ${TOP}/rootfs_overlay/etc/profile.d/* ${TOP}/rootfs/etc/profile.d/
  sudo cp -a ${TOP}/rootfs_overlay/etc/rc.local ${TOP}/rootfs/etc/rc.local
  sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/* ${TOP}/rootfs/etc/systemd/system/

  sudo mkdir -p ${TOP}/rootfs/etc/xdg/weston/
  sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/weston/* ${TOP}/rootfs/etc/xdg/weston/

  sync

  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "sudo ldconfig"

  sudo rm -rf ${TOP}/rootfs/usr/bin/qemu_install.sh

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
}

merge_tn_fs_overlay() {
  wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/technexion-android/android_restricted_extra/raw/master/imx8-focol-proprietary.tar.gz
  tar zxvf imx6_7-bionic.tar.gz
  mv ${TOP}/fs_overlay ${TOP}/
  rm -rf ${TOP}/imx6_7-bionic.tar.gz
  rm -rf ${TOP}/fs_overlay
}

throw_rootfs() {
  sudo swapoff ${TOP}/rootfs/swapfile
  sudo rm -rf ${TOP}/rootfs/
  sudo rm rootfs.tgz
}

gen_pure_rootfs
