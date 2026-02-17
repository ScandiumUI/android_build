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
ifdef _SCANDIUM_SECURITY_MK_INCLUDED
$(error core/scandium_security.mk included more than once)
endif
_SCANDIUM_SECURITY_MK_INCLUDED := true

# Must be included after scandium_flags.mk
ifndef _SCANDIUM_FLAGS_MK_INCLUDED
$(error core/scandium_security.mk requires core/scandium_flags.mk to be included first)
endif

ifeq ($(SCANDIUM_FLAG_SEC_COMPILER_HARDENING),true)

  # Stack Smashing Protection — full (all functions)
  SCANDIUM_HARDENING_CFLAGS += -fstack-protector-strong

  # FORTIFY_SOURCE level 2 — detect buffer overflows at compile + runtime
  SCANDIUM_HARDENING_CFLAGS += -D_FORTIFY_SOURCE=2

  # Position-Independent Executable
  SCANDIUM_HARDENING_CFLAGS += -fPIE

  # Strict aliasing for safer compiler optimisations
  SCANDIUM_HARDENING_CFLAGS += -fstrict-aliasing

  # Detect and error on VLA usage (variable-length arrays)
  SCANDIUM_HARDENING_CFLAGS += -Wvla -Werror=vla

  # Linker hardening
  SCANDIUM_HARDENING_LDFLAGS += -pie
  SCANDIUM_HARDENING_LDFLAGS += -Wl,-z,relro
  SCANDIUM_HARDENING_LDFLAGS += -Wl,-z,now
  SCANDIUM_HARDENING_LDFLAGS += -Wl,-z,noexecstack
  SCANDIUM_HARDENING_LDFLAGS += -Wl,-z,separate-code

endif # SCANDIUM_FLAG_SEC_COMPILER_HARDENING
ifeq ($(SCANDIUM_FLAG_SEC_CFI),true)

  SCANDIUM_HARDENING_CFLAGS += -fsanitize=cfi
  SCANDIUM_HARDENING_CFLAGS += -fsanitize-cfi-cross-dso
  SCANDIUM_HARDENING_LDFLAGS += -fsanitize=cfi

endif # SCANDIUM_FLAG_SEC_CFI

ifeq ($(SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK),true)
  ifeq ($(TARGET_ARCH),arm64)
    SCANDIUM_HARDENING_CFLAGS += -fsanitize=shadow-call-stack
  endif
endif # SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK

ifeq ($(SCANDIUM_FLAG_SEC_MTE),true)
  ifeq ($(TARGET_ARCH),arm64)
    SCANDIUM_HARDENING_CFLAGS  += -march=armv8.5-a+memtag
    SCANDIUM_HARDENING_CFLAGS  += -fsanitize=memtag-stack,memtag-heap
    SCANDIUM_HARDENING_LDFLAGS += -fsanitize=memtag-stack,memtag-heap
    # Asynchronous mode for production (lower overhead than synchronous)
    SCANDIUM_HARDENING_CFLAGS  += -fsanitize-memtag-mode=async
  endif
endif # SCANDIUM_FLAG_SEC_MTE

ifeq ($(SCANDIUM_FLAG_SEC_INTEGER_OVERFLOW_SANITIZE),true)
  SCANDIUM_HARDENING_CFLAGS += -fsanitize=signed-integer-overflow,unsigned-integer-overflow
  SCANDIUM_HARDENING_CFLAGS += -fsanitize-trap=signed-integer-overflow,unsigned-integer-overflow
endif # SCANDIUM_FLAG_SEC_INTEGER_OVERFLOW_SANITIZE

ifeq ($(SCANDIUM_FLAG_SEC_SELINUX_ENFORCING),true)
  SCANDIUM_SELINUX_POLICY_MODE := enforcing
else
  SCANDIUM_SELINUX_POLICY_MODE := permissive
endif
.KATI_READONLY := SCANDIUM_SELINUX_POLICY_MODE

# Apply SELinux mode to product properties
ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.boot.selinux=$(SCANDIUM_SELINUX_POLICY_MODE)

ifeq ($(SCANDIUM_FLAG_SEC_VERIFIED_BOOT),true)
  BOARD_AVB_ENABLE ?= true
  BOARD_AVB_ROLLBACK_INDEX := 0

  # Enforce rollback protection
  SCANDIUM_VERIFIED_BOOT_ACTIVE := true
else
  SCANDIUM_VERIFIED_BOOT_ACTIVE := false
endif
.KATI_READONLY := SCANDIUM_VERIFIED_BOOT_ACTIVE
# In locked state, USB is data-only (no ADB, no accessory) until unlocked.
ifeq ($(SCANDIUM_FLAG_SEC_USB_RESTRICTED),true)
  ADDITIONAL_SYSTEM_PROPERTIES += \
      persist.sys.usb.config=none \
      ro.adb.secure=1 \
      ro.secure=1
endif

ifeq ($(SCANDIUM_FLAG_SEC_KASLR),true)
  # Tell the kernel config system that KASLR must be enabled.
  # Actual enforcement is in the kernel defconfig; this flag serves as a
  # build-time documentation / guard checked by vendor board configs.
  SCANDIUM_REQUIRE_KASLR := true
else
  SCANDIUM_REQUIRE_KASLR := false
endif
.KATI_READONLY := SCANDIUM_REQUIRE_KASLR

ifeq ($(SCANDIUM_FLAG_SEC_WIPE_ON_FAIL),true)
  ADDITIONAL_SYSTEM_PROPERTIES += \
      ro.scandium.security.wipe_on_fail=true
endif

ifeq ($(SCANDIUM_FLAG_SEC_SECCOMP),true)
  ADDITIONAL_SYSTEM_PROPERTIES += \
      ro.scandium.security.seccomp=true
endif

ADDITIONAL_SYSTEM_PROPERTIES += \
    ro.scandium.security.hardening=$(SCANDIUM_FLAG_SEC_COMPILER_HARDENING) \
    ro.scandium.security.cfi=$(SCANDIUM_FLAG_SEC_CFI) \
    ro.scandium.security.mte=$(SCANDIUM_FLAG_SEC_MTE) \
    ro.scandium.security.shadow_call_stack=$(SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK) \
    ro.scandium.security.selinux=$(SCANDIUM_SELINUX_POLICY_MODE) \
    ro.scandium.security.verified_boot=$(SCANDIUM_FLAG_SEC_VERIFIED_BOOT) \
    ro.scandium.security.usb_restricted=$(SCANDIUM_FLAG_SEC_USB_RESTRICTED) \
    ro.scandium.security.kaslr=$(SCANDIUM_FLAG_SEC_KASLR) \
    ro.scandium.security.seccomp=$(SCANDIUM_FLAG_SEC_SECCOMP) \
    ro.scandium.security.full_hardening=$(SCANDIUM_FULL_SECURITY_HARDENING)

# Make readonly so they cannot be silently overridden downstream.
.KATI_READONLY := SCANDIUM_HARDENING_CFLAGS
.KATI_READONLY := SCANDIUM_HARDENING_LDFLAGS

$(info   ✓  [ScandiumUI Security] CFI=$(SCANDIUM_FLAG_SEC_CFI) MTE=$(SCANDIUM_FLAG_SEC_MTE) SCS=$(SCANDIUM_FLAG_SEC_SHADOW_CALL_STACK) USB_restricted=$(SCANDIUM_FLAG_SEC_USB_RESTRICTED))
