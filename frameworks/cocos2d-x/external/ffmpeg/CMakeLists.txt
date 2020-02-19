# Sets the minimum version of CMake required to build the native
# library. You should either keep the default value or only pass a
# value of 3.6 or lower.

cmake_minimum_required(VERSION 3.6)
message (STATUS "**** This is ffmpeg Library ****")

project(avcodec)
add_library( avcodec
             SHARED
             IMPORTED )
set_target_properties( avcodec
                       PROPERTIES IMPORTED_LOCATION
                       ${COCOS2DX_ROOT_PATH}/external/ffmpeg/libavcodec.so 
                       )
project(avformat)
add_library( avformat
             SHARED
             IMPORTED)
set_target_properties( avformat
                       PROPERTIES IMPORTED_LOCATION
                       ${COCOS2DX_ROOT_PATH}/external/ffmpeg/libavformat.so
                       )
project(swscale)
add_library( swscale
             SHARED
             IMPORTED)
set_target_properties( swscale
                       PROPERTIES IMPORTED_LOCATION
                       ${COCOS2DX_ROOT_PATH}/external/ffmpeg/libswscale.so
                       )

project(avutil)
add_library( avutil
             SHARED
             IMPORTED )
set_target_properties( avutil
                       PROPERTIES IMPORTED_LOCATION
                       ${COCOS2DX_ROOT_PATH}/external/ffmpeg/libavutil.so                       
                       )

# target_link_libraries( ffmpeg avutil-52 avcodec-55 swscale-2  avformat-55 )