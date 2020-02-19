
local def                   = require(s_require.def)
--local nodes                 = require(s_require.nodes)

local sound                 = require(s_require.sound)


local TNTBigWinNode = class("TNTBigWinNode", function()
    return cc.Layer:create()
end)

-----------------------------------------------------------
--BigWin效果
--

local BigWinPos      = {{682,618},{682,618},{680,641},{680,641},{680,651}}
local BigWinWarn1Pos  = {{181,618},{181,618},{133,618},{133,618},{118,618}}
local BigWinWarn2Pos  = {{1179,618},{1179,618},{1226,618},{1226,618},{1243,618}}
local BigWinPicName  = {"BigWin1.png","BigWin2.png","BigWin3.png","BigWin4.png","BigWin5.png",}
local BigWinWPicName  = {"BigWinW1.png","BigWinW2.png","BigWinW3.png","BigWinW4.png","BigWinW5.png",}
local actionsBigWin  = 
    {
        warn          = {name="Warn",   fix="png", count=9,   start=0, speed = 0.07},
        colour1       = {name="bigwin/Blue_",  fix="png", count=17,  start=0, speed = 0.05},
        colour2       = {name="bigwin/Green_", fix="png", count=17,  start=0, speed = 0.05},
        colour3       = {name="bigwin/Red_",   fix="png", count=17,  start=0, speed = 0.05},
        colour4       = {name="bigwin/White_", fix="png", count=17,  start=0, speed = 0.05},
    } 

local areaFire = {{100,100},{1208,519}} -- 烟火播放区域


-----------------------------------------------------------

function TNTBigWinNode.create()
    local bigNode = TNTBigWinNode.new()
    bigNode:init()
    return bigNode
end


function TNTBigWinNode:ctor()

end

function TNTBigWinNode:init()

    local csdPath = cc.FileUtils:getInstance():fullPathForFilename( "Data/Common/BigWin/BigWinNode.csb")
    local nodeHat = cc.CSLoader:createNode(csdPath)

    self.nodeBigWin                 = nodeHat:getChildByName("Node_BigWin")
    self.sprWarn = {}
    self.sprWarn[1]            = self.nodeBigWin:getChildByName("sprWarn1")
    self.sprWarn[2]            = self.nodeBigWin:getChildByName("sprWarn2")
    self.sprWarn[1]:setScale(13)
    self.sprWarn[2]:setScale(13)
    self.sprBigWin             = self.nodeBigWin:getChildByName("sprBigWin")
    self.sprBigWinW            = self.nodeBigWin:getChildByName("sprBigWinW")
    self.nodeEffect            = self.nodeBigWin:getChildByName("node_Effect")

    self.sprEffect = {}
    self.sprEffect[1]          = self.nodeEffect:getChildByName("sprEffect1")
    self.sprEffect[2]          = self.nodeEffect:getChildByName("sprEffect2")
    self.sprEffect[3]          = self.nodeEffect:getChildByName("sprEffect3")
    self.sprEffect[4]          = self.nodeEffect:getChildByName("sprEffect4")
    self.sprEffect[5]          = self.nodeEffect:getChildByName("sprEffect5")
    self.sprEffect[6]          = self.nodeEffect:getChildByName("sprEffect6")
    self.sprEffect[7]          = self.nodeEffect:getChildByName("sprEffect7")
    self.sprEffect[8]          = self.nodeEffect:getChildByName("sprEffect8")
    self.sprEffect[9]          = self.nodeEffect:getChildByName("sprEffect9")
    self.sprEffect[10]         = self.nodeEffect:getChildByName("sprEffect10")
    self.sprEffect[11]         = self.nodeEffect:getChildByName("sprEffect11")
    self:addChild(nodeHat)

    self.animates={}
    for k,v in pairs(actionsBigWin) do    
        local frames = {} 
        local tex       
        for i=1, v.count do
            tex=string.format("%s%02d.%s",v.name, i+v.start, v.fix)      
            frames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame(tex)
            print(tex,frames[i])
        end
        local animation = cc.Animation:createWithSpriteFrames(frames, v.speed)
        self.animates[k] = cc.Animate:create(animation);
        self.animates[k]:retain()
    end
    self:setVisible(false)

   --[[ local function eventHandler(tag)
        print(tag)
        if tag == "exit" then
            for k, v in pairs(self.animates) do
                if v==nil then
                   print()
                end
                if v ~= true then
                    v:release()
                end  
            end
        end
    end
    self:registerScriptHandler(eventHandler)--]]
end




--显示bigWin效果 style 1 bigWin,2superBigWin,3UltraBigWin,4,megaBigWin,5UltramegaBigWin
function TNTBigWinNode:showBigWin(bShow,style,autoKill)
    
    --self:setVisible(bShow)
    self.nodeBigWin:setVisible(bShow)
    self.sprBigWin:setVisible(bShow)
    self.sprBigWinW:setVisible(bShow)
    self.sprWarn[1]:setVisible(bShow)
    self.sprWarn[2]:setVisible(bShow)
    self.nodeEffect:setVisible(false)
    if bShow then
        if style<=0 then
            return
        end
        self.sprBigWin:setSpriteFrame(BigWinPicName[style])
        self.sprBigWinW:setSpriteFrame(BigWinWPicName[style])
        self.sprBigWin:setPosition(BigWinPos[style][1],BigWinPos[style][2])
        self.sprBigWinW:setPosition(BigWinPos[style][1],BigWinPos[style][2])
        self.sprWarn[1]:setPosition(BigWinWarn1Pos[style][1],BigWinWarn1Pos[style][2])
        self.sprWarn[2]:setPosition(BigWinWarn2Pos[style][1],BigWinWarn2Pos[style][2])
--        self.sprWarn[1]:setScale(1.5)
--        self.sprWarn[2]:setScale(1.5)
        local scaleTo1 = cc.ScaleTo:create(0.35,3.5)
        local scaleBack1 = cc.ScaleTo:create(0.35,3)
        local rep1 = cc.RepeatForever:create(cc.Sequence:create(scaleTo1,scaleBack1))
        self.sprWarn[1]:runAction(rep1)
        self.sprWarn[2]:runAction(rep1:clone())
        self.sprWarn[1]:runAction(cc.RepeatForever:create(self.animates["warn"]:clone()))
        self.sprWarn[2]:runAction(cc.RepeatForever:create(self.animates["warn"]:clone()))     
        local scaleTo2 = cc.ScaleTo:create(0.4,2.5)--(0.35,1.5)
        local scaleBack2 = cc.ScaleTo:create(0.4,0.5)--(0.35,1)
        local rep2 = cc.RepeatForever:create(cc.Sequence:create(scaleTo2,scaleBack2))
        local scaleTo3 = cc.ScaleTo:create(0.8,2.5)--(0.7,2.5)
        local rep3 = cc.RepeatForever:create(cc.Sequence:create(scaleTo3,cc.CallFunc:create(function()
            self.sprBigWinW:setScale(0.5)--(1)
            self.sprBigWinW:setOpacity(255)
            self.sprBigWinW:runAction(cc.FadeOut:create(0.8))
        end))) 
        local fade = cc.FadeOut:create(0.8)
        self.sprBigWin:runAction(rep2) 
        --self.sprBigWinW:setVisible(false)
        self.sprBigWinW:setScale(0.5)
        self.sprBigWinW:runAction(rep3) 
        self.sprBigWinW:setOpacity(255)
        self.sprBigWinW:runAction(fade)     
        --放烟火
        if style>0 then
            --sound.playEffect(def.sound.AztecBigWin,false)
            self.nodeEffect:setVisible(true)
            local function firePlay()
                local count = math.random(1,7)
                for i =1 ,table.getn(self.sprEffect) do
                    if self.sprEffect[i]:getNumberOfRunningActions() == 0 then
                        local colour = math.random(1,4)
                        local x =  math.random(areaFire[1][1],areaFire[2][1])
                        local y =  math.random(areaFire[1][2],areaFire[2][2])
                        self.sprEffect[i]:runAction(self.animates["colour"..colour]:clone())
                        self.sprEffect[i]:setVisible(true)
                        self.sprEffect[i]:setPosition(x,y)
                        count = count-1
                        if count==0 then
                            break
                        end
                    end
                end
            end
            --每隔0.5秒放一次
            local repTime = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(firePlay),cc.DelayTime:create(0.3)))
            self.nodeEffect:runAction(repTime)
        end
        sound.playEffect(def.sound.AztecbWinEfx,false)
        local function PlaySound()
            -- if style == 1 then
            --     sound.playEffect(def.sound.AztecbWin1BG,true) 
            -- elseif style == 2 then
            --         sound.playEffect(def.sound.AztecBigWin,false)
            --     sound.playEffect(def.sound.AztecbWin2BG,true)
            -- elseif style >= 3 then
            --         sound.playEffect(def.sound.AztecBigWin,false)
            --     sound.playEffect(def.sound.AztecbWin3BG,true)
            -- end
            --统一声音 警报特效循环轮流播放
            local function playBigWinSound()
                sound.playEffect(def.sound.AztecBigWin,false)
                sound.stopEffect(def.sound.AztecbWin3BG)
            end
            local function playBigWin3Sound()
                sound.stopEffect(def.sound.AztecBigWin)
                sound.playEffect(def.sound.AztecbWin3BG,false)
            end
            local repPlaySound = cc.RepeatForever:create(cc.Sequence:create(cc.CallFunc:create(playBigWinSound),cc.DelayTime:create(3.8),cc.CallFunc:create(playBigWin3Sound),cc.DelayTime:create(13.1)))
            self:runAction(repPlaySound)
        end
        self:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(PlaySound)))
        if type(autoKill)=="number" and autoKill>0 then
            print("autoKill.."..autoKill)
            self:runAction(cc.Sequence:create(cc.DelayTime:create(autoKill),cc.CallFunc:create(function() self:showBigWin(false) end)))
        end
    else
        self.sprBigWin:stopAllActions()
        self.sprBigWinW:stopAllActions()
        self.sprWarn[1]:stopAllActions()
        self.sprWarn[2]:stopAllActions()
        self.nodeEffect:setVisible(false)
        self:stopAllActions()
        for i =1 ,table.getn(self.sprEffect) do
            self.sprEffect[i]:stopAllActions()
            self.sprEffect[i]:setVisible(false)
        end
        if self:isVisible() then
            sound.playEffect(def.sound.AztecTNTReact,false)
        end
        sound.stopEffect(def.sound.AztecBigWin)
        sound.stopEffect(def.sound.AztecbWinEfx)
        sound.stopEffect(def.sound.AztecbWin1BG) 
        sound.stopEffect(def.sound.AztecbWin2BG)
        sound.stopEffect(def.sound.AztecbWin3BG)
    end
    self:setVisible(bShow)
end




function TNTBigWinNode:leave()
    for k, v in pairs(self.animates) do
        if v ~= true then
            v:release()
       end
    end
end

return TNTBigWinNode