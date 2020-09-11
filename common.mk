OUTPUT_DIR := $(PWD)/output
KERNEL_DIR := $(OUTPUT_DIR)/kernel
UBOOT_DIR := $(OUTPUT_DIR)/u-boot
ARCH := arm64
TOOLCHAIN := DEB
CC := aarch64-linux-gnu-
CPUS := $(shell getconf _NPROCESSORS_ONLN)
