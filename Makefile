# ============================================================================
# HIVE BOOTLOADER v3.0 - Build System
# ============================================================================
# Copyright (c) 2024-2026 HIVE Project
# Licensed under GNU General Public License v3.0
# ============================================================================

.PHONY: all clean install test help

# Tools
NASM := nasm
QEMU := qemu-system-x86_64
DD := dd
CAT := cat
TRUNCATE := truncate

# Source files
SRC_DIR := src
STAGE1_SRC := $(SRC_DIR)/stage1.asm
STAGE2_SRC := $(SRC_DIR)/stage2.asm

# Output files
BUILD_DIR := build
STAGE1_BIN := $(BUILD_DIR)/stage1.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
BOOTLOADER_IMG := $(BUILD_DIR)/hive.img
TEST_DISK := $(BUILD_DIR)/test.img

# NASM flags
NASMFLAGS := -f bin

# Default target
all: $(BOOTLOADER_IMG)
	@echo "========================================="
	@echo "HIVE Bootloader v3.0 built successfully!"
	@echo "========================================="
	@ls -lh $(BOOTLOADER_IMG)
	@echo ""
	@echo "To test: make test"
	@echo "To install to USB: sudo make install DEVICE=/dev/sdX"

# Create build directory
$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

# Build Stage 1
$(STAGE1_BIN): $(STAGE1_SRC) | $(BUILD_DIR)
	@echo "Building Stage 1 (MBR)..."
	$(NASM) $(NASMFLAGS) $< -o $@
	@echo "Stage 1: $$(wc -c < $@) bytes (must be 512)"

# Build Stage 2
$(STAGE2_BIN): $(STAGE2_SRC) | $(BUILD_DIR)
	@echo "Building Stage 2 (Main)..."
	$(NASM) $(NASMFLAGS) $< -o $@
	@echo "Stage 2: $$(wc -c < $@) bytes"

# Create bootable image
$(BOOTLOADER_IMG): $(STAGE1_BIN) $(STAGE2_BIN)
	@echo "Creating bootable image..."
	$(CAT) $(STAGE1_BIN) $(STAGE2_BIN) > $@
	$(TRUNCATE) -s 2M $@
	@echo "Bootloader image created: $@"

# Create test disk with partitions
$(TEST_DISK): $(BOOTLOADER_IMG)
	@echo "Creating test disk with partitions..."
	$(DD) if=/dev/zero of=$@ bs=1M count=256 2>/dev/null
	# Write bootloader
	$(DD) if=$(BOOTLOADER_IMG) of=$@ conv=notrunc 2>/dev/null
	# Create partition table with sfdisk
	@echo "Creating partition table..."
	@(echo "label: dos"; \
	 echo "start=2048, size=102400, type=83, bootable"; \
	 echo "start=104448, size=102400, type=7") | sfdisk $@ 2>/dev/null || true
	# Reinstall bootloader preserving partition table
	$(DD) if=$(STAGE1_BIN) of=$@ bs=446 count=1 conv=notrunc 2>/dev/null
	$(DD) if=$(STAGE2_BIN) of=$@ bs=512 seek=1 conv=notrunc 2>/dev/null
	@echo "Test disk created with 2 partitions"

# Test in QEMU
test: $(BOOTLOADER_IMG)
	@echo "Launching HIVE Bootloader in QEMU..."
	@echo "Press Ctrl+Alt+G to release mouse, Ctrl+Alt+Q to quit"
	$(QEMU) -drive format=raw,file=$(BOOTLOADER_IMG) -m 256M

# Test with partition disk
test-full: $(TEST_DISK)
	@echo "Launching HIVE Bootloader with test partitions..."
	$(QEMU) -drive format=raw,file=$(TEST_DISK) -m 256M

# Test with debug output
debug: $(BOOTLOADER_IMG)
	$(QEMU) -drive format=raw,file=$(BOOTLOADER_IMG) -m 256M -d int -no-reboot

# Install to USB drive (DANGEROUS - use with caution!)
install: $(BOOTLOADER_IMG)
ifndef DEVICE
	@echo "ERROR: DEVICE not specified"
	@echo "Usage: sudo make install DEVICE=/dev/sdX"
	@echo ""
	@echo "WARNING: This will overwrite the bootloader on $(DEVICE)"
	@echo "         All data on the device may be lost!"
	@exit 1
endif
	@echo "========================================="
	@echo "WARNING: Installing to $(DEVICE)"
	@echo "This will overwrite the MBR!"
	@echo "Press Ctrl+C to cancel, Enter to continue"
	@echo "========================================="
	@read -r dummy
	@echo "Installing HIVE Bootloader to $(DEVICE)..."
	$(DD) if=$(STAGE1_BIN) of=$(DEVICE) bs=446 count=1 conv=notrunc status=progress
	$(DD) if=$(STAGE2_BIN) of=$(DEVICE) bs=512 seek=1 count=128 conv=notrunc status=progress
	@sync
	@echo "Installation complete!"
	@echo "The partition table on $(DEVICE) has been preserved."

# Clean build files
clean:
	@echo "Cleaning build files..."
	rm -rf $(BUILD_DIR)
	@echo "Clean complete"

# Show sizes
size: $(STAGE1_BIN) $(STAGE2_BIN)
	@echo "Component sizes:"
	@echo "  Stage 1 (MBR):  $$(wc -c < $(STAGE1_BIN)) bytes (max 512)"
	@echo "  Stage 2 (Main): $$(wc -c < $(STAGE2_BIN)) bytes"
	@echo "  Total:          $$(stat -c%s $(BOOTLOADER_IMG)) bytes"

# Hexdump bootloader for debugging
hexdump: $(BOOTLOADER_IMG)
	hexdump -C $(BOOTLOADER_IMG) | head -n 50

# Disassemble for debugging  
disasm: $(STAGE1_BIN)
	ndisasm -b 16 -o 0x7C00 $(STAGE1_BIN)

# Help
help:
	@echo "HIVE Bootloader v3.0 - Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make              - Build bootloader"
	@echo "  make test         - Test in QEMU"
	@echo "  make test-full    - Test with partitions"
	@echo "  make debug        - Test with debug output"
	@echo "  make install      - Install to USB (needs DEVICE=)"
	@echo "  make clean        - Remove build files"
	@echo "  make size         - Show component sizes"
	@echo "  make hexdump      - Show hex dump"
	@echo "  make disasm       - Disassemble Stage 1"
	@echo "  make help         - Show this help"
	@echo ""
	@echo "Examples:"
	@echo "  make test"
	@echo "  sudo make install DEVICE=/dev/sdb"
	@echo ""
	@echo "Requirements:"
	@echo "  - nasm (assembler)"
	@echo "  - qemu-system-x86_64 (for testing)"
	@echo "  - sfdisk (for partition creation)"
