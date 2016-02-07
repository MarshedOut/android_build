# Copyright (C) 2016 The SaberMod Project
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

########################### Settings Begin

# Blacklists
LOCAL_BLUETOOTH := \
	libbluetooth_jni \
	bluetooth.mapsapi \
	bluetooth.default \
	bluetooth.mapsapi \
	libbt-brcm_stack \
	audio.a2dp.default \
	libbt-brcm_gki \
	libbt-utils \
	libbt-qcom_sbc_decoder \
	libbt-brcm_bta \
	libbt-brcm_stack \
	libbt-vendor \
	libbtprofile \
	libbtdevice \
	libbtcore \
	bdt \
	bdtest \
	libbt-hci \
	libosi \
	ositests \
	libbluetooth_jni \
	net_test_osi \
	net_test_device \
	net_test_btcore \
	net_bdtool \
	net_hci \
	bdAddrLoader \
	camera.msm8974 \
	copybit.msm8974 \
	gps.msm8974 \
	gralloc.msm8974 \
	keystore.msm8974 \
	memtrack.msm8974 \
	hwcomposer.msm8974 \
	lights.msm8974 \
	power.msm8974 \
	audio.primary.msm8974

NO_OPTIMIZATIONS := \
	libvpx \
	libbypass \
	libperfprofdcore \
	libwebrtc_spl \
	libFraunhoferAAC \
	libmincrypt \
	libc++abi \
	nfc_nci.bcm2079x.default \
	libjni_latinime_common_static \
	libcompiler_rt \
	libnativebridge \
	libc++ \
	libRSSupport \
	libskia \
	libxml2 \
	netd \
	libscrypt_static \
	libRSCpuRef \
	libRSDriver \
	libmm-qcamera \
	libmmcamera_interface \
	libmmjpeg_interface \
	mm-jpeg-interface-test \
	mm-qcamera-app \
	libqomx_core \
	libwebp-decode \
	libwebp-encode \
	libsfntly \
	mdnsd \
	fsck.f2fs \
	mkfs.f2fs \
	libf2fs \
	linker \
	libft2 \
	libhwui \
	libril \
	librilutils \
	librilutils_static \
	libpcap \
	liblog \
	logd \
	logcat \
	libdex \
	libFraunhoferAAC \
	libicui18n \
	libselinux \
	libsfntly \
	libharfbuzz_ng \
	libpdfiumcore \
	libpdfium \
	rsg-generator \
	libloc_core \
	libqdutils \
	libRSCpuRef \
	libmedia_jni \
	libcrypto \
	libcrypto-host_32 \
	libsqlite_jni_32 \
	libfdlibm \
	libnfc-nci \
	libssh \
	libxml2 \
	$(LOCAL_BLUETOOTH)

LOCAL_DISABLE_TUNE := \
	libc_dns \
	libc_tzcode \
	libwebviewchromium \
	libwebviewchromium_loader \
	libwebviewchromium_plat_support \
	$(NO_OPTIMIZATIONS)

LOCAL_DISABLE_GRAPHITE := $(NO_OPTIMIZATIONS)

LOCAL_DISABLE_IPA := $(LOCAL_BLUETOOTH)

LOCAL_DISABLE_GCC_VECTORIZE := $(NO_OPTIMIZATIONS)

LOCAL_DEBUGGING_WHITELIST := $(NO_OPTIMIZATIONS)

# Flags
GRAPHITE_FLAGS := \
	-fgraphite \
	-fgraphite-identity \
	-floop-flatten \
	-ftree-loop-linear \
	-floop-interchange \
	-floop-strip-mine \
	-floop-block
	-Wno-error=maybe-uninitialized

EXTRA_GCC := \
	-ftree-loop-distribution \
	-ftree-loop-if-convert \
	-ftree-loop-im \
	-ftree-loop-ivcanon

EXTRA_GCC_VECTORIZE := \
	-ftree-vectorize

########################### Settings End
########################### Optimizations Begin

# Target build flags
ifndef LOCAL_IS_HOST_MODULE
  ifneq ($(my_clang),true)
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_GCC_VECTORIZE),$(LOCAL_MODULE))))
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += $(EXTRA_GCC_VECTORIZE)
      else
        LOCAL_CFLAGS := $(EXTRA_GCC_VECTORIZE)
      endif
    endif
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += $(EXTRA_GCC)
    else
      LOCAL_CFLAGS := $(EXTRA_GCC)
    endif
  endif
endif

# Use the memory leak sanitizer and openmp for all arm targets
ifneq ($(filter arm arm64,$(TARGET_ARCH)),)
  ifndef LOCAL_IS_HOST_MODULE
    ifneq ($(my_clang),true)
      ifdef LOCAL_CONLYFLAGS
        LOCAL_CONLYFLAGS += -fsanitize=leak
      else
        LOCAL_CONLYFLAGS := -fsanitize=leak
      endif
      ifneq (1,$(words $(filter libwebviewchromium libc_netbsd,$(LOCAL_MODULE))))
        ifdef LOCAL_CFLAGS
          LOCAL_CFLAGS += -lgomp -ldl -lgcc -fopenmp
        else
          LOCAL_CFLAGS := -lgomp -ldl -lgcc -fopenmp
        endif
        ifdef LOCAL_LDLIBS
          LOCAL_LDLIBS += -lgomp -lgcc
        else
          LOCAL_LDLIBS := -lgomp -lgcc
        endif
      endif
    endif
  endif
endif

# Disable debugging
ifneq ($(my_clang),true)
  ifneq (1,$(words $(LOCAL_DEBUGGING_WHITELIST)))
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += -g0
    else
      LOCAL_CFLAGS := -g0
    endif
    ifdef LOCAL_CPPFLAGS
      LOCAL_CPPFLAGS += -g0
    else
      LOCAL_CPPFLAGS := -g0
    endif
  endif
endif

# IPA Analyser Optimizations
ifneq (true,$(my_clang))
  ifndef LOCAL_IS_HOST_MODULE
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_IPA),$(LOCAL_MODULE))))
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
      else
        LOCAL_CFLAGS := -fipa-sra -fipa-pta -fipa-cp -fipa-cp-clone
      endif
    endif
  endif
endif

# Do not use graphite on host modules or the clang compiler
ifndef LOCAL_IS_HOST_MODULE
  ifneq ($(my_clang),true)
    # If it gets this far enable graphite by default from here on out.
    ifneq (1,$(words $(filter $(LOCAL_DISABLE_GRAPHITE),$(LOCAL_MODULE))))
      ifdef LOCAL_CFLAGS
        LOCAL_CFLAGS += $(GRAPHITE_FLAGS)
      else
        LOCAL_CFLAGS := $(GRAPHITE_FLAGS)
      endif
      ifdef LOCAL_LDFLAGS
        LOCAL_LDFLAGS += $(GRAPHITE_FLAGS)
      else
        LOCAL_LDFLAGS := $(GRAPHITE_FLAGS)
      endif
    endif
  endif
endif

ifneq (1,$(words $(filter $(LOCAL_DISABLE_TUNE), $(LOCAL_MODULE))))
  ifneq ($(strip $(LOCAL_IS_HOST_MODULE)),true)
    ifdef LOCAL_CFLAGS
      LOCAL_CFLAGS += -mcpu=cortex-a15
    else
      LOCAL_CFLAGS := -mcpu=cortex-a15
    endif
  endif
endif

ifeq (true,$(strip $(LOCAL_IS_HOST_MODULE)))
  ifdef LOCAL_CFLAGS
    LOCAL_CFLAGS += -march=native -mtune=native
  else
    LOCAL_CFLAGS := -march=native -mtune=native
  endif
endif

########################### Optimizations End
