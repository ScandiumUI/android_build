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

# Major version — increments with each major platform release
PRODUCT_VERSION_MAJOR := 23

# Minor version — increments with each point / feature release
PRODUCT_VERSION_MINOR := 2

# Patch level — increments with each security / hotfix release
PRODUCT_VERSION_PATCH := 0

# Active branch codename (matches repo manifest branch)
SCANDIUM_BRANCH := cookie

# SCANDIUM_BUILD is set to true by vendor/scandium/config/common.mk
# when the full vendor tree is present. Features gate on this flag.
SCANDIUM_BUILD ?= false

# Editions define the feature set and branding variant:
#   Professional (Sc₂O₃) — Full-featured power user experience
#   Casual       (Sc)    — Balanced daily driver              [default]
#   Academy      (ScF₃)  — Education-focused, distraction-free
SCANDIUM_EDITION ?= Casual

# Map edition to lowercase for use in file names and prop values
SCANDIUM_EDITION_LC := $(shell echo $(SCANDIUM_EDITION) | tr A-Z a-z)
#   COOKIE       — Official release builds       (branch: cookie)
#   SNAPSHOT     — Automated CI snapshot builds
#   EXPERIMENTAL — Developer / testing builds
ifeq ($(SCANDIUM_BUILD),true)
  SCANDIUM_BUILDTYPE ?= COOKIE
else
  SCANDIUM_BUILDTYPE ?= EXPERIMENTAL
endif

# Map build type to lowercase
SCANDIUM_BUILDTYPE_LC := $(shell echo $(SCANDIUM_BUILDTYPE) | tr A-Z a-z)

# The following flags document which GrapheneOS hardening features are
# active in this build. They are informational and used by the vendor
# overlay / build to conditionally enable companion components.
SCANDIUM_FEATURE_GMSCOMPAT := true
SCANDIUM_FEATURE_EXEC_SPAWNING := true
SCANDIUM_FEATURE_HARDENED_MALLOC := true
SCANDIUM_FEATURE_NETWORK_PERMISSION := true
SCANDIUM_FEATURE_SENSOR_PERMISSION := true
SCANDIUM_FEATURE_STORAGE_SCOPES := true
SCANDIUM_FEATURE_CONTACT_SCOPES := true
SCANDIUM_FEATURE_SECURE_CAMERA := true

# Numeric version: <major>.<minor>.<patch>
SCANDIUM_VERSION_NUMBER := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_PATCH)

# Build date / timestamp (vendor version.mk may override when SCANDIUM_BUILD=true)
SCANDIUM_BUILD_DATE ?= $(shell date -u +%Y%m%d)
SCANDIUM_BUILD_TIMESTAMP ?= $(shell date -u +%s)

# Display version shown in Settings → About phone
# Format: "ScandiumUI 23.2.0 Casual — cookie"
SCANDIUM_DISPLAY_VERSION := ScandiumUI $(SCANDIUM_VERSION_NUMBER) $(SCANDIUM_EDITION) — $(SCANDIUM_BRANCH)

# Build fingerprint for OTA and identification
# Format: ScandiumUI/<edition_lc>/<branch>/<version>:<buildtype_lc>/<build_id>
SCANDIUM_BUILD_FINGERPRINT := ScandiumUI/$(SCANDIUM_EDITION_LC)/$(SCANDIUM_BRANCH)/$(SCANDIUM_VERSION_NUMBER):$(SCANDIUM_BUILDTYPE_LC)/$(SCANDIUM_BUILD_ID)

SCANDIUM_OTA_CHANNEL ?= stable
SCANDIUM_OTA_BASE_URL ?= https://ota.scandiumui.org

# Full property definitions live in vendor/scandium/config/version.mk.
# These base values ensure props exist even for vanilla (no-vendor) builds.
ifneq ($(SCANDIUM_BUILD),true)
  ADDITIONAL_SYSTEM_PROPERTIES += \
      ro.scandium.version=$(SCANDIUM_VERSION_NUMBER) \
      ro.scandium.build.version=$(SCANDIUM_BUILD_ID) \
      ro.scandium.build.fingerprint=$(SCANDIUM_BUILD_FINGERPRINT) \
      ro.scandium.display.version=$(SCANDIUM_DISPLAY_VERSION) \
      ro.scandium.releasetype=$(SCANDIUM_BUILDTYPE) \
      ro.scandium.edition=$(SCANDIUM_EDITION) \
      ro.scandium.branch=$(SCANDIUM_BRANCH) \
      ro.scandium.base_rom=$(SCANDIUM_BASE_ROM) \
      ro.scandium.base_rom_version=$(SCANDIUM_BASE_ROM_VERSION) \
      ro.scandium.build.date=$(SCANDIUM_BUILD_DATE) \
      ro.scandium.build.timestamp=$(SCANDIUM_BUILD_TIMESTAMP) \
      ro.scandium.ota.channel=$(SCANDIUM_OTA_CHANNEL) \
      ro.scandium.feature.gmscompat=$(SCANDIUM_FEATURE_GMSCOMPAT)
endif

# Prevent downstream makefiles from silently overwriting core identity.
.KATI_READONLY := SCANDIUM_VERSION_NUMBER
.KATI_READONLY := SCANDIUM_DISPLAY_VERSION
.KATI_READONLY := SCANDIUM_BUILD_FINGERPRINT
.KATI_READONLY := SCANDIUM_BUILD_DATE
.KATI_READONLY := SCANDIUM_BUILD_TIMESTAMP
.KATI_READONLY := SCANDIUM_OTA_CHANNEL
.KATI_READONLY := SCANDIUM_OTA_BASE_URL

# When SCANDIUM_BUILD=true, vendor/scandium/config/version.mk overrides
# the computed values above with full version info including display
# version, fingerprint, suffix, and OTA URL.
-include $(TOPDIR)vendor/scandium/config/version.mk
