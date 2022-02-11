######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

UBOOT_COMMIT := 510b22fcbf369f6ac08c349981333f7cf6f2a9cc
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
else ifeq ($(PLATFORM),edm-g-imx8mm)
	$(eval UBOOT_DEFCONFIG := edm-g-imx8mm_defconfig)
	$(eval ATF_OPTION := imx8mm-edm-g-wb)
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
else ifeq ($(PLATFORM),tep1-imx7d)
	$(eval UBOOT_DEFCONFIG := tep1-imx7d_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),wandboard-imx6)
	$(eval UBOOT_DEFCONFIG := wandboard_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tek3-imx6)
	$(eval UBOOT_DEFCONFIG := tek-imx6_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tep5-imx6)
	$(eval UBOOT_DEFCONFIG := tek-imx6_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tc0700-imx6)
	$(eval UBOOT_DEFCONFIG := edm-imx6_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tc1010-imx6)
	$(eval UBOOT_DEFCONFIG := edm-imx6_spl_defconfig)
	$(eval ARCH := arm)
	$(eval CC := arm-linux-gnueabi-)
endif

	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx $(UBOOT_DEFCONFIG)
	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/u-boot-tn-imx -j$(CPUS) all

ifeq ($(PLATFORM),pico-imx8mm)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b imx8mm-pico-pi.dtb -b imx8mm-pico-wizard.dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),axon-e-imx8mp)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),edm-g-imx8mp)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),edm-g-imx8mm)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),edm-imx8m)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -
else ifeq ($(PLATFORM),pico-imx8m)
	cd $(UBOOT_DIR)/u-boot-tn-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b imx8mq-pico-pi.dtb -b imx8mq-pico-wizard.dtb -d /dev/null > /dev/null; cd -
endif

src:
	mkdir -p $(UBOOT_DIR)
	if [ ! -f $(UBOOT_DIR)/u-boot-tn-imx/Makefile ] ; then \
		curl -L $(UBOOT_ARCHIVE) | tar xz && \
		mv u-boot-tn-imx-* $(UBOOT_DIR)/u-boot-tn-imx ; \
	fi

u-boot: $(UBOOT_BIN)


.PHONY: build
