#!/bin/bash
# ruan Device Tree Setup Script
# Run this after repo sync, before building

ANDROID_ROOT="$(pwd)"
DEVICE_PATH="device/xiaomi/ruan"
KERNEL_HEADERS="device/xiaomi/ruan-kernel/kernel-headers"
GEN="out/soong/.intermediates/vendor/lineage/build/soong/generated_kernel_includes/gen/usr/include"

cd "$ANDROID_ROOT"
echo "=== ruan Setup Script ==="

# Step 1 - Clone missing repos
echo "[1/6] Cloning required repos..."
if [ ! -d "hardware/xiaomi" ]; then
    git clone https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi
fi
if [ ! -d "vendor/xiaomi/ruan" ]; then
    git clone -b vendor https://github.com/nobleactual17/DIZI-device-trees vendor/xiaomi/ruan
fi
if [ ! -d "device/xiaomi/ruan-kernel" ]; then
    git clone -b main https://github.com/noble6/android_vendor_xiaomi_kernel device/xiaomi/ruan-kernel
fi

# Step 2 - Fix libvmmem source
echo "[2/6] Patching libvmmem source..."
cat > hardware/qcom-caf/sm8450/display/libvmmem/VmMem.cpp << 'EOF'
/*
 * Stub implementation - actual implementation provided by prebuilt blob
 */
#include "vmmem.h"
#include <memory>

VmMem::~VmMem() {}

std::unique_ptr<VmMem> VmMem::CreateVmMem() {
    return nullptr;
}
EOF

cat > hardware/qcom-caf/sm8450/display/libvmmem/Android.bp << 'EOF'
cc_library_headers {
    name: "libvmmem_headers",
    vendor: true,
    export_include_dirs: ["."],
}

cc_library_shared {
    name: "libvmmem",
    vendor: true,
    srcs: ["VmMem.cpp"],
    header_libs: ["libvmmem_headers"],
}
EOF

# Step 3 - Inject kernel headers (run after first soong pass generates the GEN dir)
echo "[3/6] Injecting kernel headers..."
mkdir -p "$GEN/linux" "$GEN/misc" "$GEN/sound"

# Linux headers
cp "$KERNEL_HEADERS/linux/msm_audio.h"         "$GEN/linux/" 2>/dev/null
cp "$KERNEL_HEADERS/linux/msm_ion.h"           "$GEN/linux/" 2>/dev/null
cp "$KERNEL_HEADERS/linux/msm_ipa.h"           "$GEN/linux/" 2>/dev/null
cp "$KERNEL_HEADERS/linux/rmnet_ipa_fd_ioctl.h" "$GEN/linux/" 2>/dev/null
cp "$KERNEL_HEADERS/linux/rmnet_data.h"         "$GEN/linux/" 2>/dev/null
cp "$KERNEL_HEADERS/linux/rmnet"*.h             "$GEN/linux/" 2>/dev/null
echo "  Copied linux headers"

# Misc headers
cp "$KERNEL_HEADERS/misc/adsp_sleepmon.h" "$GEN/misc/" 2>/dev/null
echo "  Copied misc headers"

# Sound headers
cp "$KERNEL_HEADERS/sound/"* "$GEN/sound/" 2>/dev/null
echo "  Copied sound headers"

# Step 4 - Remove conflicting kernel headers
echo "[4/6] Removing conflicting kernel headers..."
rm -f "$GEN/linux/types.h"
rm -f "$GEN/linux/swab.h"
rm -f "$GEN/linux/termios.h"
rm -f "$GEN/linux/posix_types.h"
rm -f "$GEN/linux/stddef.h"
rm -f "$GEN/linux/byteorder/little_endian.h"
rm -f "$GEN/linux/byteorder/big_endian.h"

# Step 5 - Create xiaomi_touch.h stub
echo "[5/6] Creating header stubs..."
cat > "$GEN/linux/xiaomi_touch.h" << 'EOF'
/* SPDX-License-Identifier: GPL-2.0-only */
#ifndef _XIAOMI_TOUCH_H
#define _XIAOMI_TOUCH_H
#include <linux/ioctl.h>

#define TOUCH_MAGIC 'T'

enum touch_mode {
    Touch_Game_Mode = 0,
    Touch_Active_MODE = 1,
    Touch_UP_THRESHOLD = 2,
    Touch_Tolerance = 3,
    Touch_Panel_Orientation = 4,
    Touch_Edge_Filter = 5,
    TOUCH_MODE_NONUI_MODE = 6,
    Touch_Mode_NUM = 7,
};

struct touch_mode_request {
    int mode;
    int value;
};

#define TOUCH_IOC_SET_CUR_VALUE     _IO(TOUCH_MAGIC, 0)
#define TOUCH_IOC_GET_CUR_VALUE     _IO(TOUCH_MAGIC, 1)
#define TOUCH_IOC_GET_DEF_VALUE     _IO(TOUCH_MAGIC, 2)
#define TOUCH_IOC_GET_MIN_VALUE     _IO(TOUCH_MAGIC, 3)
#define TOUCH_IOC_GET_MAX_VALUE     _IO(TOUCH_MAGIC, 4)
#define TOUCH_IOC_RESET_MODE        _IO(TOUCH_MAGIC, 5)
#endif
EOF

# Step 6 - Done
echo "[6/6] Setup complete!"
echo ""
echo "=== Setup Complete! ==="
echo "Now run:"
echo "  source build/envsetup.sh"
echo "  breakfast ruan"
echo "  mka bacon"
