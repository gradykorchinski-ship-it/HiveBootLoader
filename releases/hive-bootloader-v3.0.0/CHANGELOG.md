# Changelog

All notable changes to HIVE Bootloader will be documented in this file.

## [3.0.0] - 2026-01-14

### Added
- Complete rewrite of bootloader architecture
- Automatic partition detection for MBR disks
- Support for FAT12, FAT16, FAT32, NTFS, Linux (ext2/3/4)
- Beautiful GRUB-style UI with keyboard navigation
- Chainloading support for Windows and Linux
- System information display (CPU, RAM, disks)
- LBA disk access with CHS fallback
- Keyboard shortcuts for quick boot (1-9 keys)
- APM shutdown support
- GPL-3.0 licensing
- Comprehensive documentation
- Build system with Make
- QEMU testing support
- USB installation script

### Technical
- Stage 1: 512 bytes (MBR compliant)
- Stage 2: 64KB (main bootloader)
- Total size: ~66KB
- Written in x86 assembly (NASM)
- Real mode operation
- BIOS interrupt driven

### Known Limitations
- MBR only (no GPT support yet)
- No UEFI support
- No direct kernel loading (chainload only)
- No filesystem reading
- No configuration file
- English only

## [2.0.0] - 2024-12-01

### Added
- Initial public release
- Basic multi-boot menu
- Partition table detection
- Simple UI

## [1.0.0] - 2024-06-15

### Added
- Initial development version
- Basic boot sector functionality
