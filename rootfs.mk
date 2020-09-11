######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

ROOTFS_PACK := rootfs.tgz

all: build

clean:
	rm -rf output/$(ROOTFS_PACK)
distclean: clean

build-rootfs:
	@echo "build rootfs..."
	./gen_rootfs.sh
	@mv $(ROOTFS_PACK) output/$(ROOTFS_PACK)

build: build-rootfs

.PHONY: build-rootfs build
