#!/bin/bash
# HIVE Bootloader - Release Preparation Script

set -e

VERSION="3.0.0"
DATE=$(date +%Y-%m-%d)

echo "========================================="
echo "HIVE Bootloader v${VERSION} - Release"
echo "========================================="
echo ""

# Clean build
echo "→ Cleaning previous builds..."
make clean

# Build fresh
echo "→ Building bootloader..."
make

# Run tests
echo "→ Running verification tests..."

# Check Stage 1 size
STAGE1_SIZE=$(wc -c < build/stage1.bin)
if [ "$STAGE1_SIZE" -ne 512 ]; then
    echo "✗ Error: Stage 1 must be 512 bytes (got $STAGE1_SIZE)"
    exit 1
fi
echo "✓ Stage 1 size: 512 bytes"

# Check boot signature
BOOT_SIG=$(xxd -p -s 510 -l 2 build/stage1.bin)
if [ "$BOOT_SIG" != "55aa" ]; then
    echo "✗ Error: Invalid boot signature"
    exit 1
fi
echo "✓ Boot signature: 0x55AA"

# Check Stage 2 exists
if [ ! -f build/stage2.bin ]; then
    echo "✗ Error: Stage 2 not found"
    exit 1
fi
STAGE2_SIZE=$(wc -c < build/stage2.bin)
echo "✓ Stage 2 size: $STAGE2_SIZE bytes"

# Create release directory
RELEASE_DIR="hive-bootloader-v${VERSION}"
echo ""
echo "→ Creating release package..."
mkdir -p "releases/${RELEASE_DIR}"

# Copy files
cp build/hive.img "releases/${RELEASE_DIR}/"
cp build/stage1.bin "releases/${RELEASE_DIR}/"
cp build/stage2.bin "releases/${RELEASE_DIR}/"
cp README.md "releases/${RELEASE_DIR}/"
cp INSTALL.md "releases/${RELEASE_DIR}/"
cp QUICKSTART.md "releases/${RELEASE_DIR}/"
cp LICENSE "releases/${RELEASE_DIR}/"
cp CHANGELOG.md "releases/${RELEASE_DIR}/"

# Create checksums
cd "releases/${RELEASE_DIR}"
sha256sum *.img *.bin > SHA256SUMS
cd ../..

# Create tarball
echo "→ Creating archive..."
cd releases
tar czf "${RELEASE_DIR}.tar.gz" "${RELEASE_DIR}"
zip -r "${RELEASE_DIR}.zip" "${RELEASE_DIR}" > /dev/null 2>&1
cd ..

# Show results
echo ""
echo "========================================="
echo "Release v${VERSION} ready!"
echo "========================================="
echo ""
echo "Files created:"
ls -lh "releases/${RELEASE_DIR}.tar.gz"
ls -lh "releases/${RELEASE_DIR}.zip"
echo ""
echo "Release notes:"
echo "- Bootloader image: hive.img (2MB)"
echo "- Stage 1 (MBR): 512 bytes"
echo "- Stage 2 (Main): $STAGE2_SIZE bytes"
echo ""
echo "Next steps:"
echo "1. Test the release: make test"
echo "2. Update GitHub release page"
echo "3. Upload files from releases/ directory"
echo "4. Announce on social media"
echo ""
echo "✓ Release preparation complete!"
