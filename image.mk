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
else ifeq ($(PLATFORM),axon-imx8mp)
	$(eval TARGET := axon-imx8mp)
else ifeq ($(PLATFORM),edm-g-imx8mp)
	$(eval TARGET := edm-g-imx8mp)
else ifeq ($(PLATFORM),edm-imx8m)
	$(eval TARGET := edm-imx8m)
endif

	@echo "image generating..."
	./gen_image.sh $(TARGET)
	@mv test.img $(OUTPUT_DIR)/$(DEFAULT_IMAGE)

build: build-image

.PHONY: build-image build
