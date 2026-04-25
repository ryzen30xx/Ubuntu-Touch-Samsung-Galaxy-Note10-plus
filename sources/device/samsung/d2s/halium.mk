# Inherit from those products. Most specific first.
$(call inherit-product, device/samsung/d2s/lineage_d2s.mk)

# Halium specifics
$(call inherit-product, vendor/halium/config/common.mk)

PRODUCT_NAME := halium_d2s
PRODUCT_DEVICE := d2s
PRODUCT_MODEL := Samsung Galaxy Note 10+ (Halium)
