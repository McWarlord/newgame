/**
 * 视频纹理缓存
 * @author leoluo<luochong1987@gmail.com>
 */
#ifndef __CCVIDEOTEXTURE_CACHE_H__
#define __CCVIDEOTEXTURE_CACHE_H__

#include "cocos2d.h"
#include <string>
#include "CCVideoDecode.h"
#include "CCVideoPic.h"
 
NS_CC_BEGIN
class CCVideoDecoderCache : public CCObject
{
	protected:
		CCDictionary* m_pVideoDecodes;

	public:
		CCVideoDecoderCache();
		virtual ~CCVideoDecoderCache();

		static CCVideoDecoderCache * sharedVideoCache();
		static void purgeSharedTextureCache();
		
		CCTexture2D* addImageWidthData(const void *data, unsigned int lineSize, CCTexture2DPixelFormat pixelFormat, unsigned int pixelsWide, unsigned int pixelsHigh, const CCSize& contentSize);
		CCTexture2D* getNextTexture(const char *filename);
	    void	     removeAllTextures();
	    void		 removeTexture(const char *filename, int frame);

	    CCVideoDecode* addVideo(const char *path);
	    void removeVideo(const char *path);

};
NS_CC_END
#endif //__CCVIDEOTEXTURE_CACHE_H__

