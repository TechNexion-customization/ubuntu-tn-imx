#!/bin/bash

TOP=${PWD}

echo "target: --------------> $1"

if [[ "$(echo "$1" | grep "imx8")" ]]; then
  echo "creating 3.8GiB empty image ..."
  sudo dd if=/dev/zero of=test.img bs=1M count=3800
else
  echo "creating 2.9GiB empty image ..."
  sudo dd if=/dev/zero of=test.img bs=1M count=2900
fi

echo "created."

sudo kpartx -av test.img
loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
(echo "n"; echo "p"; echo; echo "16385"; echo "+32M"; echo "n"; echo "p"; echo; echo "81920"; echo ""; echo "a"; echo "1"; echo "w";) | sudo fdisk "$loop_dev"
sudo kpartx -d test.img
sync

sudo kpartx -av test.img
loop_dev=$(losetup | grep "test.img" | awk  '{print $1}')
mapper_dev=$(losetup | grep "test.img" | awk  '{print $1}' | awk -F/ '{print $3}')

sudo mkfs.vfat -F 32 /dev/mapper/"$mapper_dev"p1
sudo mkfs.ext4 /dev/mapper/"$mapper_dev"p2

mkdir mnt

sudo mount /dev/mapper/"$mapper_dev"p1 mnt

if [[ "$(echo "$1" | grep "imx8")" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/Image mnt/
else
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/zImage mnt/
fi


if [[ "$1" == "pico-imx8mm" ]]; then
  # pi
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mm-pico-pi.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-pi-ili9881c.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-pi-ov5640.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-pi-ov5645.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-pi-clixnfc.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-pi-voicehat.dtbo mnt/
  # wizard
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mm-pico-wizard.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-ili9881c.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-g080uan01.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-g101uan02.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-mipi2hdmi-adv7535.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-ov5640.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-ov5645.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-sn65dsi84-vl10112880.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-sn65dsi84-vl215192108.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-voicehat.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-clix1nfc.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mm-pico-wizard-clix2nfc.dtbo mnt/
elif [[ "$1" == "axon-e-imx8mp" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mp-axon-wizard.dtb mnt/
elif [[ "$1" == "edm-g-imx8mp" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mp-edm-g-wb.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mp-edm-g-wb-lvds-vl10112880.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mp-edm-g-wb-lvds-vl215192108.dtbo mnt/
elif [[ "$1" == "edm-imx8m" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-edm-wizard-mipi-dcss-ili9881c.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-edm-wizard-mipi-dcss-g080uan01.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-edm-wizard-mipi-dcss-g101uan02.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-edm-wizard-mipi2hdmi-adv7535.dtbo mnt/
elif [[ "$1" == "pico-imx8m" ]]; then
  # pi
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-pico-pi.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-pi-mipi-ili9881c.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-pi-ov5640.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-pi-ov5645.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-pi-voicehat.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-pi-dual.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-pi-clixnfc.dtbo mnt/
  # wizard
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-pico-wizard.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-ili9881c.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-g080uan01.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-g101uan02.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-mipi2hdmi-adv7535.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-sn65dsi84-vl10112880.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-sn65dsi84-vl215192108.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-ov5640.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-ov5645.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-voicehat.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-clix1nfc.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/overlays/imx8mq-pico-wizard-clix2nfc.dtbo mnt/
elif [[ "$1" == "pico-imx6" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6q-pico-pi-qca.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6q-pico-nymph-qca.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6dl-pico-pi-qca.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6dl-pico-nymph-qca.dtb mnt/
elif [[ "$1" == "edm-imx6" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6q-edm1-fairy-qca.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6dl-edm1-fairy-qca.dtb mnt/
elif [[ "$1" == "pico-imx6ull" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx6ull-pico-pi-qca.dtb mnt/
elif [[ "$1" == "pico-imx7d" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm/boot/dts/imx7d-pico-pi-qca.dtb mnt/
fi

sudo umount mnt

sudo mount /dev/mapper/"$mapper_dev"p2 mnt
cd mnt
sudo tar zxvf ../output/rootfs.tgz
cd ${TOP}
sudo cp -rv ./output/kernel/linux-tn-imx/modules/lib/modules/* mnt/lib/modules/
sudo umount mnt


if [[ "$(echo "$1" | grep "imx8")" ]]; then
  if [[ "$1" == "pico-imx8mm" ]] || [[ "$1" == "edm-imx8m" ]] || [[ "$1" == "pico-imx8m" ]]; then
    bootloader_offset=33
  elif [[ "$1" == "axon-e-imx8mp" ]] || [[ "$1" == "edm-g-imx8mp" ]]; then
    bootloader_offset=32
  fi
  sudo dd if=./output/u-boot/u-boot-tn-imx/imx-mkimage/iMX8M/flash.bin of="$loop_dev" bs=1k seek="$bootloader_offset" conv=fsync
  sync
else
  sudo dd if=./output/u-boot/u-boot-tn-imx/SPL of="$loop_dev" bs=1k seek=1 conv=sync
  sudo mount /dev/mapper/"$mapper_dev"p1 mnt
  sudo cp -rv ./output/u-boot/u-boot-tn-imx/u-boot.img mnt

  sudo touch mnt/uEnv.txt
  if [[ "$(echo "$1" | grep "imx6$")" ]]; then
    if [[ "$(echo "$1" | grep "edm-imx6")" ]]; then
      sudo sh -c 'echo baseboard=fairy > mnt/uEnv.txt'
    else
      sudo sh -c 'echo baseboard=nymph > mnt/uEnv.txt'
    fi
    sudo sh -c 'echo displayinfo=video=mxcfb0:dev=hdmi,1280x720M@60,if=RGB24,bpp=32 >> mnt/uEnv.txt'
  else
    sudo sh -c 'echo baseboard=pi > mnt/uEnv.txt'
    sudo sh -c 'echo displayinfo=video=mxcfb0:dev=lcd,800x480@60,if=RGB24,bpp=32 >> mnt/uEnv.txt'
  fi
  sudo sh -c 'echo wifi_module=qca >> mnt/uEnv.txt'

  sudo umount mnt
fi

rm -rf mnt

sudo kpartx -d test.img
