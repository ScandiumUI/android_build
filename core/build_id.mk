ifneq ($(ALLOW_BUILD_ID_MK_INCLUSION), 1)
    # do not allow including this file from unexpected places, since that would break per-product
    # BUILD_ID. See core/version_util.mk
    $(error ALLOW_BUILD_ID_MK_INCLUSION is not set)
endif
#
# Copyright (C) 2008 The Android Open Source Project
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

BUILD_ID=BP4A.251205.006

# Format: SC<major>.<minor>.<patch>-<branch>
# Bump major on platform upgrade, minor on feature release, patch on hotfix.
SCANDIUM_BUILD_ID := SC4.0.0-cookie

# Build epoch — monotonically increasing integer for OTA ordering
SCANDIUM_BUILD_EPOCH := $(shell date -u +%s)
