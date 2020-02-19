
message (STATUS "**** This is videoplayer Library ****")

include_directories(
	${COCOS2DX_ROOT_PATH}/external/ffmpeg
	${COCOS2DX_ROOT_PATH}/external/ffmpeg/include
)


set(COCOS_VIDEOPLAYER_HEADER
    videoplayer/CCVideoDecode.h
    videoplayer/CCVideoLayer.h
    videoplayer/CCVideoPic.h
    videoplayer/CCVideoTextureCache.h
)
set(COCOS_VIDEOPLAYER_SRC
    videoplayer/CCVideoDecode.cpp
    videoplayer/CCVideoLayer.cpp
    videoplayer/CCVideoPic.cpp
    videoplayer/CCVideoTextureCache.cpp
)

