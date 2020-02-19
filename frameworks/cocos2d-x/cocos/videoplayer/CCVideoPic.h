#pragma once

#include "cocos2d.h"
NS_CC_BEGIN

class CCVideoPic : public CCObject
{
public:
	CCVideoPic();
	bool init(const char *path, int frame, unsigned int width, unsigned int height, unsigned char* data, unsigned int lineSize);
	virtual ~CCVideoPic();
	char m_path[256];
	int m_frame;
	int m_width;
	int m_height;
	int m_lineSize;
	unsigned char* m_pPicture;
};

NS_CC_END