# HIVE Bootloader v3.0

**A modern, GRUB-like bootloader with OS detection, chainloading, and a beautiful UI**

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![Version](https://img.shields.io/badge/version-3.0-green.svg)
![Platform](https://img.shields.io/badge/platform-x86__64%20%7C%20x86-lightgrey.svg)

---

## 🚀 Features

- **🔍 Automatic OS Detection** - Scans and displays all bootable partitions
- **� GPT & MBR Support** - Works with modern GPT and legacy MBR partition tables
- **�🖥️ Beautiful UI** - GRUB-style menu with keyboard navigation
- **⚡ Fast Boot** - Optimized disk I/O with LBA support
- **🔄 Chainloading** - Boot Windows, Linux, and other operating systems
- **💾 Multi-Partition Support** - Handles FAT12/16/32, NTFS, ext2/3/4, and more
- **🔧 System Tools** - Built-in system information and diagnostics
- **📦 Tiny Size** - Less than 64KB total
- **🛠️ Easy Installation** - Simple USB/disk installation

---

## 📋 Requirements

### Build Requirements
- **nasm** - Netwide Assembler
- **make** - GNU Make
- **qemu-system-x86_64** - For testing (optional)

### Installation
```bash
# Ubuntu/Debian
sudo apt install nasm make qemu-system-x86

# Fedora/RHEL
sudo dnf install nasm make qemu-system-x86

# Arch Linux
sudo pacman -S nasm make qemu-system-x86
```

---

## 🔨 Building

```bash
# Clone the repository
git clone https://github.com/hive-bootloader/hive.git
cd hive

# Build the bootloader
make

# Test in QEMU (no installation needed)
make test
```

---

## 📥 Installation

### Method 1: USB Drive (Recommended)

```bash
# WARNING: This will modify the MBR of your USB drive!
# Replace /dev/sdX with your USB device (e.g., /dev/sdb)

# Build first
make

# Install (requires sudo)
sudo make install DEVICE=/dev/sdX
```

### Method 2: Hard Drive (Advanced)

```bash
# WARNING: This installs to your system drive's MBR!
# Only do this if you know what you're doing

sudo make install DEVICE=/dev/sda
```

### Method 3: Virtual Machine

```bash
# Create a virtual disk
make test-full

# Use build/test.img with your VM software
# (VirtualBox, VMware, etc.)
```

---

## 🎮 Usage

### Boot Menu Controls

| Key | Action |
|-----|--------|
| ↑↓ | Navigate menu |
| Enter | Boot selected OS |
| 1-9 | Quick select |
| r | Reboot |
| Esc | Refresh |

### Menu Options

1. **Detected OS Partitions** - Automatically found bootable systems
2. **System Information** - View CPU, memory, and disk info
3. **Reboot** - Restart the computer
4. **Shutdown** - Power off (APM)

---

## 🧪 Testing

```bash
# Test basic bootloader
make test

# Test with partitions
make test-full

# Test with debug output
make debug

# Show component sizes
make size
```

---

## 📁 Project Structure

```
hive/
├── src/
│   ├── stage1.asm      # MBR boot sector (512 bytes)
│   └── stage2.asm      # Main bootloader (64KB)
├── build/              # Build output (generated)
├── Makefile            # Build system
├── README.md           # This file
├── LICENSE             # GPL-3.0 License
└── INSTALL.md          # Detailed installation guide
```

---

## 🔧 How It Works

### Stage 1 (MBR - 512 bytes)
- Loaded by BIOS at 0x7C00
- Preserves partition table
- Loads Stage 2 from disk
- Supports both LBA and CHS disk access

### Stage 2 (Main - ~64KB)
- Scans MBR partition table
- Detects bootable partitions
- Displays interactive menu
- Chainloads selected OS
- Provides system information

---

## 🆚 Comparison with GRUB

| Feature | HIVE | GRUB2 |
|---------|------|-------|
| Size | 64KB | 1-2MB |
| Boot Speed | Very Fast | Fast |
| Partition Detection | ✅ | ✅ |
| Chainloading | ✅ | ✅ |
| Linux Kernel Boot | ⚠️ Via chainload | ✅ Direct |
| UEFI Support | ❌ | ✅ |
| Config File | ❌ | ✅ |
| Filesystem Read | ❌ | ✅ |
| Memory Footprint | Tiny | Large |

**Best for:** Dual-boot systems, USB rescue disks, embedded systems, minimal installations

---

## 🐛 Troubleshooting

### "Disk Error" on boot
- Check that Stage 2 is properly written after Stage 1
- Verify disk is readable (try in QEMU first)
- Some BIOSes require CHS addressing - this is automatic

### Partition not detected
- Currently supports MBR partition tables only (no GPT)
- Partition must have a valid type byte
- Extended partitions may not be detected

### Can't boot into OS
- Ensure the partition has a valid boot sector
- Windows partitions need their own bootloader installed
- Linux partitions need GRUB installed in the partition

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly (especially with `make test`)
5. Submit a pull request

### Development Setup

```bash
# Install development tools
sudo apt install nasm make qemu-system-x86 gdb

# Build and test
make clean && make test

# Debug
make debug
```

---

## 📜 License

Copyright (c) 2024-2026 HIVE Project

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

See [LICENSE](LICENSE) for details.

---

## ⚠️ Disclaimer

**Use at your own risk!** Installing a bootloader can potentially make your system unbootable if done incorrectly. Always:

- Backup important data before installation
- Test in a virtual machine first
- Keep a recovery USB handy
- Understand what you're doing

The authors are not responsible for any data loss or system damage.

---

## 🙏 Acknowledgments

- Inspired by GRUB, LILO, and Syslinux
- Built with NASM assembler
- Thanks to the OSDev community

---

## 📞 Support

- **Issues**: https://github.com/hive-bootloader/hive/issues
- **Discussions**: https://github.com/hive-bootloader/hive/discussions
- **Wiki**: https://github.com/hive-bootloader/hive/wiki

---

## 🗺️ Roadmap

- [ ] GPT partition table support
- [ ] Direct Linux kernel loading
- [ ] Config file support (hive.cfg)
- [ ] Filesystem reading (FAT, ext2/3/4)
- [ ] UEFI support
- [ ] Network boot (PXE)
- [ ] Graphical theme support

---

**Made with ❤️ by the HIVE Project**
# HiveBootLoader
# HiveBootLoader
