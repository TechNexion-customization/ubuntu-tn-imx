######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

ifeq ($(PLATFORM),pico-imx8mm)
UBOOT_BRANCH := tn-imx_v2020.04_5.4.70_2.3.0-stable
else ifeq ($(PLATFORM),axon-e-imx8mp)
UBOOT_BRANCH := tn-imx_v2020.04_5.4.70_2.3.0-stable
else ifeq ($(PLATFORM),edm-g-imx8mp)
UBOOT_BRANCH := tn-imx_v2020.04_5.4.70_2.3.0-stable
else ifeq ($(PLATFORM),edm-imx8m)
UBOOT_BRANCH := tn-imx_v2020.04_5.4.70_2.3.0-stable
else ifeq ($(PLATFORM),pico-imx8m)
UBOOT_BRANCH := tn-imx_v2020.04_5.4.70_2.3.0-stable
else ifeq ($(PLATFORM),pico-imx6)
UBOOT_BRANCH := tn-imx_v2018.03_4.14.98_2.0.0_ga-stable
else ifeq ($(PLATFORM),edm-imx6)
UBOOT_BRANCH := tn-imx_v2018.03_4.14.98_2.0.0_ga-stable
else ifeq ($(PLATFORM),pico-imx6ull)
UBOOT_BRANCH := tn-imx_v2018.03_4.14.98_2.0.0_ga-stable
else ifeq ($(PLATFORM),pico-imx7d)
UBOOT_BRANCH := tn-imx_v2018.03_4.14.98_2.0.0_ga-stable
endif

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
else ifeq ($(PLATFORM),edm-g-imx8mm)
	$(eval UBOOT_DEFCONFIG := edm-g-imx8mm_defconfig)
	$(eval ATF_OPTION := imx8mm-pico-pi)
	@sed -i 's/imx8mm-edm-g-wb.dtb/imx8mm-edm-g-wb-sn65dsi84-vl10112880.dtb/' $(UBOOT_DIR)/u-boot-tn-imx/configs/edm-g-imx8mm_defconfig;
else ifeq ($(PLATFORM),axon-e-imx8mp)
	$(eval UBOOT_DEFCONFIG := axon-imx8mp_defconfig)
	$(eval ATF_OPTION := imx8mp-axon)
else ifeq ($(PLATFORM),edm-g-imx8mp)
	$(eval UBOOT_DEFCONFIG := edm-g-imx8mp_defconfig)
	$(eval ATF_OPTION := imx8mp-edm-g)
else ifeq ($(PLATFORM),edm-imx8m)
	$(eval UBOOT_DEFCONFIG := edm-imx8mq_defconfig)
	$(eval ATF_OPTION := imx8mq-edm-wizard)
else ifeq ($(PLATFORM),pico-imx8m)
	$(eval UBOOT_DEFCONFIG := pico-imx8mq_defconfig)
	$(eval ATF_OPTION := imx8mq-pico-pi)
else ifeq ($(PLATFORM),pico-imx6)
	$(eval UBOOT_DEFCONFIG := pico-imx6_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),edm-imx6)
	$(eval UBOOT_DEFCONFIG := edm-imx6_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),pico-imx6ull)
	$(eval UBOOT_DEFCONFIG := pico-imx6ul_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),pico-imx7d)
	$(eval UBOOT_DEFCONFIG := pico-imx7d_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
endif

	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx $(UBOOT_DEFCONFIG)
	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx -j$(CPUS) all

ifeq ($(PLATFORM),pico-imx8mm)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),axon-e-imx8mp)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),edm-g-imx8mp)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),edm-imx8m)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),pico-imx8m)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
endif

src:
	mkdir -p $(UBOOT_DIR)
	if [ ! -f $(UBOOT_DIR)/u-boot-tn-imx/Makefile ] ; then \
		curl -L $(UBOOT_ARCHIVE) | tar xz && \
		mv u-boot-tn-imx-* $(UBOOT_DIR)/u-boot-tn-imx ; \
	fi

u-boot: $(UBOOT_BIN)


.PHONY: build
