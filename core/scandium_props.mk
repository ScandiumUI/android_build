#
# Copyright (C) 2024-2026 The ScandiumUI Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Injects ScandiumUI-specific system properties into all relevant
# partitions (system, product, vendor, odm).
#
# Property groups:
#   ro.scandium.*        Core identity & version
#   ro.scandium.build.*  Build metadata
#   ro.scandium.security.*  Security posture
#   ro.scandium.perf.*   Performance configuration
#   ro.scandium.feature.*   Feature flags
#   ro.scandium.ota.*    OTA channel & URL
#   ro.scandium.privacy.*   Privacy settings
#   ro.scandium.ux.*     UX / display settings
#   persist.scandium.*   Mutable / persist props

# Guard against double inclusion
ifdef _SCANDIUM_PROPS_MK_INCLUDED
$(error core/scandium_props.mk included more than once)
endif
_SCANDIUM_PROPS_MK_INCLUDED := true

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.version=$(SCANDIUM_VERSION_NUMBER) \
    ro.scandium.edition=$(SCANDIUM_EDITION) \
    ro.scandium.branch=$(SCANDIUM_BRANCH) \
    ro.scandium.display.version=$(SCANDIUM_DISPLAY_VERSION) \
    ro.scandium.releasetype=$(SCANDIUM_BUILDTYPE)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.build.id=$(SCANDIUM_BUILD_ID) \
    ro.scandium.build.fingerprint=$(SCANDIUM_BUILD_FINGERPRINT) \
    ro.scandium.build.date=$(SCANDIUM_BUILD_DATE) \
    ro.scandium.build.timestamp=$(SCANDIUM_BUILD_TIMESTAMP) \
    ro.scandium.base_rom=$(SCANDIUM_BASE_ROM) \
    ro.scandium.base_rom.version=$(SCANDIUM_BASE_ROM_VERSION)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.security.selinux=$(SCANDIUM_SELINUX_POLICY_MODE) \
    ro.scandium.security.verified_boot=$(SCANDIUM_VERIFIED_BOOT_ACTIVE) \
    ro.scandium.security.full_hardening=$(SCANDIUM_FULL_SECURITY_HARDENING)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.feature.gmscompat=$(SCANDIUM_FEATURE_GMSCOMPAT) \
    ro.scandium.feature.exec_spawning=$(SCANDIUM_FEATURE_EXEC_SPAWNING) \
    ro.scandium.feature.hardened_malloc=$(SCANDIUM_FEATURE_HARDENED_MALLOC) \
    ro.scandium.feature.network_permission=$(SCANDIUM_FEATURE_NETWORK_PERMISSION) \
    ro.scandium.feature.sensor_permission=$(SCANDIUM_FEATURE_SENSOR_PERMISSION) \
    ro.scandium.feature.storage_scopes=$(SCANDIUM_FEATURE_STORAGE_SCOPES) \
    ro.scandium.feature.contact_scopes=$(SCANDIUM_FEATURE_CONTACT_SCOPES) \
    ro.scandium.feature.secure_camera=$(SCANDIUM_FEATURE_SECURE_CAMERA)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.ota.channel=$(SCANDIUM_OTA_CHANNEL) \
    ro.scandium.ota.base_url=$(SCANDIUM_OTA_BASE_URL) \
    ro.scandium.ota.incremental=$(SCANDIUM_FLAG_OTA_INCREMENTAL) \
    ro.scandium.ota.auto_download=$(SCANDIUM_FLAG_OTA_AUTO_DOWNLOAD)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.privacy.mac_randomize=$(SCANDIUM_FLAG_PRIV_MAC_RANDOMIZE) \
    ro.scandium.privacy.disable_adid=$(SCANDIUM_FLAG_PRIV_DISABLE_ADID) \
    ro.scandium.privacy.minimal_logcat=$(SCANDIUM_FLAG_PRIV_MINIMAL_LOGCAT) \
    ro.scandium.privacy.restrict_bg_launch=$(SCANDIUM_FLAG_PRIV_RESTRICT_BG_LAUNCH)

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.ux.high_refresh_rate=$(SCANDIUM_FLAG_UX_HIGH_REFRESH_RATE) \
    ro.scandium.ux.adaptive_refresh=$(SCANDIUM_FLAG_UX_ADAPTIVE_REFRESH) \
    ro.scandium.ux.blur=$(SCANDIUM_FLAG_UX_BLUR) \
    ro.scandium.ux.haptics=$(SCANDIUM_FLAG_UX_HAPTICS)

PRODUCT_PRODUCT_PROPERTIES += \
    ro.scandium.version=$(SCANDIUM_VERSION_NUMBER) \
    ro.scandium.edition=$(SCANDIUM_EDITION) \
    ro.scandium.branch=$(SCANDIUM_BRANCH) \
    ro.scandium.display.version=$(SCANDIUM_DISPLAY_VERSION) \
    ro.scandium.releasetype=$(SCANDIUM_BUILDTYPE) \
    ro.scandium.ota.channel=$(SCANDIUM_OTA_CHANNEL)

PRODUCT_VENDOR_PROPERTIES += \
    ro.scandium.version=$(SCANDIUM_VERSION_NUMBER) \
    ro.scandium.branch=$(SCANDIUM_BRANCH) \
    ro.scandium.security.selinux=$(SCANDIUM_SELINUX_POLICY_MODE) \
    ro.scandium.perf.zram=$(SCANDIUM_FLAG_PERF_ZRAM) \
    ro.scandium.perf.zram_algo=$(SCANDIUM_FLAG_PERF_ZRAM_ALGO) \
    ro.scandium.perf.io_sched=$(SCANDIUM_FLAG_PERF_IO_SCHED)

PRODUCT_VENDOR_PROPERTIES += \
    persist.scandium.perf.zram_algo=$(SCANDIUM_FLAG_PERF_ZRAM_ALGO) \
    persist.scandium.ux.blur=$(SCANDIUM_FLAG_UX_BLUR) \
    persist.scandium.privacy.mac_randomize=$(SCANDIUM_FLAG_PRIV_MAC_RANDOMIZE)

ifneq ($(TARGET_BUILD_VARIANT),user)
  ADDITIONAL_SYSTEM_PROPERTIES += \
      ro.scandium.debug=true \
      ro.scandium.debug.build_variant=$(TARGET_BUILD_VARIANT)
endif

$(info   ✓  [ScandiumUI Props] Properties injected → system / product / vendor / persist)
