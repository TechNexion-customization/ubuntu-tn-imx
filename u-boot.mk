######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

UBOOT_BRANCH := tn-imx_v2020.04_5.4.24_2.1.0-next
UBOOT_COMMIT := `git ls-remote https://github.com/TechNexion/u-boot-tn-imx.git $(UBOOT_BRANCH) | awk '{print $$1}'`
UBOOT_ARCHIVE := https://github.com/TechNexion/u-boot-tn-imx/archive/$(UBOOT_COMMIT).tar.gz
UBOOT_DEFCONFIG := pico-imx8mm_defconfig

all: build

clean:
	if test -d "$(UBOOT_SRC)/u-boot-tn-imx" ; then $(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx clean ; fi
	rm -f $(UBOOT_BIN)
	rm -rf $(wildcard $(UBOOT_DIR))

distclean: clean
	rm -rf $(wildcard $(UBOOT_DIR/u-boot-tn-imx))

build: src
	@sed -i 's/imx8mm-pico-pi.dtb/imx8mm-pico-pi-ili9881c.dtb/' $(UBOOT_DIR)/u-boot-tn-imx/configs/pico-imx8mm_defconfig
	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx $(UBOOT_DEFCONFIG)
	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx -j$(CPUS) all
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ./install_uboot_imx8.sh -b imx8mm-pico-pi -d /dev/null > /dev/null; cd -

src:
	mkdir -p $(UBOOT_DIR)
	if [ ! -f $(UBOOT_DIR)/u-boot-tn-imx/Makefile ] ; then \
		curl -L $(UBOOT_ARCHIVE) | tar xz && \
		mv u-boot-tn-imx-* $(UBOOT_DIR)/u-boot-tn-imx ; \
	fi

u-boot: $(UBOOT_BIN)


.PHONY: build
