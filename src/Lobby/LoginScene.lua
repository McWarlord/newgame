local LoginScene = class("LoginScene",function()
    return cc.Scene:create()
end)

--loginScene = nil
local mainScene --主场景
local text      --提示
local loginning = false

--local dlg = require("utils.ModalDlg")

local sound = require("utils.GameSound")
sound.load("")

--local hint
--isDebug = true
local languages = {"En", "Thai"}


local toFillAcc     =   true   

local isLoginSignup =   false       --true: login, false: signup
local isAlreadySent =   false       --true: Already sent request to connect to server

--local newInput = require("Public.PinUIInput")

function LoginScene.create()
    local director = cc.Director:getInstance()
    --turn on display FPS
    director:setDisplayStats(false)

--    cc.Director:getInstance():getTextureCache():removeTextureForKey("Data/Lobby/Login.png")
    local scene = LoginScene.new()
    scene:init(scene)

    return scene
end
--加载需要预加载的文件

function LoginScene:init(scene)
    local touchLayer = cc.Layer:create()
    touchLayer:setAnchorPoint(0, 0)
    touchLayer:setPosition(0, 0)
    touchLayer:setZOrder(10)
    scene:addChild(touchLayer)

    local csdPath = cc.FileUtils:getInstance():fullPathForFilename("Data/Login/Login.csb")
    print(csdPath)
    mainScene = cc.CSLoader:createNode(csdPath)
    
    self.btnPlay1 = mainScene:getChildByName("Button_Play1")
    self.btnPlay2 = mainScene:getChildByName("Button_Play2")
    
    local tvPlayer1 = cc.TVPlayer:create("adumbrates/1112.flv")
    mainScene:addChild(tvPlayer1)
    tvPlayer1:setPosition(680, 384)
    tvPlayer1:playVideo()

--    local tvPlayer2 = cc.TVPlayer:create("adumbrates/1111.flv")
--    mainScene:addChild(tvPlayer2)
--    tvPlayer2:setPosition(680, 384)
--    tvPlayer2:playVideo()

--    local cursorTextField = cc.CursorTextField:create(mainScene, "Hello", "Arial", 30)
--    cursorTextField:setAnchorPoint(0, 0)
--    cursorTextField:setInputWidth(200);
--	cursorTextField:setPosition(680, 384)
--    
--    local strVal = cursorTextField:getInputText()
--	mainScene:addChild(cursorTextField)
    local function onClickBtn1(ref, type)
        if(ccui.TouchEventType.ended == type) then
            sound.playEffect(sound.soundid.button, false, true)
            tvPlayer1:removeTextures()
            local videoName = string.format("adumbrates/1111.flv")
            tvPlayer1:initAnother(videoName)
            tvPlayer1:playVideo()
            sound.playEffect(sound.soundid.sndinto, true)
        end
    end

    local function onClickBtn2(ref, type)
        if(ccui.TouchEventType.ended == type) then
            sound.playEffect(sound.soundid.button, false, true)
            tvPlayer1:removeTextures()
            local videoName = string.format("adumbrates/1112.flv")
            tvPlayer1:initAnother(videoName)
            tvPlayer1:playVideo()
            sound.playEffect(sound.soundid.sndinto, true)
        end
    end
    self.btnPlay1:addTouchEventListener(onClickBtn1)
    self.btnPlay2:addTouchEventListener(onClickBtn2)
    scene:addChild(mainScene)
end

--构造函数
function LoginScene:ctor()
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.schedulerID = nil
    local function eventHandler(tag)
        if tag == "exit" then
--            cc.Director:getInstance():getEventDispatcher():removeEventListener(listenner)
            --
--            cc.Director:getInstance():getTextureCache():removeTextureForKey("Data/Lobby/Login.png")
--            cc.Director:getInstance():getTextureCache():removeTextureForKey("Data/Lobby/CN/LoginCN.png")
            --package.loaded["LobbyData"] = nil
            --
            package.loaded[LobbyDir .. "LoginScene"] = nil
        end
    end
    self:registerScriptHandler(eventHandler)
    
end

function LoginScene:leave()
end

return LoginScene
