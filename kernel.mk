######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

KERNEL_BRANCH := tn-imx_5.4.24_2.1.0-next
KERNEL_COMMIT := `git ls-remote https://github.com/TechNexion/linux-tn-imx.git $(KERNEL_BRANCH) | awk '{print $$1}'`
KERNEL_ARCHIVE := https://github.com/TechNexion/linux-tn-imx/archive/$(KERNEL_COMMIT).tar.gz
KERNEL_DEFCONFIG := tn_imx8_defconfig
all: build

clean:
	if test -d "$(KERNEL_SRC)/linux-tn-imx" ; then $(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx clean ; fi
	rm -f $(KERNEL_BIN)
	rm -rf $(wildcard $(KERNEL_DIR))

distclean: clean
	rm -rf $(wildcard $(KERNEL_DIR/linux-tn-imx))

build: src
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx $(KERNEL_DEFCONFIG)
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) all
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) dtbs
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) modules
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) modules_install INSTALL_MOD_PATH=$(KERNEL_DIR)/linux-tn-imx/modules/

src:
	mkdir -p $(KERNEL_DIR)
	if [ ! -f $(KERNEL_DIR)/linux-tn-imx/Makefile ] ; then \
		curl -L $(KERNEL_ARCHIVE) | tar xz && \
		mv linux-tn-imx* $(KERNEL_DIR)/linux-tn-imx ; \
	fi

.PHONY: build
