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
ifdef _SCANDIUM_PERF_MK_INCLUDED
$(error core/scandium_perf.mk included more than once)
endif
_SCANDIUM_PERF_MK_INCLUDED := true

ifeq ($(SCANDIUM_FLAG_PERF_LTO),true)

  # Thin LTO: faster incremental builds with near full-LTO benefits
  SCANDIUM_LTO_MODE := thin
  SCANDIUM_PERF_CFLAGS  += -flto=$(SCANDIUM_LTO_MODE)
  SCANDIUM_PERF_LDFLAGS += -flto=$(SCANDIUM_LTO_MODE)
  SCANDIUM_PERF_LDFLAGS += -Wl,--thinlto-cache-dir=$(OUT_DIR)/.thinlto-cache
  SCANDIUM_PERF_LDFLAGS += -Wl,--thinlto-cache-policy,cache_size_bytes=512m

  $(info [ScandiumUI Perf] LTO mode: $(SCANDIUM_LTO_MODE))

endif # SCANDIUM_FLAG_PERF_LTO

ifeq ($(SCANDIUM_FLAG_PERF_PGO),true)

  # PGO profile path — vendor tree must supply this
  SCANDIUM_PGO_PROFILE_DIR ?= vendor/scandium/pgo/profiles

  ifneq ($(wildcard $(SCANDIUM_PGO_PROFILE_DIR)),)
    SCANDIUM_PERF_CFLAGS += -fprofile-use=$(SCANDIUM_PGO_PROFILE_DIR)
    SCANDIUM_PERF_CFLAGS += -fprofile-correction
    $(info [ScandiumUI Perf] PGO enabled with profiles from $(SCANDIUM_PGO_PROFILE_DIR))
  else
    $(warning [ScandiumUI Perf] PGO requested but no profiles found at $(SCANDIUM_PGO_PROFILE_DIR). Falling back to -O2.)
  endif

endif # SCANDIUM_FLAG_PERF_PGO

ifeq ($(SCANDIUM_FLAG_PERF_POLLY),true)

  SCANDIUM_PERF_CFLAGS += -mllvm -polly
  SCANDIUM_PERF_CFLAGS += -mllvm -polly-parallel
  SCANDIUM_PERF_CFLAGS += -mllvm -polly-vectorizer=stripmine
  SCANDIUM_PERF_CFLAGS += -mllvm -polly-omp-backend=LLVM
  $(info [ScandiumUI Perf] Polly auto-vectoriser enabled)

endif # SCANDIUM_FLAG_PERF_POLLY

# O3 for release builds; O2 for debug builds to keep symbol fidelity.
ifeq ($(TARGET_BUILD_VARIANT),user)
  SCANDIUM_PERF_OPT_LEVEL := -O3
else
  SCANDIUM_PERF_OPT_LEVEL := -O2
endif

SCANDIUM_PERF_CFLAGS += $(SCANDIUM_PERF_OPT_LEVEL)

# Architecture-specific tuning
ifeq ($(TARGET_ARCH),arm64)
  SCANDIUM_PERF_CFLAGS += -mcpu=generic+crc+crypto
  SCANDIUM_PERF_CFLAGS += -mno-outline-atomics
endif
ifeq ($(TARGET_ARCH),arm)
  SCANDIUM_PERF_CFLAGS += -mfpu=neon-vfpv4
  SCANDIUM_PERF_CFLAGS += -mfloat-abi=softfp
endif

ifeq ($(SCANDIUM_FLAG_PERF_ZRAM),true)

  # ZRAM algorithm
  SCANDIUM_ZRAM_ALGO := $(SCANDIUM_FLAG_PERF_ZRAM_ALGO)

  # ZRAM size: compute from flag or default to 50% of typical device RAM
  ifeq ($(SCANDIUM_FLAG_PERF_ZRAM_SIZE_MB),0)
    # Auto: let init script compute at runtime; set a sensible ceiling prop
    SCANDIUM_ZRAM_SIZE_PROP := auto
  else
    SCANDIUM_ZRAM_SIZE_PROP := $(SCANDIUM_FLAG_PERF_ZRAM_SIZE_MB)M
  endif

  ADDITIONAL_SYSTEM_PROPERTIES += \
      ro.scandium.perf.zram=true \
      ro.scandium.perf.zram_algo=$(SCANDIUM_ZRAM_ALGO) \
      ro.scandium.perf.zram_size=$(SCANDIUM_ZRAM_SIZE_PROP)

  $(info [ScandiumUI Perf] ZRAM enabled. algo=$(SCANDIUM_ZRAM_ALGO) size=$(SCANDIUM_ZRAM_SIZE_PROP))

endif # SCANDIUM_FLAG_PERF_ZRAM

ifeq ($(SCANDIUM_FLAG_PERF_IO_SCHED),true)

  # Target scheduler is set at runtime by init based on storage type.
  # We only expose the preference via props here.
  ADDITIONAL_SYSTEM_PROPERTIES += \
      ro.scandium.perf.io_sched=true \
      ro.scandium.perf.io_sched.ufs=mq-deadline \
      ro.scandium.perf.io_sched.emmc=cfq \
      ro.scandium.perf.io_sched.nvme=none

endif # SCANDIUM_FLAG_PERF_IO_SCHED

# System apps: speed compiler filter for minimal JIT overhead
ifeq ($(SCANDIUM_FLAG_PERF_DEXPREOPT_SYSTEM),true)
  SCANDIUM_DEXPREOPT_SYSTEM_FILTER := speed
  PRODUCT_DEX_PREOPT_DEFAULT_FLAGS += --compiler-filter=$(SCANDIUM_DEXPREOPT_SYSTEM_FILTER)
  $(info [ScandiumUI Perf] dexpreopt system filter: $(SCANDIUM_DEXPREOPT_SYSTEM_FILTER))
endif

# Priv-apps: speed-profile for JIT-guided compilation
ifeq ($(SCANDIUM_FLAG_PERF_DEXPREOPT_PRIV),true)
  SCANDIUM_DEXPREOPT_PRIV_FILTER := speed-profile
  PRODUCT_DEX_PREOPT_BOOT_FLAGS += --compiler-filter=$(SCANDIUM_DEXPREOPT_PRIV_FILTER)
  $(info [ScandiumUI Perf] dexpreopt priv-app filter: $(SCANDIUM_DEXPREOPT_PRIV_FILTER))
endif

# ART boot image profile
ifeq ($(SCANDIUM_FLAG_PERF_ART_BOOT_PROFILE),true)
  PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
  PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION ?= frameworks/base/config/boot-image-profile.txt
  $(info [ScandiumUI Perf] ART boot image profile: $(PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION))
endif

ifeq ($(SCANDIUM_FLAG_PERF_MAKE_JOBS),0)
  # Auto: use all available cores
  SCANDIUM_MAKE_JOBS := $(shell nproc 2>/dev/null || echo 4)
else
  SCANDIUM_MAKE_JOBS := $(SCANDIUM_FLAG_PERF_MAKE_JOBS)
endif
.KATI_READONLY := SCANDIUM_MAKE_JOBS

$(info   ✓  [ScandiumUI Perf] Parallel build jobs: $(SCANDIUM_MAKE_JOBS) cores)

ifeq ($(SCANDIUM_FLAG_PERF_CCACHE),true)
  USE_CCACHE := 1
  CCACHE_EXEC := $(shell which ccache 2>/dev/null)
  ifdef CCACHE_EXEC
    $(info [ScandiumUI Perf] ccache enabled: $(CCACHE_EXEC))
  else
    $(warning [ScandiumUI Perf] ccache requested but not found in PATH. Disabling.)
    USE_CCACHE := 0
  endif
endif

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.perf.lto=$(SCANDIUM_FLAG_PERF_LTO) \
    ro.scandium.perf.pgo=$(SCANDIUM_FLAG_PERF_PGO) \
    ro.scandium.perf.polly=$(SCANDIUM_FLAG_PERF_POLLY) \
    ro.scandium.perf.opt_level=$(SCANDIUM_PERF_OPT_LEVEL) \
    ro.scandium.perf.make_jobs=$(SCANDIUM_MAKE_JOBS) \
    ro.scandium.perf.art_boot_profile=$(SCANDIUM_FLAG_PERF_ART_BOOT_PROFILE)

.KATI_READONLY := SCANDIUM_PERF_CFLAGS
.KATI_READONLY := SCANDIUM_PERF_LDFLAGS
.KATI_READONLY := SCANDIUM_PERF_OPT_LEVEL
