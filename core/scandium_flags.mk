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
ifdef _SCANDIUM_FLAGS_MK_INCLUDED
$(error core/scandium_flags.mk included more than once)
endif
_SCANDIUM_FLAGS_MK_INCLUDED := true


# Enable ScandiumUI core extensions (must be true for all custom features)
SCANDIUM_FLAG_CORE_ENABLED ?= true

# Verbose banner during build (prints version/edition info)
SCANDIUM_FLAG_CORE_VERBOSE_BANNER ?= true

# Enable per-device build customisation hooks
SCANDIUM_FLAG_CORE_DEVICE_HOOKS ?= true


# Enable compiler-level hardening (stack canaries, FORTIFY, etc.)
SCANDIUM_FLAG_SEC_COMPILER_HARDENING ?= true

# Enable verified boot / dm-verity enforcement
SCANDIUM_FLAG_SEC_VERIFIED_BOOT ?= true

# Enable SELinux enforcing mode (always true for release builds)
SCANDIUM_FLAG_SEC_SELINUX_ENFORCING ?= true

# Wipe userdata on decryption failure
SCANDIUM_FLAG_SEC_WIPE_ON_FAIL ?= true

# Restrict USB in locked state (GrapheneOS-style)
SCANDIUM_FLAG_SEC_USB_RESTRICTED ?= true

# Enable kernel address space layout randomization
SCANDIUM_FLAG_SEC_KASLR ?= true

# Seccomp filter enforcement
SCANDIUM_FLAG_SEC_SECCOMP ?= true

# Memory-tagging extension (MTE) for AArch64
SCANDIUM_FLAG_SEC_MTE ?= false

# Shadow call stack (hardware-assisted CFI)
SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK ?= false

# Control Flow Integrity
SCANDIUM_FLAG_SEC_CFI ?= true

# Integer overflow sanitizer (production builds only for performance)
SCANDIUM_FLAG_SEC_INTEGER_OVERFLOW_SANITIZE ?= false

# Minimal logcat by default (no app logs unless unlocked)
SCANDIUM_FLAG_PRIV_MINIMAL_LOGCAT ?= true

# Restrict background process launch (stronger than AOSP)
SCANDIUM_FLAG_PRIV_RESTRICT_BG_LAUNCH ?= true

# Enable MAC address randomisation at every boot
SCANDIUM_FLAG_PRIV_MAC_RANDOMIZE ?= true

# Disable advertising ID by default
SCANDIUM_FLAG_PRIV_DISABLE_ADID ?= true

# Strip build fingerprint from crash reports
SCANDIUM_FLAG_PRIV_STRIP_FINGERPRINT_IN_REPORTS ?= true

# Enable Link-Time Optimisation for core platform libraries
SCANDIUM_FLAG_PERF_LTO ?= true

# Enable Profile-Guided Optimisation (requires PGO profile in vendor)
SCANDIUM_FLAG_PERF_PGO ?= false

# Enable Polly LLVM auto-vectorisation
SCANDIUM_FLAG_PERF_POLLY ?= false

# Enable ZRAM (compressed RAM swap)
SCANDIUM_FLAG_PERF_ZRAM ?= true

# Default ZRAM size in MB (0 = auto = half of RAM)
SCANDIUM_FLAG_PERF_ZRAM_SIZE_MB ?= 0

# ZRAM compression algorithm: lz4 | zstd | lzo-rle
SCANDIUM_FLAG_PERF_ZRAM_ALGO ?= lz4

# Enable I/O scheduler tuning (mq-deadline for UFS, cfq for eMMC)
SCANDIUM_FLAG_PERF_IO_SCHED ?= true

# Enable dexpreopt with speed compiler filter for system apps
SCANDIUM_FLAG_PERF_DEXPREOPT_SYSTEM ?= true

# Enable dexpreopt with speed-profile for priv-apps
SCANDIUM_FLAG_PERF_DEXPREOPT_PRIV ?= true

# Enable ART boot image profile
SCANDIUM_FLAG_PERF_ART_BOOT_PROFILE ?= true

# Parallel make jobs (0 = auto-detect from nproc)
SCANDIUM_FLAG_PERF_MAKE_JOBS ?= 0

# Enable ccache for build acceleration
SCANDIUM_FLAG_PERF_CCACHE ?= false

# Enable smooth display / high-refresh-rate support
SCANDIUM_FLAG_UX_HIGH_REFRESH_RATE ?= true

# Enable adaptive refresh rate
SCANDIUM_FLAG_UX_ADAPTIVE_REFRESH ?= true

# Enable blur effects in SystemUI
SCANDIUM_FLAG_UX_BLUR ?= true

# Enable haptic feedback enhancements
SCANDIUM_FLAG_UX_HAPTICS ?= true

# Enable notification LED support (legacy)
SCANDIUM_FLAG_UX_NOTIFICATION_LED ?= false

# GMS compatibility layer (sandboxed Google Play)
SCANDIUM_FLAG_GAPPS_GMSCOMPAT ?= $(SCANDIUM_FEATURE_GMSCOMPAT)

# Signature spoofing support for MicroG (incompatible with GmsCompat)
SCANDIUM_FLAG_GAPPS_SIGNATURE_SPOOF ?= false

# Enable built-in OTA updater
SCANDIUM_FLAG_OTA_ENABLED ?= true

# Enable automatic OTA download (Wi-Fi only by default)
SCANDIUM_FLAG_OTA_AUTO_DOWNLOAD ?= false

# Enable incremental OTA generation
SCANDIUM_FLAG_OTA_INCREMENTAL ?= true

# Security hardening active: requires both compiler hardening and CFI
ifeq ($(SCANDIUM_FLAG_SEC_COMPILER_HARDENING)$(SCANDIUM_FLAG_SEC_CFI),truetrue)
  SCANDIUM_FULL_SECURITY_HARDENING := true
else
  SCANDIUM_FULL_SECURITY_HARDENING := false
endif
.KATI_READONLY := SCANDIUM_FULL_SECURITY_HARDENING

# Edition gate: Professional edition unlocks experimental perf flags
ifeq ($(SCANDIUM_EDITION),Professional)
  SCANDIUM_FLAG_PERF_POLLY ?= true
  SCANDIUM_FLAG_SEC_MTE ?= true
  SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK ?= true
endif

# Academy edition: lock down more privacy features
ifeq ($(SCANDIUM_EDITION),Academy)
  SCANDIUM_FLAG_PRIV_MINIMAL_LOGCAT := true
  SCANDIUM_FLAG_PRIV_RESTRICT_BG_LAUNCH := true
  SCANDIUM_FLAG_GAPPS_SIGNATURE_SPOOF := false
endif

# Expose all flags to Soong modules for conditional compilation.

# Core
$(call soong_config_set_bool,SCANDIUM,flag_core_enabled,$(if $(filter true,$(SCANDIUM_FLAG_CORE_ENABLED)),true,false))

# Security
$(call soong_config_set_bool,SCANDIUM,flag_sec_compiler_hardening,$(if $(filter true,$(SCANDIUM_FLAG_SEC_COMPILER_HARDENING)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_sec_cfi,$(if $(filter true,$(SCANDIUM_FLAG_SEC_CFI)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_sec_mte,$(if $(filter true,$(SCANDIUM_FLAG_SEC_MTE)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_sec_shadow_call_stack,$(if $(filter true,$(SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_sec_seccomp,$(if $(filter true,$(SCANDIUM_FLAG_SEC_SECCOMP)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_sec_usb_restricted,$(if $(filter true,$(SCANDIUM_FLAG_SEC_USB_RESTRICTED)),true,false))

# Privacy
$(call soong_config_set_bool,SCANDIUM,flag_priv_mac_randomize,$(if $(filter true,$(SCANDIUM_FLAG_PRIV_MAC_RANDOMIZE)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_priv_disable_adid,$(if $(filter true,$(SCANDIUM_FLAG_PRIV_DISABLE_ADID)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_priv_minimal_logcat,$(if $(filter true,$(SCANDIUM_FLAG_PRIV_MINIMAL_LOGCAT)),true,false))

# Performance
$(call soong_config_set_bool,SCANDIUM,flag_perf_lto,$(if $(filter true,$(SCANDIUM_FLAG_PERF_LTO)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_perf_pgo,$(if $(filter true,$(SCANDIUM_FLAG_PERF_PGO)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_perf_zram,$(if $(filter true,$(SCANDIUM_FLAG_PERF_ZRAM)),true,false))
$(call soong_config_set,SCANDIUM,flag_perf_zram_algo,$(SCANDIUM_FLAG_PERF_ZRAM_ALGO))

# OTA
$(call soong_config_set_bool,SCANDIUM,flag_ota_enabled,$(if $(filter true,$(SCANDIUM_FLAG_OTA_ENABLED)),true,false))
$(call soong_config_set_bool,SCANDIUM,flag_ota_incremental,$(if $(filter true,$(SCANDIUM_FLAG_OTA_INCREMENTAL)),true,false))
