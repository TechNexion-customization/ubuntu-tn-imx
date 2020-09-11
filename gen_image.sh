#!/bin/bash

TOP=${PWD}

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
sudo cp -rv ./output/kernel/linux-tn-imx/arch/arm64/boot/dts/freescale/imx8mm-pico-pi-ili9881c.dtb mnt/
sudo umount mnt

sudo mount /dev/mapper/"$mapper_dev"p2 mnt
cd mnt
sudo tar zxvf ../output/rootfs.tgz
cd ${TOP}
sudo cp -rv ./output/kernel/linux-tn-imx/modules/lib/modules/* mnt/lib/modules/
sudo umount mnt

rm -rf mnt

sudo dd if=./output/u-boot/u-boot-tn-imx/imx-mkimage/iMX8M/flash.bin of="$loop_dev" bs=1k seek=33 conv=fsync
sync

sudo kpartx -d test.img
