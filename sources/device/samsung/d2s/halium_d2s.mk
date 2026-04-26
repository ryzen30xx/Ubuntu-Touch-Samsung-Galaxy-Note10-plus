# Halium-specific overrides
PRODUCT_NAME := halium_d2s
PRODUCT_DEVICE := d2s
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-N975F
PRODUCT_MANUFACTURER := samsung

# Inherit from the LineageOS configuration
$(call inherit-product, device/samsung/d2s/lineage_d2s.mk)

# Halium fstab
PRODUCT_COPY_FILES += \
    halium/halium.fstab:$(TARGET_COPY_OUT_RAMDISK)/fstab.exynos9820 \
    halium/halium.fstab:$(TARGET_COPY_OUT_RAMDISK)/fstab.exynos9825 \
    halium/halium.fstab:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.exynos9820 \
    halium/halium.fstab:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.exynos9825
