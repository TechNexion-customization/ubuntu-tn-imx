######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

ROOTFS_PACK := rootfs.tgz

all: build

clean:
	rm -rf output/$(ROOTFS_PACK)
distclean: clean

build-rootfs: src
	@echo "build rootfs..."
	./gen_rootfs.sh
	@mv $(ROOTFS_PACK) output/$(ROOTFS_PACK)
	@rm -rf rootfs

build: build-rootfs

src:
	if [ ! -f output ] ; then \
		mkdir -p output; \
	fi

.PHONY: build-rootfs build
