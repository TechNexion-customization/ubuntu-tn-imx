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
ifeq ($(PLATFORM),pico-imx6)
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

	@echo "image generating..."
	./gen_image.sh $(TARGET)
	@mv test.img $(OUTPUT_DIR)/$(DEFAULT_IMAGE)

build: build-image

.PHONY: build-image build
