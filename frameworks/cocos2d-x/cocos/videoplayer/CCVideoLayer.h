#ifndef __CCVIDEO_LAYER_H__
#define __CCVIDEO_LAYER_H__


#include "cocos2d.h"  
#include <string>    
#ifdef __APPLE__  
#include <tr1/functional>  
namespace std {  
    namespace tr1 {}  
    using namespace tr1;  
    using tr1::function;  
}  
//using namespace std::tr1;  
#else  
#include <functional>  
#endif  

  
NS_CC_BEGIN  
  
class CC_DLL CCVideoLayer : public Sprite  
{  
public:  
    static CCVideoLayer* create(const char* path);


    CCVideoLayer();  
    virtual ~CCVideoLayer();  
      
    bool init(const char* path);  
	void playVideo();
    void stopVideo(void); 
    void seek(int frame);  
    void update(float dt);

	bool getState();
	void removeTextures();
	void initAnother(const char* path);
      
    void registerPlayScriptHandler(int nHandler);
    void setVideoEndCallback(std::function<void()> func);    

private:

	void unregisterPlayScriptHandler();

	unsigned int	m_width;  
    unsigned int	m_height;
    unsigned int	m_frames; 
    double			m_frameRate;  

    int				m_playEndScriptHandler;
    unsigned int	m_frame_count;
    std::string		m_strFileName;

    bool					m_enableTouchEnd;  
    std::function<void()>	m_videoEndCallback;
	bool					m_bIsPlaying;
};  
  
  
NS_CC_END

#endif //__CCVIDEO_LAYER_H__