# Inherit from the LineageOS configuration
$(call inherit-product, $(LOCAL_DIR)/lineage_d2s.mk)

# Halium-specific overrides
PRODUCT_NAME := halium_d2s
