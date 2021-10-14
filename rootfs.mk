######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

ROOTFS_PACK := rootfs.tgz

all: build

clean:
	rm -rf output/$(ROOTFS_PACK)
distclean: clean

build-rootfs: src

ifeq ($(PLATFORM),pico-imx8mm)
	$(eval TARGET := pico-imx8mm)
else ifeq ($(PLATFORM),edm-g-imx8mm)
	$(eval TARGET := edm-g-imx8mm)
else ifeq ($(PLATFORM),axon-e-imx8mp)
	$(eval TARGET := axon-e-imx8mp)
else ifeq ($(PLATFORM),edm-g-imx8mp)
	$(eval TARGET := edm-g-imx8mp)
else ifeq ($(PLATFORM),edm-imx8m)
	$(eval TARGET := edm-imx8m)
else ifeq ($(PLATFORM),pico-imx8m)
	$(eval TARGET := pico-imx8m)
else ifeq ($(PLATFORM),pico-imx6)
	$(eval TARGET := pico-imx6)
else ifeq ($(PLATFORM),edm-imx6)
	$(eval TARGET := edm-imx6)
else ifeq ($(PLATFORM),pico-imx6ull)
	$(eval TARGET := pico-imx6ull)
else ifeq ($(PLATFORM),pico-imx7d)
	$(eval TARGET := pico-imx7d)
else ifeq ($(PLATFORM),tep1-imx7d)
	$(eval TARGET := tep1-imx7d)
else ifeq ($(PLATFORM),wandboard-imx6)
	$(eval TARGET := wandboard-imx6)
else ifeq ($(PLATFORM),tek3-imx6)
	$(eval TARGET := tek3-imx6)
else ifeq ($(PLATFORM),tep5-imx6)
	$(eval TARGET := tep5-imx6)
else ifeq ($(PLATFORM),tc0700-imx6)
	$(eval TARGET := tc0700-imx6)
else ifeq ($(PLATFORM),tc1010-imx6)
	$(eval TARGET := tc1010-imx6)
endif

	@echo "build rootfs..."
	./gen_rootfs.sh $(TARGET)
	@mv $(ROOTFS_PACK) output/$(ROOTFS_PACK)

build: build-rootfs

src:
	if [ ! -f output ] ; then \
		mkdir -p output; \
	fi

.PHONY: build-rootfs build
