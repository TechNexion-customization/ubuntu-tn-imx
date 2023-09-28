######################################################################
#         2020 Technexion Ltd. Ubuntu Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <wig.cheng@technexion.com>                  #
######################################################################

include common.mk

# tag: tn-kirkstone_5.15.71-2.2.0_20230512
KERNEL_COMMIT  := 7c37b47490ee2f927fb90664d914f19887bbee58
KERNEL_ARCHIVE := https://github.com/TechNexion/linux-tn-imx/archive/$(KERNEL_COMMIT).tar.gz

ifeq ($(PLATFORM),pico-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),edm-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),pico-imx6ull)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),pico-imx7d)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tep1-imx7d)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),wandboard-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tek3-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tep5-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tc0700-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)
else ifeq ($(PLATFORM),tc1010-imx6)
KERNEL_DEFCONFIG := tn_imx_defconfig
$(eval ARCH := arm)
$(eval CC := arm-linux-gnueabi-)

endif

QCACLD_BRANCH := tn-CNSS.LEA.NRT_3.1
QCACLD_COMMIT := `git ls-remote https://github.com/TechNexion/qcacld-2.0.git $(QCACLD_BRANCH) | awk '{print $$1}'`
QCACLD_ARCHIVE := https://github.com/TechNexion/qcacld-2.0/archive/$(QCACLD_COMMIT).tar.gz

all: build

clean:
	if test -d "$(KERNEL_SRC)/linux-tn-imx" ; then $(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx clean ; fi
	rm -f $(KERNEL_BIN)
	rm -rf $(wildcard $(KERNEL_DIR))

distclean: clean
	rm -rf $(wildcard $(KERNEL_DIR/linux-tn-imx))

build: src
	echo CONFIG_DRM_LEGACY=y >> $(KERNEL_DIR)/linux-tn-imx/arch/arm/configs/$(KERNEL_DEFCONFIG)
	echo CONFIG_DRM_VIVANTE=y >> $(KERNEL_DIR)/linux-tn-imx/arch/arm/configs/$(KERNEL_DEFCONFIG)
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx $(KERNEL_DEFCONFIG)
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) all
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) dtbs
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) imx6qp-edm1-fairy-qca.dtb
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) modules
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/linux-tn-imx -j$(CPUS) modules_install INSTALL_MOD_PATH=$(KERNEL_DIR)/linux-tn-imx/modules/
	cd $(KERNEL_DIR)/qcacld-2.0; \
	KERNEL_SRC=$(KERNEL_DIR)/linux-tn-imx CONFIG_CLD_HL_SDIO_CORE=y CONFIG_PER_VDEV_TX_DESC_POOL=1 SAP_AUTH_OFFLOAD=1 \
	CONFIG_QCA_LL_TX_FLOW_CT=1 CONFIG_WLAN_FEATURE_FILS=y CONFIG_FEATURE_COEX_PTA_CONFIG_ENABLE=y \
	CONFIG_QCA_SUPPORT_TXRX_DRIVER_TCP_DEL_ACK=y CONFIG_WLAN_WAPI_MODE_11AC_DISABLE=y TARGET_BUILD_VARIANT=user \
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/qcacld-2.0 -j$(CPUS)
	KERNEL_SRC=$(KERNEL_DIR)/linux-tn-imx INSTALL_MOD_PATH=$(KERNEL_DIR)/linux-tn-imx/modules/ $(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/qcacld-2.0 -j$(CPUS) modules_install

src:
	mkdir -p $(KERNEL_DIR)
	if [ ! -f $(KERNEL_DIR)/linux-tn-imx/Makefile ] ; then \
		curl -L $(KERNEL_ARCHIVE) | tar xz && \
		mv linux-tn-imx* $(KERNEL_DIR)/linux-tn-imx ; \
		curl -L $(QCACLD_ARCHIVE) | tar xz && \
		mv qcacld-2.0* $(KERNEL_DIR)/qcacld-2.0 ; \
	fi

.PHONY: build
