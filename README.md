# LineageOS 23.0 Device Tree — Xiaomi Redmi Pad Pro / POCO Pad (dizi)

> **Status:** Work in Progress — Unofficial

---

## Device Info

| Property | Value |
|---|---|
| Device | Xiaomi Redmi Pad Pro / POCO Pad |
| Codename | `dizi` (WiFi) / `ruan` (5G) |
| SoC | Snapdragon 7s Gen 2 (SM7435P / Parrot) |
| Architecture | ARM64 |
| Display | 12.1" 1600×2560 @ 120Hz |
| RAM | 6GB / 8GB / 12GB |
| Storage | 128GB / 256GB / 512GB (UFS) |
| Battery | 10000 mAh |
| Charging | 33W wired |
| Cameras | 8MP front, 8MP rear (OV08D10), 13MP (OV13B10) |
| WiFi | WCN6750 (QCA6750) |
| Bluetooth | 5.3 |
| NFC | No |
| Fingerprint | No |

---

## Branches

| Branch | Purpose |
|---|---|
| `lineage-23.0` | Device tree |
| `vendor` | Vendor blobs (PRODUCT_COPY_FILES) |

---

## Dependencies

Add this to `.repo/local_manifests/dizi.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="nobleactual17/DIZI-device-trees" path="device/xiaomi/dizi" remote="github" revision="lineage-23.0" />
  <project name="nobleactual17/DIZI-device-trees" path="vendor/xiaomi/dizi" remote="github" revision="vendor" />
  <project name="garnet-random/android_kernel_xiaomi_sm7435" path="kernel/xiaomi/sm7435" remote="github" revision="lineage-23.0" />
  <project name="garnet-random/android_kernel_xiaomi_sm7435-devicetrees" path="kernel/xiaomi/sm7435-devicetrees" remote="github" revision="lineage-23.0" />
  <project name="garnet-random/android_kernel_xiaomi_sm7435-modules" path="kernel/xiaomi/sm7435-modules" remote="github" revision="lineage-23.0" />
  <project name="LineageOS/android_hardware_xiaomi" path="hardware/xiaomi" remote="github" revision="lineage-23.0" />
</manifest>
```

> **Note:** `external/libnetfilter_conntrack` and `hardware/libhardware_legacy` are in the main LineageOS manifest — do NOT add them.

---

## Build Instructions

```bash
# 1. Repo sync
repo sync -c -j16 --force-sync --no-clone-bundle --no-tags

# 2. SCP libvmmem (required — see Known Issues below)

# 3. Build
source build/envsetup.sh
breakfast dizi
mka bacon
```

---

## Known Build Issues & Fixes

### 1. libvmmem.so missing
The CAF display stack requires `libvmmem.so` which must be manually placed after sync:

```bash
# Copy from vendor tree to display libvmmem folder
cp vendor/xiaomi/dizi/proprietary/vendor/lib64/libvmmem.so \
    hardware/qcom-caf/sm8450/display/libvmmem/libvmmem.so

cp vendor/xiaomi/dizi/proprietary/vendor/lib/libvmmem.so \
    hardware/qcom-caf/sm8450/display/libvmmem/libvmmem32.so
```

### 2. dizi_GKI.config missing
The kernel config for dizi must be created from the parrot/garnet base:

```bash
cp kernel/xiaomi/sm7435/arch/arm64/configs/vendor/garnet_GKI.config \
   kernel/xiaomi/sm7435/arch/arm64/configs/vendor/dizi_GKI.config
```

### 3. qcril-database — SQL files not present in stock ROM
The `qcril-database` genrule references vendor SQL filegroups that do not exist in the dizi stock ROM.
Fix applied: genrule and prebuilt_etc disabled in `qcril-database/Android.bp`, `qcrilNrDb_vendor` removed from `device.mk`.

### 4. DTBO partition write error
`BOARD_PREBUILT_DTBOIMAGE` must point outside the source tree to avoid a read-only directory error during kernel.mk execution.

```makefile
BOARD_PREBUILT_DTBOIMAGE := out/dtbo_prebuilt/dtbo.img
```

Copy the prebuilt before building:
```bash
mkdir -p out/dtbo_prebuilt
cp device/xiaomi/dizi/dtbo/dtbo.img out/dtbo_prebuilt/dtbo.img
```

---

## Partition Sizes (from stock ROM — SM7435P)

| Partition | Size |
|---|---|
| boot | 100663296 (96MB) |
| recovery | 104857600 (100MB) |
| vendor_boot | 100663296 (96MB) |
| dtbo | 25165824 (24MB) |

---

## Key Differences vs Garnet (base device)

| Feature | Garnet | Dizi |
|---|---|---|
| WiFi/BT | WCN3990 (Adrastea) | WCN6750 (QCA6750) |
| Cameras | 4 sensors | 3 sensors (GC08A3, OV08D10, OV13B10) |
| Display | 6.67" 480 DPI | 12.1" 280 DPI |
| Fingerprint | Side-mounted | None |
| NFC | Yes | No |
| Board ID | `0x1000b 0x00` | `0x2000b 0x01` |

---

## Flashing Instructions

1. Flash recovery: `fastboot flash recovery recovery.img`
2. Reboot to recovery: `fastboot reboot recovery`
3. Factory Reset → Format Data (type "yes") — **REQUIRED**
4. Apply Update → ADB Sideload
5. `adb sideload lineage-23.0-*-dizi.zip`

> If stuck at metadata: `fastboot erase metadata` then reboot recovery.

---

## Credits

- [garnet-random](https://github.com/garnet-random) — kernel source and base device tree (Redmi Note 13 Pro)
- [LineageOS](https://github.com/LineageOS) — Android base
- Ported to dizi by [nobleactual17](https://github.com/nobleactual17)
