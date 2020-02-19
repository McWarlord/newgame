#include "CCVideoPic.h"

NS_CC_BEGIN

CCVideoPic::CCVideoPic()
{
	m_pPicture = NULL;
}

CCVideoPic::~CCVideoPic()
{
	if (m_pPicture)
	{
		CCLOG("trying to free", "");
		free(m_pPicture);
		CCLOG("finished to free", "");
	}
}

bool CCVideoPic::init(const char *path, int frame, unsigned int width, unsigned int height, unsigned char* data, unsigned int lineSize)
{
	//unsigned char* data = pic.data[m_videoStream];
	m_width = width;
	m_height = height;
	m_frame = frame;
	strcpy(m_path, path);
	m_lineSize = lineSize;
	unsigned int length = m_width * m_height * 4;
	m_pPicture = (unsigned char*) malloc(length);
	memcpy(m_pPicture, data, length);
	return true;
}

NS_CC_END