# Contributing to HIVE Bootloader

Thank you for your interest in contributing! Here's how you can help.

## How to Contribute

### Reporting Bugs

1. Check if the bug already exists in Issues
2. Create a new issue with:
   - Clear title
   - Steps to reproduce
   - Expected vs actual behavior
   - System information
   - Any error messages

### Suggesting Features

1. Open an issue with tag `enhancement`
2. Describe the feature and use case
3. Explain why it would be useful

### Code Contributions

1. **Fork the repository**
2. **Create a branch**: `git checkout -b feature/my-feature`
3. **Make your changes**
4. **Test thoroughly**: `make test`
5. **Commit**: `git commit -m "Add my feature"`
6. **Push**: `git push origin feature/my-feature`
7. **Create Pull Request**

## Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/hive.git
cd hive

# Install dependencies
sudo apt install nasm make qemu-system-x86

# Build
make

# Test
make test
```

## Coding Standards

### Assembly Code
- Use clear, descriptive labels
- Comment complex sections
- Follow the existing style
- Keep lines under 80 characters where possible
- Use consistent indentation (4 spaces)

### Example:
```asm
; Good
load_sector:
    pusha                   ; Save registers
    mov ah, 0x02           ; BIOS read function
    int 0x13               ; Call BIOS
    popa                   ; Restore registers
    ret

; Bad
load:
mov ah,0x02
int 0x13
ret
```

### Documentation
- Update README.md for user-facing changes
- Update INSTALL.md for installation changes
- Add changelog entry
- Comment your code

## Testing

Before submitting:

```bash
# Clean build
make clean && make

# Test in QEMU
make test

# Test with partitions
make test-full

# Verify sizes
make size
```

## Pull Request Process

1. Update documentation
2. Add tests if applicable
3. Ensure all tests pass
4. Update CHANGELOG.md
5. One feature per PR
6. Reference any related issues

## Code Review

We review:
- Code quality and style
- Documentation
- Testing
- Performance impact
- Security implications

## Community

- Be respectful and inclusive
- Help others learn
- Share knowledge
- Follow our Code of Conduct

## License

By contributing, you agree that your contributions will be licensed under GPL-3.0.

## Questions?

Open an issue or start a discussion on GitHub.

Thank you for contributing to HIVE! 🚀
