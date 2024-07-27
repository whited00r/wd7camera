THEOS_DEVICE_IP = 192.168.1.18
GO_EASY_ON_ME = 1
include theos/makefiles/common.mk

TWEAK_NAME = WD7Camera
WD7Camera_FILES = Tweak.xm
WD7Camera_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
