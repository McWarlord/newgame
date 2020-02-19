LOCAL_PATH:= $(call my-dir)
APP_ALLOW_MISSING_DEPS := true
include $(CLEAR_VARS)
LOCAL_MODULE:= avformat_pre
LOCAL_SRC_FILES:= lib/libavformat.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= avcodec_pre
LOCAL_SRC_FILES:= lib/libavcodec.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= swscale_pre
LOCAL_SRC_FILES:= lib/libswscale.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= avutil_pre
LOCAL_SRC_FILES:= lib/libavutil.so
include $(PREBUILT_SHARED_LIBRARY)
