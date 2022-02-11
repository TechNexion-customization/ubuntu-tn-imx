OUTPUT_DIR := $(PWD)/output
KERNEL_DIR := $(OUTPUT_DIR)/kernel
UBOOT_DIR := $(OUTPUT_DIR)/u-boot
ARCH := arm
TOOLCHAIN := DEB
CC := arm-linux-gnueabi-
CPUS := $(shell getconf _NPROCESSORS_ONLN)
PLATFORM := pico-imx6
