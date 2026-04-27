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
if [ ! -d ".repo" ]; then
    repo init -u https://github.com/Halium/android -b halium-11.0 --depth=1
fi

# 2. Setup Local Manifest
echo ">>> Setting up local manifests..."
mkdir -p .repo/local_manifests
cp "$REPO_DIR/halium/local_manifests/roomservice.xml" .repo/local_manifests/

# 3. Sync Sources
echo ">>> Syncing sources (This will take a while)..."
repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags

# 4. Apply our patched device tree & kernel
echo ">>> Applying our patched device tree & kernel..."
# Xóa các thư mục .git để tiết kiệm dung lượng đĩa (rất quan trọng cho CI)
echo ">>> Pruning .git directories to save space..."
find . -name ".git" -type d -prune -exec rm -rf {} +

# Vá lỗi Soong: loại bỏ các biến không xác định của LineageOS
if [ -f "vendor/lineage/build/soong/Android.bp" ]; then
    echo ">>> Patching vendor/lineage/build/soong/Android.bp..."
    sed -i 's/$(PATH_OVERRIDE_SOONG)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_MAKE_CMD)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_MAKE_FLAGS)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(TARGET_KERNEL_SOURCE)/kernel\/samsung\/exynos9820/g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_BUILD_OUT_PREFIX)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(CLANG_TRIPLE)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_ARCH)/arm64/g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_2ND_ARCH)/arm/g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_CROSS_COMPILE)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_CC)//g' vendor/lineage/build/soong/Android.bp
    sed -i 's/$(KERNEL_CLANG_TRIPLE)//g' vendor/lineage/build/soong/Android.bp
fi

# Chúng ta copy SAU KHI sync để đảm bảo không bị repo sync ghi đè
rm -rf device/samsung/d2s
rm -rf kernel/samsung/exynos9820
rm -rf device/samsung/exynos9820-common

cp -r "$REPO_DIR/sources/device/samsung/d2s" device/samsung/d2s
cp -r "$REPO_DIR/sources/device/samsung/exynos9820-common" device/samsung/exynos9820-common
cp -r "$REPO_DIR/sources/kernel/samsung/exynos9820" kernel/samsung/exynos9820

# Sao chép thư mục halium vào workspace để có fstab
cp -r "$REPO_DIR/halium" "$WORKSPACE/"

# 5. Build Halium
echo ">>> Building halium-boot and systemimage..."
export LINEAGE_SKIP_DEVICE_CHECK=true
export SKIP_ROOMSERVICE=true
export LINEAGE_BUILD_OFFLINE=true
# Giới hạn RAM và chống phân mảnh bộ nhớ
export MALLOC_ARENA_MAX=2
export _JAVA_OPTIONS="-Xmx4g"
source build/envsetup.sh

# Sử dụng lunch với sản phẩm cụ thể
lunch halium_d2s-userdebug

# Giới hạn số luồng biên dịch xuống 2 để tránh OOM
mka -j$(nproc) halium-boot systemimage

echo ">>> Build completed successfully! Output is in out/target/product/d2s/"
