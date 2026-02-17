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

# Guard against double inclusion
ifdef _SCANDIUM_BUILD_UTILS_MK_INCLUDED
$(error core/scandium_build_utils.mk included more than once)
endif
_SCANDIUM_BUILD_UTILS_MK_INCLUDED := true

# sc-version-gte
# Returns "true" if version $(1) >= version $(2).
# Versions must be dot-separated integers, e.g. "23.2.0".
#
# Usage: $(call sc-version-gte,23.2.0,23.1.0)  → true
#        $(call sc-version-gte,23.0.0,23.2.0)  → (empty)
define sc-version-split-major
$(firstword $(subst ., ,$(1)))
endef

define sc-version-split-minor
$(word 2,$(subst ., ,$(1)))
endef

define sc-version-split-patch
$(word 3,$(subst ., ,$(1)))
endef

define sc-version-gte
$(strip \
  $(eval _sc_v1_maj := $(call sc-version-split-major,$(1))) \
  $(eval _sc_v2_maj := $(call sc-version-split-major,$(2))) \
  $(eval _sc_v1_min := $(call sc-version-split-minor,$(1))) \
  $(eval _sc_v2_min := $(call sc-version-split-minor,$(2))) \
  $(eval _sc_v1_pat := $(call sc-version-split-patch,$(1))) \
  $(eval _sc_v2_pat := $(call sc-version-split-patch,$(2))) \
  $(if $(call math_gte_int,$(_sc_v1_maj),$(_sc_v2_maj)), \
    $(if $(call math_gt_int,$(_sc_v1_maj),$(_sc_v2_maj)), \
      true, \
      $(if $(call math_gte_int,$(_sc_v1_min),$(_sc_v2_min)), \
        $(if $(call math_gt_int,$(_sc_v1_min),$(_sc_v2_min)), \
          true, \
          $(if $(call math_gte_int,$(_sc_v1_pat),$(_sc_v2_pat)),true,)), \
        )), \
    ))
endef

# sc-version-bump-patch
# Increments the patch component of a version string.
# $(1): version string (e.g. "23.2.0")
# Returns: version with patch + 1 (e.g. "23.2.1")
define sc-version-bump-patch
$(call sc-version-split-major,$(1)).$(call sc-version-split-minor,$(1)).$(shell expr $(call sc-version-split-patch,$(1)) + 1)
endef

# sc-flag-enabled
# Returns "true" if the given flag variable equals "true".
# $(1): variable name (e.g. SCANDIUM_FLAG_PERF_LTO)
define sc-flag-enabled
$(filter true,$($(1)))
endef

# sc-flag-any-enabled
# Returns "true" if ANY of the given flag variables equals "true".
# $(1): space-separated list of variable names
define sc-flag-any-enabled
$(strip $(foreach _f,$(1),$(call sc-flag-enabled,$(_f))))
endef

# sc-flag-all-enabled
# Returns "true" if ALL of the given flag variables equal "true".
# $(1): space-separated list of variable names
define sc-flag-all-enabled
$(strip \
  $(eval _sc_fae_all := true) \
  $(foreach _f,$(1), \
    $(if $(call sc-flag-enabled,$(_f)),, \
      $(eval _sc_fae_all :=))) \
  $(_sc_fae_all))
endef

# sc-require-flag
# Emits a build error if the given flag is NOT "true".
# $(1): variable name
# $(2): human-readable description for the error message
define sc-require-flag
$(if $(call sc-flag-enabled,$(1)),, \
  $(error [ScandiumUI] Required flag $(1) is not enabled. $(2)))
endef

# sc-assert-nonempty
# Errors if variable $(1) is empty.
# $(2): description shown in error message
define sc-assert-nonempty
$(if $(strip $($(1))),, \
  $(error [ScandiumUI] $(1) must not be empty. $(2)))
endef

# sc-assert-one-of
# Errors if variable $(1) is not in the list $(2).
# $(2): space-separated list of valid values
define sc-assert-one-of
$(if $(filter $($(1)),$(2)),, \
  $(error [ScandiumUI] $(1)='$($(1))' is not one of: $(2)))
endef

# sc-assert-file-exists
# Errors if file $(1) does not exist.
# $(2): description
define sc-assert-file-exists
$(if $(wildcard $(1)),, \
  $(error [ScandiumUI] Required file '$(1)' not found. $(2)))
endef

# sc-assert-min-version
# Errors if SCANDIUM_VERSION_NUMBER < $(1).
# $(1): minimum required version string
define sc-assert-min-version
$(if $(call sc-version-gte,$(SCANDIUM_VERSION_NUMBER),$(1)),, \
  $(error [ScandiumUI] Build requires ScandiumUI >= $(1), but current version is $(SCANDIUM_VERSION_NUMBER)))
endef

# sc-add-system-prop
# Appends a key=value pair to ADDITIONAL_SYSTEM_PROPERTIES.
# $(1): property key
# $(2): property value
define sc-add-system-prop
$(eval ADDITIONAL_SYSTEM_PROPERTIES += $(1)=$(2))
endef

# sc-add-product-prop
# Appends a key=value pair to PRODUCT_PRODUCT_PROPERTIES.
# $(1): property key
# $(2): property value
define sc-add-product-prop
$(eval PRODUCT_PRODUCT_PROPERTIES += $(1)=$(2))
endef

# sc-add-vendor-prop
# Appends a key=value pair to PRODUCT_VENDOR_PROPERTIES.
# $(1): property key
# $(2): property value
define sc-add-vendor-prop
$(eval PRODUCT_VENDOR_PROPERTIES += $(1)=$(2))
endef

# sc-add-odm-prop
# Appends a key=value pair to PRODUCT_ODM_PROPERTIES.
# $(1): property key
# $(2): property value
define sc-add-odm-prop
$(eval PRODUCT_ODM_PROPERTIES += $(1)=$(2))
endef

# sc-add-prop-to-all
# Injects the same key=value to system, product, and vendor.
# $(1): property key
# $(2): property value
define sc-add-prop-to-all
$(call sc-add-system-prop,$(1),$(2)) \
$(call sc-add-product-prop,$(1),$(2)) \
$(call sc-add-vendor-prop,$(1),$(2))
endef

# sc-info
# Prints a structured info line prefixed with [ScandiumUI <module>].
# $(1): module name (e.g. Security, Perf, Core)
# $(2): message
define sc-info
$(info [ScandiumUI $(1)] $(2))
endef

# sc-warn
# Prints a structured warning line.
# $(1): module name
# $(2): message
define sc-warn
$(warning [ScandiumUI $(1)] $(2))
endef

# sc-step
# Prints a build step marker (useful for tracking inclusion order).
# $(1): step description
define sc-step
$(info >>> ScandiumUI: $(1))
endef

# sc-vendor-path
# Returns path under vendor/scandium/<subpath>.
# $(1): subpath
define sc-vendor-path
vendor/scandium/$(1)
endef

# sc-vendor-file-exists
# Returns "true" if vendor/scandium/$(1) exists.
# $(1): subpath
define sc-vendor-file-exists
$(if $(wildcard $(call sc-vendor-path,$(1))),true,)
endef

# sc-core-path
# Returns path under build/make/core/<subpath>.
# $(1): subpath
define sc-core-path
build/make/core/$(1)
endef

# sc-out-path
# Returns path under $(OUT_DIR)/<subpath>.
# $(1): subpath
define sc-out-path
$(OUT_DIR)/$(1)
endef

# sc-is-edition
# Returns "true" if SCANDIUM_EDITION equals $(1).
# $(1): edition name (Professional | Casual | Academy)
define sc-is-edition
$(filter $(1),$(SCANDIUM_EDITION))
endef

# sc-if-edition
# Evaluates $(2) if SCANDIUM_EDITION equals $(1), else $(3).
# $(1): edition name
# $(2): value if match
# $(3): value if no match
define sc-if-edition
$(if $(call sc-is-edition,$(1)),$(2),$(3))
endef

# sc-is-release
# Returns "true" if this is a COOKIE (official release) build.
define sc-is-release
$(filter COOKIE,$(SCANDIUM_BUILDTYPE))
endef

# sc-is-snapshot
# Returns "true" if this is a SNAPSHOT build.
define sc-is-snapshot
$(filter SNAPSHOT,$(SCANDIUM_BUILDTYPE))
endef

# sc-is-experimental
# Returns "true" if this is an EXPERIMENTAL build.
define sc-is-experimental
$(filter EXPERIMENTAL,$(SCANDIUM_BUILDTYPE))
endef

# sc-if-release
# Evaluates $(1) only on COOKIE builds.
# $(1): expression to evaluate
define sc-if-release
$(if $(call sc-is-release),$(1),)
endef

$(call sc-step,Build utilities loaded)
