SHELL = bash -o errexit -o pipefail

export ENABLE_ROOT ?= 1
export ENABLE_READONLY ?= 1
export ENABLE_RELEASE ?= 0
export ENABLE_DEBUG ?= 1
export ENABLE_AUTOUPDATES ?= 0
export ENABLE_SELINUX ?= 0
export ENABLE_RESCUE ?= 0

QEMU_DIR ?= $(abspath qemu)
BUILD_DIR ?= $(abspath build)
BOARDS ?= $(MAKECMDGOALS)
ARTIFACT ?= Fedora-Server-38-1.6.aarch64.raw.xz 

# FIXME: Currently the first target is read; all others are ignored.
BOARD = $(word 1, $(BOARDS))
BOARD_INFO_LIST = $(subst /, ,$(BOARD))
BOARD_INFO_LIST_LEN = $(words $(BOARD_INFO_LIST))

BOARD_NAME = $(lastword $(BOARD_INFO_LIST))

# https://stackoverflow.com/a/53082467
BOARD_CPU_VARIANT := $(word $(BOARD_INFO_LIST_LEN),foo $(BOARD_INFO_LIST))
BOARD_CPU_ARCH := $(word $(BOARD_INFO_LIST_LEN),foo bar $(BOARD_INFO_LIST))

# Determine which qemu exectuable to use
ifeq (v7,$(BOARD_CPU_VARIANT))
    QEMU_PATH ?= $(QEMU_DIR)/qemu-arm-static
else ifeq (v8,$(BOARD_CPU_VARIANT))
    QEMU_PATH ?= $(QEMU_DIR)/qemu-aarch64-static
endif

.PHONY: $(BOARD)
$(BOARD): $(ARTIFACT)
	cd fedora; \
	./main.sh --cpu-arch $(BOARD_CPU_ARCH) --cpu-variant $(BOARD_CPU_VARIANT) --qemu-path $(QEMU_PATH) --extra-env $(abspath $(BOARD)/info) $(abspath $(ARTIFACT)) 

.PHONY: setup-qemu
setup-qemu: $(QEMU_DIR)/bin/qemu-*

.PHONY: setup-binfmt
setup-binfmt: setup-qemu
	cd $(QEMU_DIR); \
	./bin/qemu-binfmt-conf.sh --persistent --qemu-path bin --exportdir lib/binfmt.d

$(QEMU_DIR)/bin/qemu-*:
	cd $(QEMU_DIR); \
	./setup.sh

.PHONY: clean
clean:
	rm -rf build

.PHONY: clean-all
clean-all: clean
	rm -rf $(QEMU_DIR)/bin
