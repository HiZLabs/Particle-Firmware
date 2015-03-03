ifeq ($(included_productid_mk),)
included_productid_mk := 1

# defines 
# PLATFORM_NAME - a unique name for the platform, can be used to organise sources
#                 by platform
# PLATFORM_MCU  - an identifier for the MCU family
# PLATFORM_NET  - the network subsystem
# STM32_DEVICE  - the specific device being targeted for STM32 platform builds
# ARCH		- architecture (ARM/GCC)
# PRODUCT_DESC  - text description of the product ID
# PLATFORM_DYNALIB_MODULES - if the device supports a modular build, the name
#		- of the subdirectory containing 

# Default USB Device Vendor ID for Spark Products
USBD_VID_SPARK=0x1D50
# Default USB Device Product ID for DFU Class
USBD_PID_DFU=0x607F
# Default USB Device Product ID for CDC Class
USBD_PID_CDC=0x607D

ifneq (,$(PLATFORM))
ifeq ("$(PLATFORM)","core")
PLATFORM_ID = 0
endif

ifeq ("$(PLATFORM)","core-hd")
PLATFORM_ID = 2
endif

ifeq ("$(PLATFORM)","gcc")
PLATFORM_ID = 3
endif

ifeq ("$(PLATFORM)","dev-photon")
PLATFORM_ID = 4
endif

ifeq ("$(PLATFORM)","dev-teacup-bm14")
PLATFORM_ID = 5
endif

ifeq ("$(PLATFORM)","photon")
PLATFORM_ID = 6
endif

ifeq ("$(PLATFORM)","teacup-bm14")
PLATFORM_ID = 7
endif

ifeq ("$(PLATFORM)","newhal")
PLATFORM_ID=8
endif

ifeq (,$(PLATFORM_ID))
$(error "Unknown platform: $(PLATFORM))
endif
endif

ifndef PLATFORM_ID
PLATFORM_ID=0
endif

# Determine which is the target device

ARCH=arm

ifeq ("$(PLATFORM_ID)","0")
STM32_DEVICE=STM32F10X_MD
PLATFORM=core
PLATFORM_NAME=core-v1
PLATFORM_MCU=STM32F1xx
PLATFORM_NET=CC3000
PRODUCT_DESC=Spark core
USBD_VID_SPARK=0x1D50
USBD_PID_DFU=0x607F
USBD_PID_CDC=0x607D
DEFAULT_PRODUCT_ID=0
endif

ifeq ("$(PLATFORM_ID)","1")
# Not used. PRRODUCT_ID 1 is the original teacup pigtail - the platform
# is the Spark Core
DEFAULT_PRODUCT_ID=1
endif

ifeq ("$(PLATFORM_ID)","2")
PLATFORM=core-hd
STM32_DEVICE=STM32F10X_HD
PLATFORM_NAME=core-v1
PLATFORM_MCU=STM32F1xx
PLATFORM_NET=CC3000
PRODUCT_DESC=Spark core-HD, 256k flash, 48k ram
USBD_VID_SPARK=0x1D50
USBD_PID_DFU=0x607F
USBD_PID_CDC=0x607D
DEFAULT_PRODUCT_ID=2
endif

ifeq ("$(PLATFORM_ID)","3")
PLATFORM=gcc
PLATFORM_NAME=gcc
PLATFORM_MCU=gcc
PLATFORM_NET=gcc
ARCH=gcc
PRODUCT_DESC=GCC xcompile
# explicitly exclude platform headers
SPARK_NO_PLATFORM=1
DEFAULT_PRODUCT_ID=3
endif

ifeq ("$(PLATFORM_ID)","4")
PLATFORM=dev-photon
STM32_DEVICE=STM32F2XX
PLATFORM_NAME=core-v2
PLATFORM_MCU=STM32F2xx
PLATFORM_NET=BCM9WCDUSI09
PRODUCT_DESC=BM-09/WICED
PLATFORM_DYNALIB_MODULES=photon
USBD_VID_SPARK=0x1D50
USBD_PID_DFU=0x607F
USBD_PID_CDC=0x607D
DEFAULT_PRODUCT_ID=4
endif

ifeq ("$(PLATFORM_ID)","5")
PLATFORM=dev-teacup-bm14
STM32_DEVICE=STM32F2XX
PLATFORM_NAME=core-v2
PLATFORM_MCU=STM32F2xx
PLATFORM_NET=BCM9WCDUSI14
PRODUCT_DESC=BM-14/WICED
USBD_VID_SPARK=0x1D50
USBD_PID_DFU=0x607F
USBD_PID_CDC=0x607D
DEFAULT_PRODUCT_ID=5
endif

ifeq ("$(PLATFORM_ID)","6")
PLATFORM=photon
STM32_DEVICE=STM32F2XX
PLATFORM_NAME=core-v2
PLATFORM_MCU=STM32F2xx
PLATFORM_NET=BCM9WCDUSI09
PRODUCT_DESC=Production Photon
# eventually want to generate the PID from the base + product ID
USBD_VID_SPARK=0x2B04
USBD_PID_DFU=0xD006
USBD_PID_CDC=0xC006
PLATFORM_DYNALIB_MODULES=photon
DEFAULT_PRODUCT_ID=6
endif

ifeq ("$(PLATFORM_ID)","7")
PLATFORM=teacup-bm14
STM32_DEVICE=STM32F2XX
PLATFORM_NAME=core-v2
PLATFORM_MCU=STM32F2xx
PLATFORM_NET=BCM9WCDUSI14
PRODUCT_DESC=Production Teacup Pigtail
USBD_VID_SPARK=0x1D50
USBD_PID_DFU=0x607F
USBD_PID_CDC=0x607D
DEFAULT_PRODUCT_ID=5
endif

ifeq ("$(PLATFORM_ID)","8")
PLATFORM=newhal
STM32_DEVICE=newhalcpu
# used to define the sources in hal/src/new-hal
PLATFORM_NAME=newhal
# define MCU-specific platform defines under platform/MCU/new-hal
PLATFORM_MCU=newhal-mcu
PLATFORM_NET=not-defined
PRODUCT_DESC=Test platform for producing a new HAL implementation
USBD_VID_SPARK=0x1D50
USBD_PID_DFU=0x607F
USBD_PID_CDC=0x607D
DEFAULT_PRODUCT_ID=8
endif


ifeq ("$(PLATFORM_NAME)","core-v1")
    PLATFORM_DFU ?= 0x08005000
else
    PLATFORM_DFU ?= 0x08020000
endif


ifeq ("$(PLATFORM_MCU)","")
$(error PLATFORM_MCU not defined. Check platform id $(PLATFORM_ID))
endif

ifeq ("$(PLATFORM_NET)","")
$(error PLATFORM_NET not defined. Check platform id $(PLATFORM_ID))
endif

# lower case version of the STM32_DEVICE string for use in filenames
STM32_DEVICE_LC  = $(shell echo $(STM32_DEVICE) | tr A-Z a-z)

ifdef STM32_DEVICE
# needed for conditional compilation of syshealth_hal.h
CFLAGS += -DSTM32_DEVICE
# needed for conditional compilation of some stm32 specific files
CFLAGS += -D$(STM32_DEVICE)
endif

ifeq ("$(PRODUCT_ID)","")
# ifeq (,$(submake))
# $(info PRODUCT_ID not defined - using default: $(DEFAULT_PRODUCT_ID))
# endif
PRODUCT_ID = $(DEFAULT_PRODUCT_ID)
endif

CFLAGS += -DPLATFORM_ID=$(PLATFORM_ID) -DPLATFORM_NAME=$(PLATFORM_NAME)

CFLAGS += -DUSBD_VID_SPARK=$(USBD_VID_SPARK)
CFLAGS += -DUSBD_PID_DFU=$(USBD_PID_DFU)
CFLAGS += -DUSBD_PID_CDC=$(USBD_PID_CDC)


MODULE_FUNCTION_NONE            :=0
MODULE_FUNCTION_RESOURCE        :=1
MODULE_FUNCTION_BOOTLOADER      :=2
MODULE_FUNCTION_MONO_FIRMWARE   :=3
MODULE_FUNCTION_SYSTEM_PART     :=4
MODULE_FUNCTION_USER_PART       :=5


endif