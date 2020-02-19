
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("../src")
cc.FileUtils:getInstance():addSearchPath("res")
cc.FileUtils:getInstance():addSearchPath("../res")
cc.FileUtils:getInstance():addSearchPath("../")
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Assets/src")
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Assets/res")
cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."Assets")
CC_USE_DEPRECATED_API = true
require "config"
require "cocos.init"
LobbyDir = "Lobby."
require("json")
language = "En"
s_updateEnabled = false
local lastError = ""

-- cclog
local cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    local platform = cc.Application:getInstance():getTargetPlatform()
    if lastError ~= msg and cc.PLATFORM_OS_ANDROID == platform then
        local luaj = require "cocos.cocos2d.luaj"
        local log = string.format("%s\n%s",msg,debug.traceback())
        --local nowVer = getVersion()
        --if nowVer > "1.1" then
        --    --luaj.callStaticMethod("org.cocos2dx.lua.MyApplication","onLuaCrashed",{log},"(Ljava/lang/String;)V")
        --end
    end
    lastError = msg
    return msg
end

local function init()
--    local pngPath = cc.FileUtils:getInstance():fullPathForFilename(string.format("Data/%s/Common/Default.png", language))
--    local tex = cc.Director:getInstance():getTextureCache():addImage(pngPath)
--    local rect = cc.rect(0,0,tex:getPixelsWide(),tex:getPixelsHigh())
--    local frame = cc.SpriteFrame:createWithTexture(tex, rect)
--    cc.SpriteFrameCache:getInstance():addSpriteFrame(frame,"Data/Common/Default.png")
    
--    local lan = cc.LocalStorage:localStorageGetItem("Language")
--    if lan == "" or lan == nil then
--        language = "En"
--    else
--        language = lan
--    end

    language = "En"
end

local function doUpdate()
    local function onEnterGame(event)
        cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners("GameUpdate")
        local scene = require(LobbyDir .. "LoginScene")
        loginScene = scene.create()
        cc.Director:getInstance():replaceScene(loginScene)
    end
    cc.FileUtils:getInstance():purgeCachedEntries()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create("GameUpdate",onEnterGame)
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

local function onRecieveIP()
    local scene = require(LobbyDir .. "LoginScene")
    loginScene = scene.create()
    init()
    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(loginScene)
    else
        cc.Director:getInstance():runWithScene(loginScene)
    end
end

local function main()
	
	local platform = cc.Application:getInstance():getTargetPlatform()
    cc.Device:setKeepScreenOn(true)	
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
	
--	local sStooage = cc.FileUtils:getInstance():getWritablePath()
--    local sDBStooage = sStooage .. "Lobby.db"
--    cc.LocalStorage:localStorageInit(sDBStooage)

    local arch
    if (os.getenv"os" or ""):match"^Windows" then
       print"Your system is Windows"
       arch = os.getenv"PROCESSOR_ARCHITECTURE"
    else
       print"Your system is Linux"
       arch = io.popen"uname -m":read"*a"
    end
    print("arch : " .. arch)
    if (arch or ""):match"64" then
       print"Your system is 64-bit"
    else
       print"Your system is 32-bit"
    end

	cc.FileUtils:getInstance():addSearchPath(string.format("%s%s", sStooage, "src/"), true)
    cc.FileUtils:getInstance():addSearchPath(string.format("%s%s", sStooage, "res/"), true)	

	require (LobbyDir .. "LobbyGlobal")
    require "utils.print_r"
	-- initialize director
    local director = cc.Director:getInstance()		

	--turn on display FPS
    director:setDisplayStats(false)
    director:setAnimationInterval(1.0 / 30)
    math.randomseed(os.time())

	--for test on windows
	local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("The Ocean", cc.rect(0, 0,1360, 768))  -- 768,1360
        director:setOpenGLView(glview)
    end
    glview:setDesignResolutionSize(1360, 768, 0)
	if platform == cc.PLATFORM_OS_WINDOWS then
		cc.Director:getInstance():getOpenGLView():setFrameSize(1360, 768)
	end
	
	onRecieveIP()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
