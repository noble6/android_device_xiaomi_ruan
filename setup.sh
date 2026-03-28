#!/bin/bash
# Run this once after repo sync, from ~/android/lineage/
set -e
echo "==> Setting up dizi build environment..."

# libvmmem
echo "==> Copying libvmmem..."
cp vendor/xiaomi/dizi/proprietary/vendor/lib64/libvmmem.so \
    hardware/qcom-caf/sm8450/display/libvmmem/libvmmem.so
cp vendor/xiaomi/dizi/proprietary/vendor/lib/libvmmem.so \
    hardware/qcom-caf/sm8450/display/libvmmem/libvmmem32.so

# dizi_GKI.config
echo "==> Creating dizi_GKI.config..."
cp kernel/xiaomi/sm7435/arch/arm64/configs/vendor/garnet_GKI.config \
    kernel/xiaomi/sm7435/arch/arm64/configs/vendor/dizi_GKI.config

# dtbo prebuilt
echo "==> Staging dtbo prebuilt..."
mkdir -p out/dtbo_prebuilt
cp device/xiaomi/dizi/dtbo/dtbo.img out/dtbo_prebuilt/dtbo.img

echo ""
echo "==> All done! Now run:"
echo "    source build/envsetup.sh && breakfast dizi && mka bacon"
