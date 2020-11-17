######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

UBOOT_BRANCH := tn-imx_v2020.04_5.4.24_2.1.0-next
UBOOT_COMMIT := `git ls-remote https://github.com/TechNexion/u-boot-tn-imx.git $(UBOOT_BRANCH) | awk '{print $$1}'`
UBOOT_ARCHIVE := https://github.com/TechNexion/u-boot-tn-imx/archive/$(UBOOT_COMMIT).tar.gz

all: build

clean:
	if test -d "$(UBOOT_SRC)/u-boot-tn-imx" ; then $(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx clean ; fi
	rm -f $(UBOOT_BIN)
	rm -rf $(wildcard $(UBOOT_DIR))

distclean: clean
	rm -rf $(wildcard $(UBOOT_DIR/u-boot-tn-imx))

build: src
ifeq ($(PLATFORM),pico-imx8mm)
	$(eval UBOOT_DEFCONFIG := pico-imx8mm_defconfig)
	$(eval ATF_OPTION := imx8mm-pico-pi)
	@sed -i 's/imx8mm-pico-pi.dtb/imx8mm-pico-pi-ili9881c.dtb/' $(UBOOT_DIR)/u-boot-tn-imx/configs/pico-imx8mm_defconfig;
else ifeq ($(PLATFORM),axon-imx8mp)
	$(eval UBOOT_DEFCONFIG := axon-imx8mp_defconfig)
	$(eval ATF_OPTION := imx8mp-axon)
else ifeq ($(PLATFORM),edm-g-imx8mp)
	$(eval UBOOT_DEFCONFIG := edm-g-imx8mp_defconfig)
	$(eval ATF_OPTION := imx8mp-edm-g)
else ifeq ($(PLATFORM),edm-imx8m)
	$(eval UBOOT_DEFCONFIG := edm-imx8mq_defconfig)
	$(eval ATF_OPTION := imx8mq-edm-wizard)

endif

	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx $(UBOOT_DEFCONFIG)
	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx -j$(CPUS) all
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- ./install_uboot_imx8.sh -b $(ATF_OPTION) -d /dev/null > /dev/null; cd -

src:
	mkdir -p $(UBOOT_DIR)
	if [ ! -f $(UBOOT_DIR)/u-boot-tn-imx/Makefile ] ; then \
		curl -L $(UBOOT_ARCHIVE) | tar xz && \
		mv u-boot-tn-imx-* $(UBOOT_DIR)/u-boot-tn-imx ; \
	fi

u-boot: $(UBOOT_BIN)


.PHONY: build
