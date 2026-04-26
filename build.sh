#!/bin/bash
set -e

echo "======================================"
echo " Ubuntu Touch (d2s) Halium Builder "
echo "======================================"

# Determine workspace (GitHub Actions vs Docker)
if [ -n "$GITHUB_WORKSPACE" ]; then
    WORKSPACE="$GITHUB_WORKSPACE/workspace"
    REPO_DIR="$GITHUB_WORKSPACE"
else
    WORKSPACE="workspace"
    REPO_DIR="."
fi

mkdir -p "$WORKSPACE"
cd "$WORKSPACE"

# 1. Initialize Repo
echo ">>> Initializing Halium 11 Repository..."
repo init -u https://github.com/Halium/android -b halium-11.0 --depth=1

# 2. Setup Local Manifest
echo ">>> Setting up local manifests..."
mkdir -p .repo/local_manifests
cp "$REPO_DIR/halium/local_manifests/roomservice.xml" .repo/local_manifests/
cp -r "$REPO_DIR/halium" "$WORKSPACE/"

# 3. Sync Sources
echo ">>> Syncing sources (This will take a while)..."
repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags

# 4. Copy patched trees
echo ">>> Applying our patched device tree & kernel..."
rm -rf device/samsung/d2s
rm -rf kernel/samsung/exynos9820
rm -rf device/samsung/exynos9820-common

cp -r "$REPO_DIR/sources/device/samsung/d2s" device/samsung/d2s
cp -r "$REPO_DIR/sources/device/samsung/exynos9820-common" device/samsung/exynos9820-common
cp -r "$REPO_DIR/sources/kernel/samsung/exynos9820" kernel/samsung/exynos9820

# 5. Build Halium
echo ">>> Building halium-boot and systemimage..."
export LINEAGE_SKIP_DEVICE_CHECK=true
source build/envsetup.sh
lunch halium_d2s-userdebug
mka halium-boot systemimage

echo ">>> Build completed successfully! Output is in out/target/product/d2s/"
