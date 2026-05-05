#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Inherit from ruan device
$(call inherit-product, device/xiaomi/ruan/device.mk)

PRODUCT_NAME := lineage_ruan
PRODUCT_DEVICE := ruan
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := Redmi Pad Pro 5G

PRODUCT_SYSTEM_NAME := ruan_global
PRODUCT_SYSTEM_DEVICE := ruan

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="ruan_in_global-user 15 AQ3A.240912.001 OS2.0.207.0.VFSINXM release-keys" \
    BuildFingerprint=Redmi/ruan_in_global/ruan:15/AQ3A.240912.001/OS2.0.207.0.VFSINXM:user/release-keys \
    DeviceName=$(PRODUCT_SYSTEM_DEVICE) \
    DeviceProduct=$(PRODUCT_SYSTEM_NAME)

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
