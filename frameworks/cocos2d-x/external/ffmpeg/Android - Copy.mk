LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE:= avcodec_pre
LOCAL_SRC_FILES:= libavcodec.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= avformat_pre
LOCAL_SRC_FILES:= libavformat.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= swscale_pre
LOCAL_SRC_FILES:= libswscale.so
include $(PREBUILT_SHARED_LIBRARY)
 
include $(CLEAR_VARS)
LOCAL_MODULE:= avutil_pre
LOCAL_SRC_FILES:= libavutil.so
include $(PREBUILT_SHARED_LIBRARY)
