#!/bin/bash

TOP=${PWD}

echo "target: --------------> $1"
echo "creating 3.4GiB empty image ..."
sudo dd if=/dev/zero of=test.img bs=1M count=3400
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
sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/Image mnt/
if [[ "$1" == "pico-imx8mm" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mm-pico-pi-ili9881c.dtb mnt/
elif [[ "$1" == "axon-imx8mp" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mp-axon-wizard.dtb mnt/
elif [[ "$1" == "edm-g-imx8mp" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mp-edm-g-wb.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mp-edm-g-wb-lvds-vl10112880.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard-mipi-dcss-g080uan01.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mp-edm-g-wb-lvds-vl215192108.dtbo mnt/
elif [[ "$1" == "edm-imx8m" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard-mipi-dcss-ili9881c.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard-mipi-dcss-g080uan01.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard-mipi-dcss-g101uan02.dtbo mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-edm-wizard-mipi2hdmi-adv7535.dtbo mnt/
elif [[ "$1" == "pico-imx8m" ]]; then
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-pico-pi.dtb mnt/
  sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mq-pico-pi-mipi-dcss-ili9881c.dtbo mnt/
fi
sudo umount mnt

sudo mount /dev/mapper/"$mapper_dev"p2 mnt
cd mnt
sudo tar zxvf ../output/rootfs.tgz
cd ${TOP}
sudo cp -rv ./output/kernel/linux-tn-imx/modules/lib/modules/* mnt/lib/modules/
sudo umount mnt

rm -rf mnt

if [[ "$1" == "pico-imx8mm" ]] || [[ "$1" == "edm-imx8m" ]] || [[ "$1" == "pico-imx8m" ]]; then
  bootloader_offset=33
elif [[ "$1" == "axon-imx8mp" ]] || [[ "$1" == "edm-g-imx8mp" ]]; then
  bootloader_offset=32
fi

sudo dd if=./output/u-boot/u-boot-tn-imx/imx-mkimage/iMX8M/flash.bin of="$loop_dev" bs=1k seek="$bootloader_offset" conv=fsync

sync

sudo kpartx -d test.img
