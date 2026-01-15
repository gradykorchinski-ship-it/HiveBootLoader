# HIVE Bootloader - Installation Guide

## Table of Contents
1. [Before You Begin](#before-you-begin)
2. [Installation Methods](#installation-methods)
3. [Testing](#testing)
4. [Troubleshooting](#troubleshooting)
5. [Uninstallation](#uninstallation)

---

## Before You Begin

### ⚠️ Important Warnings

- **Backup your data!** Installing a bootloader modifies your disk's MBR
- **Test in a VM first** using `make test` before installing on real hardware
- **Know your device names** - Installing to the wrong device can render your system unbootable
- **Have a recovery method** - Keep a USB recovery disk handy

### Check Your System

```bash
# List all disks
lsblk

# Check current bootloader (if any)
sudo dd if=/dev/sda bs=512 count=1 | hexdump -C | head

# Verify partitions
sudo fdisk -l
```

---

## Installation Methods

### Method 1: USB Drive (Recommended for Testing)

This is the safest method for testing HIVE Bootloader.

```bash
# 1. Identify your USB drive
lsblk

# 2. Unmount if mounted
sudo umount /dev/sdX*

# 3. Build HIVE
make clean && make

# 4. Install to USB
sudo make install DEVICE=/dev/sdX

# 5. Test boot from USB
# Reboot and select USB drive in BIOS
```

**Example:**
```bash
sudo make install DEVICE=/dev/sdb
```

### Method 2: Hard Drive Installation

**⚠️ WARNING: This modifies your system drive!**

```bash
# Build
make clean && make

# Install to primary hard drive
sudo make install DEVICE=/dev/sda

# Reboot
sudo reboot
```

### Method 3: Manual Installation

If you need more control:

```bash
# Build components
make clean && make

# Install Stage 1 (MBR) - preserves partition table
sudo dd if=build/stage1.bin of=/dev/sdX bs=446 count=1 conv=notrunc

# Install Stage 2 starting at sector 1
sudo dd if=build/stage2.bin of=/dev/sdX bs=512 seek=1 count=128 conv=notrunc

# Sync to disk
sudo sync
```

### Method 4: Dual Boot Setup

To use HIVE alongside existing bootloaders:

```bash
# Install HIVE to MBR
sudo make install DEVICE=/dev/sda

# HIVE will detect your existing OS partitions
# It can chainload to GRUB or Windows bootloader
```

---

## Testing

### Test in QEMU (No Installation)

```bash
# Basic test
make test

# Test with partitions
make test-full

# Debug mode
make debug
```

### Test on Real Hardware

1. Create a bootable USB:
   ```bash
   sudo make install DEVICE=/dev/sdX
   ```

2. Reboot computer

3. Enter BIOS (usually F2, F12, Del, or Esc)

4. Select USB drive from boot menu

5. HIVE should load and display menu

---

## Verification

After installation, verify:

```bash
# Check MBR signature
sudo dd if=/dev/sdX bs=512 count=1 | hexdump -C | grep "55 aa"

# Should show: "000001f0  ... 55 aa"

# Check Stage 1 size
sudo dd if=/dev/sdX bs=512 count=1 2>/dev/null | wc -c
# Should output: 512

# View first few sectors
sudo dd if=/dev/sdX bs=512 count=10 | hexdump -C | head -n 40
```

---

## Configuration

HIVE automatically detects bootable partitions. No configuration needed!

### Customization (Future)

Configuration file support planned for v3.1:

```
# /boot/hive/hive.cfg (planned)
timeout=5
default=0

menuentry "My Linux" {
    root=(hd0,1)
    chainload +1
}
```

---

## Troubleshooting

### Problem: "Disk Error" on Boot

**Causes:**
- Stage 2 not properly written
- Disk read error
- Incompatible BIOS

**Solutions:**
```bash
# Reinstall with verification
sudo make install DEVICE=/dev/sdX

# Try legacy CHS mode (automatic in HIVE)

# Check disk health
sudo smartctl -a /dev/sdX
```

### Problem: No Partitions Detected

**Causes:**
- GPT partition table (not supported yet)
- Corrupted partition table
- Extended partitions

**Solutions:**
```bash
# Check partition table type
sudo fdisk -l /dev/sdX | grep "Disklabel"

# Convert GPT to MBR (CAUTION: destroys data!)
# sudo gdisk /dev/sdX
# r (recovery menu)
# g (convert GPT to MBR)

# Verify partition table
sudo sfdisk -l /dev/sdX
```

### Problem: Can't Boot Existing OS

**Causes:**
- Partition bootloader missing
- Incorrect partition type
- Boot flag not set

**Solutions:**
```bash
# Set boot flag on partition
sudo fdisk /dev/sdX
# a (toggle bootable flag)
# 1 (partition number)
# w (write)

# Reinstall GRUB on Linux partition
sudo grub-install --boot-directory=/mnt/boot /dev/sdX1

# For Windows, use Windows recovery
```

### Problem: System Won't Boot at All

**Recovery:**

```bash
# Boot from rescue USB/CD

# Restore old MBR (if backed up)
sudo dd if=mbr_backup.bin of=/dev/sdX bs=512 count=1

# Or install GRUB
sudo grub-install /dev/sdX
sudo update-grub

# Or install Windows bootloader
# Use Windows recovery disk and run:
# bootrec /fixmbr
# bootrec /fixboot
```

---

## Uninstallation

### Replace with GRUB

```bash
# Install GRUB over HIVE
sudo grub-install /dev/sdX
sudo update-grub
```

### Replace with Windows Bootloader

Use Windows recovery:
```cmd
bootrec /fixmbr
bootrec /fixboot
bootrec /rebuildbcd
```

### Restore Original MBR

If you made a backup:
```bash
sudo dd if=mbr_backup.bin of=/dev/sdX bs=512 count=1
```

---

## Backup and Recovery

### Backup MBR Before Installation

```bash
# Backup first 512 bytes (MBR)
sudo dd if=/dev/sdX of=mbr_backup.bin bs=512 count=1

# Backup first 1MB (MBR + bootloader area)
sudo dd if=/dev/sdX of=full_backup.bin bs=1M count=1

# Store safely!
cp mbr_backup.bin ~/Documents/
```

### Restore from Backup

```bash
# Restore MBR
sudo dd if=mbr_backup.bin of=/dev/sdX bs=512 count=1

# Sync
sudo sync

# Reboot
sudo reboot
```

---

## Advanced Topics

### Chainloading

HIVE can chainload other bootloaders:

- **Windows**: Automatically detected and bootable
- **GRUB**: Install GRUB in Linux partition, HIVE can boot it
- **Other OS**: Any partition with valid boot sector

### Multi-Disk Setup

```bash
# Install HIVE on disk 1
sudo make install DEVICE=/dev/sda

# It will detect partitions on all disks
# Select boot device in BIOS as needed
```

### Custom Partition Detection

Currently automatic. Future versions will support:
- Custom partition labels
- Hidden partitions
- Encrypted partitions

---

## Support

- **GitHub Issues**: Report bugs and request features
- **Documentation**: Check the wiki
- **Community**: Join discussions

---

## Next Steps

After installation:

1. ✅ Reboot and test
2. ✅ Verify all OS partitions detected
3. ✅ Test booting each OS
4. ✅ Create rescue USB
5. ✅ Configure boot order in BIOS

---

**Remember: Always have a backup and recovery plan!**
