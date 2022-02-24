#!/bin/bash

TOP=${PWD}

# generate minimum rootfs
gen_pure_rootfs() {

  if [[ $(echo $1 | grep "imx6") ]] || [[ $(echo $1 | grep "imx7") ]]; then
    ARCH=armhf
    QEMU=qemu-arm-static
    proprietary=imx6
  else
    ARCH=arm64
    QEMU=qemu-aarch64-static
    proprietary=imx8
  fi

  if [ ! -d rootfs_overlay ] ; then
    wget -c -t 0 --timeout=60 --waitretry=60 https://download.technexion.com/development_resources/NXP/ubuntu/22.04/proprietary-package/"$proprietary"-jammy-proprietary.tar.gz
    tar zxvf "$proprietary"-jammy-proprietary.tar.gz
    rm ./"$proprietary"-jammy-proprietary.tar.gz
  fi

  mkdir rootfs

  echo "generate ubuntu rootfs... default version: focal LTS"
  sudo debootstrap --arch="$ARCH" --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign jammy ${TOP}/rootfs
  sudo cp /usr/bin/"$QEMU" ${TOP}/rootfs/usr/bin
  sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage

  if [[ $(echo $1 | grep "imx6") ]] || [[ $(echo $1 | grep "imx7") ]]; then
    sudo cp ${TOP}/qemu_install-imx6_7.sh ${TOP}/rootfs/usr/bin/
  else
    sudo cp ${TOP}/qemu_install.sh ${TOP}/rootfs/usr/bin/
  fi

  sudo cp ${TOP}/qemu_install.sh ${TOP}/rootfs/usr/bin/
  sudo cp -rv ${TOP}/deb/ ${TOP}/rootfs/opt/

  sync

  if [[ $(echo $1 | grep "imx6") ]] || [[ $(echo $1 | grep "imx7") ]]; then
    sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/qemu_install-imx6_7.sh; /usr/bin/qemu_install-imx6_7.sh"
  else
    sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/qemu_install.sh; /usr/bin/qemu_install.sh"
  fi
  sync

  if [[ $(echo $1 | grep "imx8") ]]; then

    # fs-overlay
    sudo cp -a ${TOP}/rootfs_overlay/usr/bin/* ${TOP}/rootfs/usr/bin/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/aarch64-linux-gnu/* ${TOP}/rootfs/usr/lib/aarch64-linux-gnu/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/weston ${TOP}/rootfs/usr/lib/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/dri ${TOP}/rootfs/usr/lib/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/gstreamer-1.0 ${TOP}/rootfs/usr/lib/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/libweston-9 ${TOP}/rootfs/usr/lib/
    sudo cp -a ${TOP}/rootfs_overlay/usr/include/* ${TOP}/rootfs/usr/include/
    sudo cp -a ${TOP}/rootfs_overlay/usr/share/* ${TOP}/rootfs/usr/share/
    sudo cp -a ${TOP}/rootfs_overlay/usr/libexec/* ${TOP}/rootfs/usr/libexec/

    sudo cp -a ${TOP}/rootfs_overlay/etc/alternatives/* ${TOP}/rootfs/etc/alternatives/
    sudo cp -a ${TOP}/rootfs_overlay/etc/profile.d/* ${TOP}/rootfs/etc/profile.d/
    sudo cp -a ${TOP}/rootfs_overlay/etc/rc.local ${TOP}/rootfs/etc/rc.local
    sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/rc-local.service ${TOP}/rootfs/etc/systemd/system/rc-local.service

    if [[ "$@" == "pico-imx8mm" ]] || [[ "$@" == "edm-g-imx8mp" ]] || [[ "$@" == "axon-e-imx8mp" ]] ; then
      sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc0.service ${TOP}/rootfs/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc0.service
    elif [[ "$@" == "edm-imx8m" ]] ||  [[ "$@" == "pico-imx8m" ]] ; then
      sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc1.service ${TOP}/rootfs/etc/systemd/system/multi-user.target.wants/serial-qcabtfw@ttymxc1.service
    fi

    sudo cp -a ${TOP}/rootfs_overlay/etc/bluetooth ${TOP}/rootfs/etc/
    sudo cp -a ${TOP}/rootfs_overlay/etc/dbus-1/* ${TOP}/rootfs/etc/dbus-1/

    sudo mkdir -p ${TOP}/rootfs/etc/xdg/weston/
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/weston/* ${TOP}/rootfs/etc/xdg/weston/

    sudo cp -rv ${TOP}/rootfs_overlay/lib/systemd/* ${TOP}/rootfs/lib/systemd/
    sudo cp -rv ${TOP}/rootfs_overlay/lib/udev/* ${TOP}/rootfs/lib/udev/

    sync
  elif [[ $(echo $1 | grep "imx6$") ]]; then

    # fs-overlay
    echo "Start copy VPU relate libraries"

    # VPU part
    sudo cp -a ${TOP}/rootfs_overlay/gst-imx-plugin/lib/lib* ${TOP}/rootfs/usr/lib/
    sudo cp -a ${TOP}/rootfs_overlay/gst-imx-plugin/lib/arm-linux-gnueabihf/lib* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/gst-imx-plugin/lib/arm-linux-gnueabihf/pkgconfig/*.pc ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/pkgconfig/
    sudo cp -a ${TOP}/rootfs_overlay/gst-imx-plugin/lib/arm-linux-gnueabihf/gstreamer-1.0/lib* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/gstreamer-1.0/
    sudo cp -a ${TOP}/rootfs_overlay/gst-imx-plugin/include/* ${TOP}/rootfs/usr/include

    # imx-codec
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-codec/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-codec/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-codec/usr/share ${TOP}/rootfs/usr/

    # imx-gpu-g2d
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-g2d/opt/* ${TOP}/rootfs/opt/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-g2d/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-g2d/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # imx-gpu-viv
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-viv/etc/* ${TOP}/rootfs/etc/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-viv/opt/* ${TOP}/rootfs/opt/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-viv/usr/bin/ ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-viv/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gpu-viv/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # imx-gst1.0-plugin
    #sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gst1.0-plugin/usr/bin/ ${TOP}/rootfs/usr/
    #sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gst1.0-plugin/usr/include ${TOP}/rootfs/usr/
    #sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gst1.0-plugin/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    #sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-gst1.0-plugin/usr/share ${TOP}/rootfs/usr/

    # imx-lib
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-lib/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-lib/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # imx-vpu
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-vpu/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-vpu/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # imx-vpuwrap
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-vpuwrap/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/imx-vpuwrap/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/


    # harfbuzz
    sudo cp -a ${TOP}/rootfs_overlay/vpu/harfbuzz/usr/bin ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/harfbuzz/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/harfbuzz/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # libepoxy
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libepoxy/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libepoxy/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # libfm
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libfm/etc/* ${TOP}/rootfs/etc/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libfm/usr/bin ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libfm/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libfm/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libfm/usr/share ${TOP}/rootfs/usr/

    # libgpuperfcnt
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libgpuperfcnt/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libgpuperfcnt/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/libgpuperfcnt/usr/share ${TOP}/rootfs/usr/

    # librsvg
    # sudo cp -a ${TOP}/rootfs_overlay/vpu/librsvg/etc/* ${TOP}/rootfs/etc/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/librsvg/usr/bin ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/librsvg/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/librsvg/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/vpu/librsvg/usr/share ${TOP}/rootfs/usr/

    echo "Done for VPU relate libraries copying"


    echo "Start copy GPU libraries copying"

    # xf86-video-imx-vivante
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xf86-video-imx-vivante/etc/init.d ${TOP}/rootfs/etc/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xf86-video-imx-vivante/usr/bin ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xf86-video-imx-vivante/usr/include ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xf86-video-imx-vivante/usr/lib/xorg/modules/drivers/vivante_drv.so ${TOP}/rootfs/usr/lib/xorg/modules/drivers/vivante_drv.so

    # xserver-xorg
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xserver-xorg/usr/bin/* ${TOP}/rootfs/usr/bin/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xserver-xorg/usr/include/* ${TOP}/rootfs/usr/include/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xserver-xorg/var/* ${TOP}/rootfs/var/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xserver-xorg/usr/share ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xserver-xorg/usr/lib/pkgconfig ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/xserver-xorg/usr/lib/xorg ${TOP}/rootfs/usr/lib/

    # mesa
    sudo cp -a ${TOP}/rootfs_overlay/gpu/mesa/usr/share ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/mesa/usr/include/* ${TOP}/rootfs/usr/include/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/mesa/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # libdrm
    sudo cp -a ${TOP}/rootfs_overlay/gpu/libdrm/usr/share ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/libdrm/usr/include/* ${TOP}/rootfs/usr/include/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/libdrm/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/

    # glmark2
    sudo cp -a ${TOP}/rootfs_overlay/gpu/glmark2/usr/bin ${TOP}/rootfs/usr/
    sudo cp -a ${TOP}/rootfs_overlay/gpu/glmark2/usr/share ${TOP}/rootfs/usr/

    echo "done copy GPU libraries copying"

    # desktop configuration
    sudo cp -a ${TOP}/rootfs_overlay/etc/X11/xorg.conf ${TOP}/rootfs/etc/X11/xorg.conf
  fi

  if [[ $(echo $1 | grep "imx6") ]]; then
    sudo cp -a ${TOP}/rootfs_overlay/etc/slim.conf ${TOP}/rootfs/etc/slim.conf
    sudo cp -a ${TOP}/rootfs_overlay/home/ubuntu/.fluxbox/startup ${TOP}/rootfs/home/ubuntu/.fluxbox/startup
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/tn-standby.jpg ${TOP}/rootfs/etc/xdg/tn-standby.jpg
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/tn-weston.png ${TOP}/rootfs/etc/xdg/tn-weston.png
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/tn-weston.png ${TOP}/rootfs/usr/share/backgrounds/xfce/xfce-stripes.png

    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libprotobuf.so.20 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libprotobuf.so.20.0.2 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libtbbmalloc_proxy.so.2 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libtbbmalloc.so.2 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libtbb.so.2 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libwebp.so.7 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libwebp.so.7.0.5 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libcroco-0.6.so.3 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
    sudo cp -a ${TOP}/rootfs_overlay/usr/lib/arm-linux-gnueabihf/libcroco-0.6.so.3.0.1 ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
  elif [[ $(echo $1 | grep "imx7") ]]; then
    sudo cp -a ${TOP}/rootfs_overlay/etc/slim.conf ${TOP}/rootfs/etc/slim.conf
    sudo cp -a ${TOP}/rootfs_overlay/home/ubuntu/.fluxbox/startup ${TOP}/rootfs/home/ubuntu/.fluxbox/startup
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/tn-standby.jpg ${TOP}/rootfs/etc/xdg/tn-standby.jpg
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/tn-weston.png ${TOP}/rootfs/etc/xdg/tn-weston.png
    sudo cp -a ${TOP}/rootfs_overlay/etc/xdg/tn-weston.png ${TOP}/rootfs/usr/share/backgrounds/xfce/xfce-stripes.png
  fi

  echo "Start copy tweaked bt libraries copying"
  sudo cp -a ${TOP}/rootfs_overlay/bluez5/usr/bin/* ${TOP}/rootfs/usr/bin/
  sudo cp -a ${TOP}/rootfs_overlay/bluez5/usr/lib/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
  echo "done copy tweaked bt libraries copying"

  # tn service
  sudo cp -a ${TOP}/rootfs_overlay/etc/systemd/system/tn_init.service ${TOP}/rootfs/etc/systemd/system/
  sudo cp -a ${TOP}/rootfs_overlay/usr/bin/system_init ${TOP}/rootfs/usr/bin/system_init

  sudo cp -a ${TOP}/rootfs_overlay/home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml ${TOP}/rootfs/home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
  sudo cp -rv ${TOP}/rootfs_overlay/lib/firmware/* ${TOP}/rootfs/lib/firmware/

  sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "sudo ldconfig"

  sudo rm -rf ${TOP}/rootfs/usr/bin/qemu_install.sh
  sudo rm -rf ${TOP}/rootfs/usr/bin/qemu_install-imx6_7.sh
  sudo rm -rf ${TOP}/rootfs/opt/deb/

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
}

gen_pure_rootfs "$1"
