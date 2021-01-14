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

build-image:
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
endif

	@echo "image generating..."
	./gen_image.sh $(TARGET)
	@mv test.img $(OUTPUT_DIR)/$(DEFAULT_IMAGE)

build: build-image

.PHONY: build-image build
