# HIVE Bootloader - Quick Start Guide

Get up and running with HIVE Bootloader in 5 minutes!

## 📦 What You Get

✅ Automatic OS detection  
✅ Beautiful boot menu  
✅ Multi-boot support  
✅ Windows & Linux compatible  
✅ Tiny footprint (64KB)

## ⚡ Quick Install

### Option 1: Try in Virtual Machine (Safest)

```bash
# 1. Install requirements
sudo apt install nasm make qemu-system-x86

# 2. Build
make

# 3. Test (opens QEMU window)
make test
```

That's it! The bootloader will run in QEMU.

### Option 2: Install to USB Drive

```bash
# 1. Identify your USB drive
lsblk

# 2. Build and install (replace sdX with your USB)
make
sudo make install DEVICE=/dev/sdX

# 3. Reboot and select USB in BIOS
```

## 🎮 Using the Menu

Once booted, you'll see:

```
═══════════════════════════════════════════
        HIVE BOOTLOADER v3.0
═══════════════════════════════════════════

Select OS:
  ▶ Boot: Windows/NTFS
    Boot: Linux
    System Information
    Reboot
    Shutdown

↑↓ Select | Enter Boot | 1-9 Quick | r Reboot
═══════════════════════════════════════════
```

**Controls:**
- `↑` `↓` - Move selection
- `Enter` - Boot selected OS
- `1-9` - Quick select (1 for first, 2 for second, etc.)
- `r` - Reboot immediately

## 🔍 What It Detects

HIVE automatically finds:
- ✅ Windows (FAT32, NTFS)
- ✅ Linux (ext2/3/4)
- ✅ Other bootloaders
- ✅ USB drives
- ✅ Multiple hard drives

## 💡 Tips

**Dual Boot Setup:**
```bash
# Install HIVE to MBR
sudo make install DEVICE=/dev/sda

# It will detect both Windows and Linux
# No config needed!
```

**Rescue USB:**
```bash
# Create bootable rescue USB
sudo make install DEVICE=/dev/sdb

# Boot from it to chainload any OS
```

**Check What's Detected:**
- Boot HIVE
- Press `i` or select "System Information"
- Shows all partitions and hardware

## ⚠️ Important

Before installing on your main drive:

1. **Backup your data!**
2. **Test in QEMU first:** `make test`
3. **Try on USB first** before main drive
4. **Keep a rescue disk** handy

## 🆘 Common Issues

**"No partitions detected"**
- Check you have MBR partitions (not GPT)
- Use `sudo fdisk -l` to verify

**"Disk Error"**
- Reinstall: `sudo make install DEVICE=/dev/sdX`
- Some BIOSes need legacy boot mode enabled

**Can't boot OS**
- Ensure partition has its own bootloader
- For Linux: Install GRUB in the partition
- For Windows: Already has bootloader

## 📚 Learn More

- **Full guide:** [INSTALL.md](INSTALL.md)
- **Documentation:** [README.md](README.md)
- **Contribute:** [CONTRIBUTING.md](CONTRIBUTING.md)

## 🎯 Next Steps

1. ✅ Test in QEMU: `make test`
2. ✅ Install to USB
3. ✅ Boot and verify OS detection
4. ✅ Install to hard drive (if desired)
5. ✅ Star the repo! ⭐

## 💬 Need Help?

- Open an issue on GitHub
- Check the wiki
- Ask in discussions

**Ready to boot!** 🚀
