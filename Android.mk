# Copyright 2007 The Android Open Source Project
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

# This makefile builds both for host and target, and so all the
# common definitions are factored out into a separate file to
# minimize duplication between the build rules.

LOCAL_PATH:= $(call my-dir)

#
# Build rules for the target.
#
include $(CLEAR_VARS)

FFI_ARCH=$(TARGET_ARCH)

LOCAL_SRC_FILES := src/$(TARGET_ARCH)-dummy.c

ifeq ($(TARGET_ARCH),arm64)
  FFI_ARCH=aarch64
  LOCAL_SRC_FILES += src/aarch64/sysv.S src/aarch64/ffi.c
endif

ifeq ($(TARGET_ARCH),arm)
  LOCAL_SRC_FILES += src/arm/sysv.S src/arm/ffi.c
endif

ifeq ($(TARGET_ARCH),mips64)
  LOCAL_SRC_FILES += src/mips/ffi.c src/mips/o32.S src/mips/n32.S
endif

ifeq ($(TARGET_ARCH),mips)
  LOCAL_SRC_FILES += src/mips/ffi.c src/mips/o32.S src/mips/n32.S
endif

ifeq ($(TARGET_ARCH),x86)
  FFI_ARCH=i686
  LOCAL_SRC_FILES += src/x86/ffi.c src/x86/sysv.S src/x86/win32.S
endif

ifeq ($(TARGET_ARCH),x86_64)
  LOCAL_SRC_FILES += src/x86/ffi64.c src/x86/unix64.S src/x86/ffi.c src/x86/sysv.S
endif

ifeq ($(LOCAL_SRC_FILES),)
  $(info The os/architecture $(TARGET_ARCH) is not supported by libffi.)
  LOCAL_SRC_FILES += your-architecture-not-supported-by-ffi-makefile.c
endif

LOCAL_C_INCLUDES := $(LOCAL_PATH)/include $(LOCAL_PATH)/$(FFI_ARCH)-and-linux-gnu $(LOCAL_PATH)/$(FFI_ARCH)-and-linux-gnu/include

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/$(FFI_ARCH)-and-linux-gnu/include

LOCAL_SRC_FILES += \
	src/debug.c \
	src/java_raw_api.c \
	src/prep_cif.c \
        src/raw_api.c \
	src/types.c \
	src/closures.c

$(LOCAL_PATH)/configure:
	$(LOCAL_PATH)/autogen.sh

$(LOCAL_PATH)/src/arm-dummy.c: $(LOCAL_PATH)/configure
	$(LOCAL_PATH)/configure --host=arm-and-linux-gnu
	echo "" > src/arm-dummy.c

$(LOCAL_PATH)/src/arm64-dummy.c: $(LOCAL_PATH)/configure
	$(LOCAL_PATH)/configure --host=aarch64-and-linux-gnu
	echo "" > src/arm64-dummy.c

$(LOCAL_PATH)/src/x86-dummy.c: $(LOCAL_PATH)/configure
	$(LOCAL_PATH)/configure --host=i686-and-linux-gnu
	echo "" > src/x86-dummy.c

$(LOCAL_PATH)/src/x86_64-dummy.c: $(LOCAL_PATH)/configure
	$(LOCAL_PATH)/configure --host=x86_64-and-linux-gnu
	echo "" > src/x86_64-dummy.c

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := libffi

include $(BUILD_SHARED_LIBRARY)
