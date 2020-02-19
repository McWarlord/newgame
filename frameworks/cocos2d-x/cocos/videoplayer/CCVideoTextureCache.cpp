/**
 * 视频材质缓存类
 */

#include "CCVideoTextureCache.h"
#include "CCVideoDecode.h"
#include <sstream>
#include <queue>

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8)
//#include <pthread.h>
#else
#include "CCPThreadWinRT.h"
#include <ppl.h>
#include <ppltasks.h>
using namespace concurrency;
#endif


using namespace std;
NS_CC_BEGIN

static CCVideoDecoderCache *g_sharedVideoCache = NULL;
bool g_notNull = false;

static void *videoDecode(void *data)
{
    CCVideoDecode *p = (CCVideoDecode *) data;
    if(p)
    {
        while(p->decode())
        {
            //sleep ?
        }
    }
    return 0;
}



CCVideoDecoderCache * CCVideoDecoderCache::sharedVideoCache()
{
	if (!g_sharedVideoCache)
    {
		g_sharedVideoCache = new CCVideoDecoderCache();
    }
	return g_sharedVideoCache;
}

void CCVideoDecoderCache::purgeSharedTextureCache()
{
	CC_SAFE_RELEASE_NULL(g_sharedVideoCache);
}


CCVideoDecoderCache::CCVideoDecoderCache()
{
	CCAssert(g_sharedVideoCache == NULL, "Attempted to allocate a second instance of a singleton.");
    m_pVideoDecodes = new CCDictionary();
}

CCVideoDecoderCache::~CCVideoDecoderCache()
{
    CCLOGINFO("cocos2d: deallocing CCVideoDecoderCache.");
    CC_SAFE_RELEASE(m_pVideoDecodes);
}


CCVideoDecode* CCVideoDecoderCache::addVideo(const char *path)
{
    CCVideoDecode* pVideoDecode = (CCVideoDecode*)m_pVideoDecodes->objectForKey(path);
    if(!pVideoDecode)
    {
        pVideoDecode = new CCVideoDecode();
        if(pVideoDecode->init(path))
        {
            m_pVideoDecodes->setObject(pVideoDecode, path);
            pVideoDecode->release();
        }
        else
        {
            CCLOGERROR("CCVideoDecode init error in CCVideoTextureCache");
            return NULL;
        }
    }
    else
    {
        pVideoDecode->retain();
    }

    return pVideoDecode;
}



/**
 *  图片转纹理
 */
CCTexture2D* CCVideoDecoderCache::getNextTexture(const char *filename)
{

	CCVideoDecode* pVideoDecode = (CCVideoDecode*)m_pVideoDecodes->objectForKey(filename);
	if (pVideoDecode == NULL)
		return NULL;

	CCLOG("CCVideoDecoderCache::Trying to decode", "");
	CCVideoPic* pVideoPic = pVideoDecode->decode();
	CCLOG("CCVideoDecoderCache::Decoded and Trying to add to texture", "");

	if (pVideoPic == NULL)
	{
		CCLOG("video pic is NULL");
		return NULL;
	}
	try
	{
		CCLOG("linesize %d, width %d, height %d", pVideoPic->m_lineSize,
			pVideoPic->m_width, pVideoPic->m_height);

		CCTexture2D* texture = addImageWidthData(pVideoPic->m_pPicture, pVideoPic->m_lineSize,
			kCCTexture2DPixelFormat_RGBA8888,
			pVideoPic->m_width, pVideoPic->m_height,
			CCSize(pVideoPic->m_width, pVideoPic->m_height));

		CCLOG("CCVideoDecoderCache::Trying to release", "");
		pVideoPic->release();
		CCLOG("CCVideoDecoderCache::Released", "");
		return texture;
	}
	catch (long e)
	{
		CCLOG("Exception is caused bu %d", e);
	}
	return NULL;
}

void CCVideoDecoderCache::removeVideo(const char *path)
{
    CCVideoDecode* pVideoDecode = (CCVideoDecode*)m_pVideoDecodes->objectForKey(path);
    if(pVideoDecode)
    {
        m_pVideoDecodes->removeObjectForKey(path);
		g_notNull = true;
    }
}


    	
CCTexture2D* CCVideoDecoderCache::addImageWidthData(const void *data, unsigned int lineSize, CCTexture2DPixelFormat pixelFormat, unsigned int pixelsWide, unsigned int pixelsHigh, const CCSize& contentSize)
{
    CCTexture2D * texture = NULL;
	texture = new CCTexture2D();
    if( texture && 
		texture->initWithData(data, lineSize * pixelsHigh, pixelFormat, pixelsWide, pixelsHigh, contentSize))
    {
	}
	else
    {
        CCLOG("cocos2d: Couldn't create texture for file:%s in CCVideoTextureCache", "");
    }
	return texture;
}
NS_CC_END


