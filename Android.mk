#
# Copyright (C) 2020-2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifneq ($(filter tulip jasmine_sprout wayne clover lavender platina jason whyred,$(TARGET_DEVICE)),)

$(shell mkdir -p $(TARGET_OUT_VENDOR)/firmware)

LPFLASH := $(HOST_OUT_EXECUTABLES)/lpflash$(HOST_EXECUTABLE_SUFFIX)
INSTALLED_SUPERIMAGE_DUMMY_TARGET := $(PRODUCT_OUT)/super_dummy.img

$(INSTALLED_SUPERIMAGE_DUMMY_TARGET): $(PRODUCT_OUT)/super_empty.img $(LPFLASH)
	$(call pretty,"Target dummy super image: $@")
	$(hide) touch $@
	$(hide) echo $(CURDIR)
	$(hide) $(LPFLASH) $@ $(PRODUCT_OUT)/super_empty.img

.PHONY: super_dummyimage
super_dummyimage: $(INSTALLED_SUPERIMAGE_DUMMY_TARGET)

INSTALLED_RADIOIMAGE_TARGET += $(INSTALLED_SUPERIMAGE_DUMMY_TARGET)

include $(CLEAR_VARS)

# A/B builds require us to create the mount points at compile time.
# Just creating it for all cases since it does not hurt.
FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/firmware_mnt
BT_FIRMWARE_MOUNT_POINT := $(TARGET_OUT_VENDOR)/bt_firmware
DSP_MOUNT_POINT := $(TARGET_OUT_VENDOR)/dsp

$(FIRMWARE_MOUNT_POINT):
	@echo "Creating $(FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/firmware_mnt

$(BT_FIRMWARE_MOUNT_POINT):
	@echo "Creating $(BT_FIRMWARE_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/bt_firmware

$(DSP_MOUNT_POINT):
	@echo "Creating $(DSP_MOUNT_POINT)"
	@mkdir -p $(TARGET_OUT_VENDOR)/dsp

ALL_DEFAULT_INSTALLED_MODULES += $(FIRMWARE_MOUNT_POINT) $(BT_FIRMWARE_MOUNT_POINT) $(DSP_MOUNT_POINT)

IMS_LIBS := libimscamera_jni.so libimsmedia_jni.so
IMS_SYMLINKS := $(addprefix $(TARGET_OUT_SYSTEM_EXT_APPS_PRIVILEGED)/ims/lib/arm64/,$(notdir $(IMS_LIBS)))
$(IMS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "IMS lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /system_ext/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(IMS_SYMLINKS)

EGL_LIBRARIES := \
	libEGL_adreno.so \
	libGLESv2_adreno.so \
	libq3dtools_adreno.so

EGL_32_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/lib/,$(notdir $(EGL_LIBRARIES)))
$(EGL_32_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "EGL 32 lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf egl/$(notdir $@) $@

EGL_64_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/lib64/,$(notdir $(EGL_LIBRARIES)))
$(EGL_64_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "EGL lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf egl/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += \
	$(EGL_32_SYMLINKS) \
	$(EGL_64_SYMLINKS)

METADATA_SYMLINKS := $(TARGET_ROOT_OUT)/metadata
$(METADATA_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating $@"
	@mkdir -p $(TARGET_ROOT_OUT)/metadata
	$(hide) ln -sf /data/apex $@/apex

ALL_DEFAULT_INSTALLED_MODULES += $(METADATA_SYMLINKS)

CNE_LIBS := libvndfwk_detect_jni.qti.so
CNE_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/app/CneApp/lib/arm64/,$(notdir $(CNE_LIBS)))
$(CNE_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CneApp lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /vendor/lib64/$(notdir $@) $@

ALL_DEFAULT_INSTALLED_MODULES += $(CNE_SYMLINKS)

subdir_makefiles=$(call first-makefiles-under,$(LOCAL_PATH))
$(foreach mk,$(subdir_makefiles),$(info including $(mk) ...)$(eval include $(mk)))
endif
