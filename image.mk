######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

DEFAULT_IMAGE := ubuntu.img

all: build

clean:
	rm -rf $(OUTPUT_DIR)/$(DEFAULT_IMAGE)
distclean: clean

build-rootfs:
	@echo "image generating..."
	./gen_image.sh
	@mv test.img $(OUTPUT_DIR)/$(DEFAULT_IMAGE)

build: build-rootfs

.PHONY: build-rootfs build
