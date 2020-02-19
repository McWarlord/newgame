/**
 * 视频播放层
 * 依赖ffmpeg库
 * 
 * @author leoluo<luochong1987@gmail.com>
 * 
 */
  
#include "CCVideoLayer.h"  
#include "CCVideoTextureCache.h" 
#include "CCVideoDecode.h"

extern "C" { 
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"  
#include "libswscale/swscale.h"  
}  

NS_CC_BEGIN  
CCVideoLayer* CCVideoLayer::create(const char* path)  
{  
    CCVideoLayer* video = new CCVideoLayer();  
    if (video && video->init(path)) {  
         video->autorelease();
         return video;
    }
    CC_SAFE_DELETE(video);
    return NULL;  
}  
  
CCVideoLayer::CCVideoLayer()  
{  
    m_frameRate = 1.0 / 31;
    m_frame_count = 1;  
    m_enableTouchEnd = false;  
    m_width = 100;
    m_height = 100;
    m_playEndScriptHandler = 0;

	m_bIsPlaying = false;
}  
  
CCVideoLayer::~CCVideoLayer()  
{
	CCVideoDecoderCache::sharedVideoCache()->removeVideo(m_strFileName.c_str());
	unregisterPlayScriptHandler();
}

bool CCVideoLayer::init(const char* path)  
{  
    m_strFileName = path;
	CCLOG("CCVideoLayer::init filename = %s", m_strFileName.c_str());

	CCVideoDecode *pVideoDecode = CCVideoDecoderCache::sharedVideoCache()->addVideo(path);
    if(!pVideoDecode)
    {
        CCLOGERROR("videoDecode get error in %s", "CCVideoLayer");
        return false;
    }



    m_width = pVideoDecode->getWidth();
    m_height = pVideoDecode->getHeight();
    m_frames = pVideoDecode->getFrames();   // 总帧数 
    m_frameRate = pVideoDecode->getFrameRate();             // 帧率

    // 渲染的纹理  
    CCTexture2D *texture = new CCTexture2D();
    unsigned int length = m_width * m_height * 4;
    unsigned char* tempData = new unsigned char[length];
	memset(tempData, 0, length);

    texture->initWithData(tempData, length, kCCTexture2DPixelFormat_RGBA8888, m_width, m_height, CCSize(m_width, m_height));      
    initWithTexture(texture);
    this->setContentSize(CCSize(m_width, m_height));
    delete [] tempData;

    return true;  
}

void CCVideoLayer::initAnother(const char* path)
{
	m_strFileName = path;
	Director::getInstance()->getScheduler()->performFunctionInCocosThread([=]{
		init(m_strFileName.c_str());
	});
}
  
void CCVideoLayer::playVideo()
{
	m_frame_count = 1;
    update(0);
    this->schedule(schedule_selector(CCVideoLayer::update), m_frameRate);

	m_bIsPlaying = true;
}  
  
void CCVideoLayer::stopVideo(void)  
{  
    this->unscheduleAllSelectors(); 
	m_bIsPlaying = false;
}  
  
void CCVideoLayer::seek(int frame)  
{  
    m_frame_count = frame;
    update(0);
}

bool CCVideoLayer::getState()
{
	return m_bIsPlaying;
}

void CCVideoLayer::update(float dt)  
{
	try
	{
		CCTexture2D *texture = NULL;
		texture = CCVideoDecoderCache::sharedVideoCache()->getNextTexture(m_strFileName.c_str());

		CCLOG("Trying to decode(total = %d, current = %d)", m_frames, m_frame_count);

		if (texture == NULL)
		{
			stopVideo();
			return;
		}

		if(texture)
		{
			m_frame_count++;
			setTexture(texture);
			if(m_frame_count > m_frames)
			{
				m_frame_count = 1; 
				if (m_videoEndCallback) {  
					m_videoEndCallback();
				}
			}
			CCLOG("Trying to release(total = %d, current = %d)", m_frames, m_frame_count);
			texture->release();

			CCLOG("Finished decode released(total = %d, current = %d)", m_frames, m_frame_count);
		}
		else
		{
			CCLOG("Fail CCVideoLayer::update filename = %s , frame = %d", m_strFileName.c_str(),m_frame_count);
		}

		if (m_frame_count >= m_frames - 1)
		{
			stopVideo();
		}
	}
	catch (long e)
	{
		CCLOG("exception code : %d", e);
	}
}  

void CCVideoLayer::registerPlayScriptHandler(int nHandler)
{
    unregisterPlayScriptHandler();
    m_playEndScriptHandler = nHandler;
    LUALOG("[LUA] Add CCVideoLayer event handler: %d", m_playEndScriptHandler);
}

void CCVideoLayer::unregisterPlayScriptHandler(void)
{
    if (m_playEndScriptHandler)
    {
        m_playEndScriptHandler = 0;
    }
}

void CCVideoLayer::removeTextures()
{
	CCVideoDecoderCache::sharedVideoCache()->removeVideo(m_strFileName.c_str());
}
  
void CCVideoLayer::setVideoEndCallback(std::function<void(void)> func)  
{  
    m_videoEndCallback = func;  
}  
  
  
NS_CC_END  