/**
 * 视频解码类
 * 目前只支持视频流、不包括音频
 */
#ifndef __CCVIDEO_DECODE_H__
#define __CCVIDEO_DECODE_H__

#include "cocos2d.h"
#include "CCVideoLayer.h"
#include "CCVideoPic.h"

#ifdef __cplusplus
extern "C" {
	#include "libavcodec/avcodec.h"
	#include "libavformat/avformat.h"  
	#include "libswscale/swscale.h"  
}
#else
	#include "libavcodec/avcodec.h"
	#include "libavformat/avformat.h"  
	#include "libswscale/swscale.h"  
#endif

struct AVFormatContext;  
struct AVCodecContext;  
struct AVFrame;  
struct AVPicture;  
struct SwsContext; 


NS_CC_BEGIN  
 
class CCVideoDecode : public CCObject
{
	private:
		AVFormatContext *m_pFormatCtx;  
	    AVCodecContext	*m_pCodecCtx;  
	    AVFrame			*m_pFrame;  
	    
	    int m_videoStream;
	    SwsContext *m_pSwsCtx;

	    int m_frameCount;   //解码到第几帧
	    char m_filepath[256]; //视频文件路径
	    double m_frameRate; //帧率
	    unsigned int m_frames;   // 总帧数
	    unsigned int m_width;  
    	unsigned int m_height;
	
	public:
		CCVideoDecode();
		virtual ~CCVideoDecode();
		CCVideoPic*		decode();
		bool			init(const char *path);
		unsigned int	getWidth();
		unsigned int	getHeight();
		double			getFrameRate();
		unsigned int	getFrames();
		const char*		getFilePath(); 
};

NS_CC_END
#endif //__CCVIDEO_DECODE_H__
