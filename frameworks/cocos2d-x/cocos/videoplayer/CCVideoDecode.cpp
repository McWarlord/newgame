/**
 * 视频解码类
 */
#include "CCVideoDecode.h"
#include "CCVideoTextureCache.h"
#include "CCVideoPic.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	#include "jni.h"
	#include "platform/android/jni/JniHelper.h"
#endif

NS_CC_BEGIN

int m_width = 0;
int64_t duration = 0;
CCVideoDecode::CCVideoDecode()
{
	m_filepath[0] = '\0';
	m_pFormatCtx = NULL;
	m_videoStream = -1;
    m_pSwsCtx = NULL;
    m_pCodecCtx = NULL;
    m_frameCount = 0;
}

bool CCVideoDecode::init(const char *path)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo info;
	std::string absolutePath = JniHelper::callStaticStringMethod("org/cocos2dx/lua/AppActivity", "getAbsolutePathOfAdum");

	strcpy(m_filepath, absolutePath.c_str());
	strcat(m_filepath, "/");
	strcat(m_filepath, "adumbratesv202/");
	strcat(m_filepath, path + 11);
	CCLOG(m_filepath, "");
#else
    strcpy(m_filepath, CCFileUtils::sharedFileUtils()->fullPathForFilename(path).c_str());
#endif
   
	/*strcpy(m_filepath, CCFileUtils::sharedFileUtils()->fullPathForFilename(path).c_str());*/
    // Register all formats and codecs  
    av_register_all();  
      
    /* 1、构建avformat */
    if(avformat_open_input(&m_pFormatCtx, m_filepath, NULL, NULL) != 0) {  
         CCLOG("avformat_open_input false");
         return false;  
    }
    
    /* 2、获取流信息 */
    if(avformat_find_stream_info(m_pFormatCtx, NULL) < 0) {  
        CCLOG("avformat_find_stream_info false");
        return false;  
    } 

    m_videoStream = -1;

    for(int i=0; i<m_pFormatCtx->nb_streams; i++) {  
        
        if(m_videoStream == -1 && m_pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            m_videoStream = i;
            break;
        }

    } 
    
    //  没有视频流，无法播放  
    if(m_videoStream == -1) {
        CCLOGERROR("没有视频流，无法播放");  
        return false;  
    } 

    m_pCodecCtx = m_pFormatCtx->streams[m_videoStream]->codec;
    // 获取基本信息
    if (m_pCodecCtx->width) 
    {
        m_width = m_pCodecCtx->width;
        m_height = m_pCodecCtx->height;
    }
    else
    {
        CCLOGERROR("获取视频尺寸失败");  
        return false;
    }

     /*
      Duration: 00:00:07.32, start: 0.000000, bitrate: 579 kb/s
    Stream #0:0: Video: vp6a, yuva420p, 224x240,
     31 fps, 31 tbr, 1k tbn, 1k tbc
     */
    
    //算时间
//    int64_t duration = 0;
    if (m_pFormatCtx->duration != AV_NOPTS_VALUE) {
        /*int hours, mins, secs, us;*/
        duration = m_pFormatCtx->duration + 5000;
        /*secs = duration / AV_TIME_BASE;
        us = duration % AV_TIME_BASE;
        mins = secs / 60;
        secs %= 60;
        hours = mins / 60;
        mins %= 60;
        CCLOG("%02d:%02d:%02d.%02d", hours, mins, secs, (100 * us) / AV_TIME_BASE);*/
    } else {
        CCLOGERROR("duration is null");
        return false;
    }
    
    AVRational rational;

    if(m_pFormatCtx->streams[m_videoStream]->avg_frame_rate.den && m_pFormatCtx->streams[m_videoStream]->avg_frame_rate.num)
    {           
        rational = m_pFormatCtx->streams[m_videoStream]->avg_frame_rate;
    }
    else if(m_pFormatCtx->streams[m_videoStream]->r_frame_rate.den && m_pFormatCtx->streams[m_videoStream]->r_frame_rate.num)
    {
        rational = m_pFormatCtx->streams[m_videoStream]->r_frame_rate;
    }
    else
    {
		rational.num = 25;
		rational.den = 1;
        CCLOGERROR("fps 获取失败");  
        //return false;
    }

    double fps = av_q2d(rational);
    m_frameRate = 1.0 / fps;
    m_frames = (int)((fps * duration) / AV_TIME_BASE);
    CCLOG("m_frameRate = %f , frames = %d", m_frameRate, m_frames);



    AVCodec *pCodec = NULL;
    pCodec = avcodec_find_decoder(m_pCodecCtx->codec_id);

    if(pCodec == NULL) { 
        CCLOGERROR("avcodec_find_decoder error");
        return false;
    }  
      
    if(avcodec_open2(m_pCodecCtx, pCodec, NULL)) { 
        CCLOGERROR("avcodec_open2 error");
        return false;
    }  

	m_pSwsCtx = sws_getContext(m_pCodecCtx->width,
		m_pCodecCtx->height,
		m_pCodecCtx->pix_fmt,
		m_width,
		m_height, PIX_FMT_RGBA, SWS_FAST_BILINEAR, NULL, NULL, NULL);
	if (!m_pSwsCtx)
	{
		CCLOGERROR("sws_getContext error");
		return false;
	}
    return true;
}


unsigned int CCVideoDecode::getWidth()
{
    return m_width;
}

unsigned int CCVideoDecode::getHeight()
{
    return m_height;
}

double CCVideoDecode::getFrameRate(){
    return m_frameRate;
}

unsigned int CCVideoDecode::getFrames()
{
    return m_frames;
}

const char* CCVideoDecode::getFilePath()
{
    return m_filepath;
}

CCVideoDecode::~CCVideoDecode()
{
    CCLOGINFO("cocos2d: deallocing CCVideoDecode.");
    //if(m_pSwsCtx) sws_freeContext(m_pSwsCtx); 
    

    // Free the YUV frame 
    //if(m_pFrame) av_free(m_pFrame);  
    
    // Close the codec  
    if (m_pCodecCtx) avcodec_close(m_pCodecCtx);  
    if (m_pFormatCtx) avformat_close_input(&m_pFormatCtx);

}

/**
 * 解码
 * @return [description]
 */
CCVideoPic* CCVideoDecode::decode()
{
	try
	{
		if (m_frameCount == -1)
			return NULL;

		AVPacket packet;
		int frameFinished = 0;
		m_pFrame = NULL;
		while (!frameFinished && av_read_frame(m_pFormatCtx, &packet) >= 0)
		{
			if (packet.stream_index == m_videoStream)
			{
				m_pFrame = avcodec_alloc_frame();
				int lentmp = avcodec_decode_video2(m_pCodecCtx, m_pFrame, &frameFinished, &packet);
				if (lentmp <= 0)
				{
					av_free(m_pFrame);
					CCLOG("video pic is NULL1");
					return NULL;
				}
			}
			av_free_packet(&packet);
		}

		if (m_pFrame == NULL)
		{
			CCLOG("video pic is NULL2");
			return NULL;
		}

		AVPicture pic;
		avpicture_alloc(&pic, PIX_FMT_RGBA, m_width, m_height);
		CCLOG("avpicture_alloc width = %d height = %d m_videoStream = %d", m_width, m_height, m_videoStream);
		sws_scale(m_pSwsCtx, m_pFrame->data, m_pFrame->linesize, 0, m_height, pic.data, pic.linesize);
    
		m_frameCount++;

		CCVideoPic *pVideoPic = new CCVideoPic();
		pVideoPic->init(m_filepath, m_frameCount, m_width, m_height, pic.data[m_videoStream], pic.linesize[m_videoStream]);
    

		avpicture_free(&pic);
		av_free(m_pFrame);

		if (frameFinished == 0)
		{
			//重头开始解码
			//av_seek_frame(m_pFormatCtx, m_videoStream , 0, AVSEEK_FLAG_ANY);
			m_frameCount = -1;
		}
		av_free_packet(&packet);
		
		return pVideoPic;
	}
	catch (long e)
	{
		CCLOG("exception code : %d", e);
	}

	CCLOG("video pic is NULL3");
	return NULL;

}

NS_CC_END
