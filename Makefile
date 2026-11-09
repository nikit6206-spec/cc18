TARGET := iphone:clang:latest:15.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := iPadOS18CC
iPadOS18CC_FILES := Tweak.xm
iPadOS18CC_CFLAGS := -fobjc-arc
iPadOS18CC_FRAMEWORKS := UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

# RootHide package build; package metadata is in control
