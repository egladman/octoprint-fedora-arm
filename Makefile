SHELL = bash -o errexit -o pipefail

QEMU_DIR ?= $(abspath qemu)
BUILD_DIR ?= $(abspath build)
BOARDS ?= $(MAKECMDGOALS)
ARTIFACT ?= Fedora-Server-38-1.6.aarch64.raw.xz 

# FIXME: Currently the first target is read; all others are ignored.
BOARD = $(word 1, $(BOARDS))
BOARD_INFO = $(subst /, ,$(BOARD))
BOARD_NAME = $(lastword $(BOARD_INFO))

# Determine which qemu exectuable to use
ifneq ($(findstring v7,$(BOARD_INFO)),)
    QEMU ?= $(QEMU_DIR)/qemu-arm-static
else ifneq ($(findstring v8,$(BOARD_INFO)),)
    QEMU ?= $(QEMU_DIR)/qemu-aarch64-static
else ifeq ($(QEMU)$(BOARD),)
    $(error Could not determine qemu executable. Manually set variable: QEMU)
endif

.PHONY: $(BOARD)
$(BOARD): $(ARTIFACT)
	cd fedora; \
	./main.sh --extra-vars $(abspath $(BOARD)/info) $(abspath $(ARTIFACT)) 

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
	rm -rf $(QEMU_DIR)/bin fedora/rootfs
