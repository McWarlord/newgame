LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE:= avcodec_pre
LOCAL_SRC_FILES:= libavcodec-55.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= avformat_pre
LOCAL_SRC_FILES:= libavformat-55.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= swscale_pre
LOCAL_SRC_FILES:= libswscale-2.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= avutil_pre
LOCAL_SRC_FILES:= libavutil-52.so
include $(PREBUILT_SHARED_LIBRARY)
