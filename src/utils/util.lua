util={}
--属性
util.logLevel={}
util.logLevel.trace=1
util.logLevel.debug=2
util.logLevel.info=3
util.logLevel.warn=4
util.logLevel.error=5
util.curLevel=0
util.visibleSize = cc.Director:getInstance():getVisibleSize()
util.origin = cc.Director:getInstance():getVisibleOrigin()
util.winSize=cc.Director:getInstance():getWinSize();

util.isTextDebug=false
util.txt_Debug=nil
local msgDebug=""
local isAddDebug=false
local scroll_view=nil
if util.isTextDebug==true then
--    local sv= ccui.ScrollView:create()
--    sv:setAnchorPoint(0,1)
--    --sv:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)--背景颜色
--    sv:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)--背景颜色
--    sv:setClippingEnabled(true)--启用裁剪
--    sv:setPosition(cc.p(0,600)) 
--    sv:setContentSize(cc.size(800,600))
--    sv:setDirection(2)-- 设置滑动的方向   0 是水平方向     1是垂直方向    2 是水平垂直都可以
--    scroll_view=sv

    local txt_Debug=cc.LabelTTF:create("debug","fonts/arial.ttf",12)       
    txt_Debug:setAnchorPoint(0,1)
    txt_Debug:setHorizontalAlignment(0)
    txt_Debug:setPosition(0,500)
    txt_Debug:setColor(cc.c3b(255, 255, 255))
    --txt_Debug:enableStroke(cc.c3b(0,0,255),2)--卡
    util.txt_Debug=txt_Debug
    util.txt_Debug:retain()
    --scroll_view:addChild(txt_Debug)
    --scroll_view:retain()
end
function util.showAt(scene)
    if util.isTextDebug~=true then return end
    if isAddDebug==true then
        util.txt_Debug:removeFromParent()
        isAddDebug=false
    end
    if scene~=nil then
        scene:addChild(util.txt_Debug)
        isAddDebug=true
    end
end
function util.toogle()
    if util.txt_Debug:isVisible() then
        util.txt_Debug:setVisible(false)
    else
        util.txt_Debug:setVisible(true)
    end
end

function util.append(msg)
    if util.isTextDebug~=true then return end
    if msg~=nil then
        msgDebug=string.format("%s\n%s",msg,msgDebug)
        util.txt_Debug:setString(msgDebug)
    end
end

local platform = cc.Application:getInstance():getTargetPlatform()
local luaj =nil
if cc.PLATFORM_OS_ANDROID == platform then
    luaj = require "cocos.cocos2d.luaj"    
end

local retains={}
function util.retain(obj)
    if obj~=nil then
        obj:retain()
        retains[#retains+1]=obj
    end
end

function util.release()
    for i=1,#retains do
        retains[i]:release()
    end
    retains={}
end
--方法
--设置节点的位置,x y是传统坐标系的坐标
function util.setPosition(node,x,y)
    local nx=node:getContentSize().width/2+x
    local ny=util.winSize.height-(node:getContentSize().height/2+y)
    node:setAnchorPoint(0.5,0.5)
    node:setPosition(nx,ny)
    --print("setPosition to "..node:getPositionX().." "..node:getPositionY())
end

--flash的坐标x转换到cocos的,注册点0,1
function util.getPosX(x)
    return util.winSize.width-x
end

--flash的坐标y转换到cocos的,注册点0,1
function util.getPosY(y)
    return util.winSize.height-y
end

function util.addPosY(node,dy)
    local y0=node:getPositionY()
    node:setPositionY(y0+dy)
end
function util.addPosX(node,dx)
    local x0=node:getPositionX()
    node:setPositionX(x0+dx)
end
--
--异步载入纹理大图png
function util.addPlistAsync(filename,callback)
    local function loadImageCallBack(texture)

        print("load png sucess:"..filename)
        --cc.FileUtils:getInstance()
        --cc.SpriteFrameCache:getInstance():addSpriteFramesWithFileContent(filename..".plist",texture);
        --argument #3 is 'cc.Texture2D'; 'string' expected. 无视这个错误提示
        cc.SpriteFrameCache:getInstance():addSpriteFrames(filename..".plist",texture);
        util.trace("addSpriteFrames sucess:"..filename)
        callback(texture)
    end
    local pngPath=cc.FileUtils:getInstance():fullPathForFilename(filename..".png")
    cc.Director:getInstance():getTextureCache():addImageAsync(pngPath,loadImageCallBack)
end

--同步步载入纹理大图
function util.addPlistSync(filename,callback)
    local pngPath=cc.FileUtils:getInstance():fullPathForFilename(filename..".png")
    local plistPath = cc.FileUtils:getInstance():fullPathForFilename(filename .. ".plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plistPath, pngPath)
    if callback~=nil then
        callback()
    end
end

--同步步载入图片
function util.addPictureSync(filename)
    local picPath=cc.FileUtils:getInstance():fullPathForFilename(filename)
    local tex=cc.Director:getInstance():getTextureCache():addImage(picPath)
    if tex==nil then
        util.trace("addPictureSync error"..filename)
    end
    local rect = cc.rect(0,0,tex:getPixelsWide(),tex:getPixelsHigh())
    local frame = cc.SpriteFrame:createWithTexture(tex, rect)
    cc.SpriteFrameCache:getInstance():addSpriteFrame(frame,filename)
end

function util.createNode(filename)
    local csbPath = cc.FileUtils:getInstance():fullPathForFilename(filename)
    return cc.CSLoader:createNode(csbPath)
end

--设置Sprite (0.5,0.5)显示对象居中,偏移 x(右正) y(下是正)
function util.center(sprite,x,y)
    if x==nil then x=0 end
    if y==nil then y=0 end
    sprite:setPosition(util.winSize.width/2+x,util.winSize.height/2+y)
end
function util.print_android(text,tag)
    if text==nil then return end
    if luaj~=nil then
        if tag==nil then tag="testapp" end
        luaj.callStaticMethod("android.util.Log","d",{tag,text},"(Ljava/lang/String;Ljava/lang/String;)I")
    else
        print(text)
    end
    util.append(text)
end
function util.trace(...)
    if util.curLevel<=util.logLevel.trace then
        util.print_android(string.format(...))
    end
end

function util.debug(...)
    if util.curLevel<=util.logLevel.debug then
        util.print_android(string.format(...))
    end
end

function util.info(...)
    if util.curLevel<=util.logLevel.info then
        print(string.format(...))
    end
end

function util.error(...)
    if util.curLevel<=util.logLevel.error then
        util.print_android(string.format(...))
    end
end

function util.addBMFont(parent,fontName,x,y,ax,ay)
     local txt=util.newBMFont(fontName,x,y,ax,ay)
     parent:addChild(txt)
     return txt
end

function util.newBMFont(fontName,x,y,ax,ay)
     local txt=cc.Label:createWithBMFont(fontName,"")
     if ax~=nil then
        txt:setAnchorPoint(ax,ay)
     end
    if x~=nil then
         txt:setPosition(x,y)
    end
     return txt
end

function util.addChild(parent,node,x,y,ax,ay,name)
    parent:addChild(node)
    if ax~=nil then
        node:setAnchorPoint(ax,ay)
    end
    node:setPosition(x,y)
    if name~=nil then
        node:setName(name)
    end
end

function util.addSprite(parent,pngName,x,y,ax,ay,name)
    local sp=util.sprite(pngName,x,y,name)
    if ax~=nil then
        sp:setAnchorPoint(ax,ay)
    end
     if x~=nil then
         sp:setPosition(x,y)
    end
     parent:addChild(sp)
     return sp
end

function util.addNode(parent,name,x,y,ax,ay)
    local node=cc.Node:create()
    if name~=nil then node:setName(name) end
    if ax~=nil then
        node:setAnchorPoint(ax,ay)
    end
    if x~=nil then
        node:setPosition(x,y)
    end
    if parent~=nil then
        parent:addChild(node)
    end
    return node
end

function util.newSprite(pngName,x,y,name)
    return util.sprite(pngName,x,y,name)
end
--创建精灵
function util.sprite(pngName,x,y,name)
    local sprite
    if  type(pngName)=="string" then
        sprite=cc.Sprite:createWithSpriteFrameName(pngName)
    else
        sprite=cc.Sprite:createWithSpriteFrame(pngName)
    end
    
    --if x~=nil then util.setPosition(sprite,x,y) end
    if name~=nil then sprite:setName(name) end
--    util.retain(sprite)
    return sprite
end

--加一个裁剪区域
function util.addClipping(parent,x,y,clipRect,isShowBox)
      --遮罩
    local clip=cc.ClippingRectangleNode:create()
    --clip:setClippingRegion(cc.rect(0,0,w,h))
    clip:setClippingRegion(clipRect)
    clip:setPosition(x,y)
    --clip:setContentSize(w,h)
    if isShowBox==true then
        local boxSize = cc.size(clipRect.width, clipRect.height)
        -- 创建层颜色块，c4b,第一个参数是r，代表红色，第二个参数是g，代表绿色，第三个参数是b，代表蓝色，第四个参数是a,代表透明度
        local box = cc.LayerColor:create(cc.c4b(255,255,0,125))
        -- 设置锚点
        --box:setAnchorPoint(cc.p(0.5,0.5))
        -- 设置盒子大小
        box:setContentSize(boxSize)
        box:setPosition(clipRect.x,clipRect.y)
        clip:addChild(box)
    end
    if parent~=nil then
        parent:addChild(clip)
    end
    return clip
end

--创建一个动画对象
function util.newMoveClip(fps,frameFormat,from,to,positionXYs,loop,onFinished)
    local frames=util.buildFrames(nil,frameFormat,from,to)
    return util.newMoveClipByFrames(fps,frames,loop,onFinished,positionXYs)
end

function util.newMoveClipByFrames(fps,frames,loop,onFinished,positionXYs)
    local moveClip=MoveClip.create()
    moveClip:init(fps,frames,positionXYs,loop)
    moveClip:setFinishCall(onFinished)
    return moveClip
end

function util.buildFrames(frames,frameFormat,from,to)
    if type(frames)~="table" then
        frames={}
    end  
    local count=#frames
    if to>from then
        for i=from,to do
            count=count+1
            frames[count]=string.format(frameFormat,i)
        end
    else
        local name=from
        for i=to,from do
            count=count+1
            frames[count]=string.format(frameFormat,name)
            name=name-1
        end
    end

    return frames
end

--创建一个按钮
--name 名称
--textFmt纹理前缀 如Back_0%s.png
--disSome disabled与normal相同不
function util.newButton(name,textFmt,disSome,x,y,parent,ax,ay,isTouchEnable,clickHander)
    local normal=string.format(textFmt,1)
    local selected=string.format(textFmt,2)
    local disabled=normal
    if disSome~=true then
        disabled=string.format(textFmt,3)
    end
    local node=ccui.Button:create(normal,selected,disabled,ccui.TextureResType.plistType)
    node:setName(name)
    if ax~=nil then
        node:setAnchorPoint(ax,ay)
    end
    if x~=nil then
        node:setPosition(x,y)
    end
    if parent~=nil then
        parent:addChild(node)
    end
    if type(isTouchEnable)=="boolean" then
        node:setTouchEnabled(isTouchEnable)
    end
    if type(clickHander)=="function" then
        node:addTouchEventListener(clickHander)
    end
    return node
end
function util.loadButton(button,textFmt,disOther3)
    if button==nil then return end
    local normal=string.format(textFmt,1)
    local selected=string.format(textFmt,2)
    local disabled=normal
    if disOther3==true then
        disabled=string.format(textFmt,3)
    end
    button:loadTextures(normal, selected, normal, ccui.TextureResType.plistType)
end

function util.enableButton(btn,isEnable,isAlpha)
    btn:setEnabled(isEnable)
    if isAlpha==true then
        if isEnable==true then
            btn:setOpacity(255)
        else
            btn:setOpacity(100)
        end
    else
        btn:setBright(isEnable)
    end
end

--从自定义格式里创建自元素
function util.createChilds(parent,struct,nodes)
    local child
    for k,v in pairs(struct) do
        print("1+++",k,v,"+++")
        child=nil
        if v[1]=="txt" then
            child= cc.LabelTTF:create(v[3],v[4],v[5])
            child:setName(v[2])
            util.setPosition(child,v[6],v[7])
        elseif v[1]=="btn" then
            child=ccui.Button:create(v[3],v[4],v[5],ccui.TextureResType.plistType)
            child:setName(v[2])
            print(v==struct.btn_close)
            nodes[v]=child
            util.setPosition(child,v[6],v[7])
            local function onExitGame(target, type)
                print(tostring(target).."click"..type)
            end
            nodes[struct.btn_close]:addTouchEventListener(onExitGame)
        end
        if child~=nil then
            parent:addChild(child)
            nodes[v]=child
        end
    end

end

function util.removeFromParent(node)
    --    local p=node:getParent()
    --    p:removeChild(node)
    if node~=nil then
        node:removeFromParent()
    end
end


function util.setVisible(node,visible)
   if node~=nil then
        if visible~=nil then
            node:setVisible(visible)
         else
            node:setVisible(true)
        end
   end
end

function util.indexOf(list,element)
    for i=1,#list do
        if list[i]==element then return i end
    end
    return -1
end

--加入一个元素到队列尾部 无重复
function util.push(list,element)
    local i=util.indexOf(list,element)
    if i~=-1 then
        return i
    end
    i=#list+1
    list[i]=element
    return i
end

function util.remove(list,element)
    local index= util.indexOf(list,element)
    if index~=-1 then
        table.remove(list,index)
    end
    return index
end

local watchTime
--是不是开始计时啦
local isStartWatch=false
function util.startWatch()
    if isStartWatch then util.trace("-----------startWatch Error------------") end
    watchTime=os.time()
    isStartWatch=true
end

function util.stopWatch(title)
    if not isStartWatch then util.trace("-----------startWatch Error------------") end
    local endTime=os.time()
    isStartWatch=false
    util.trace("-----------startWatch Result------------")
    util.trace(title.."------------------"..tostring(endTime-watchTime).."(s)----------")
    util.trace("----------------------------------------")
end


--lua 字符串分割函数
function util.split(str, split_char,isNum)
    local sub_str_tab = {};
    local pos
    while (true) do
        pos = string.find(str, split_char);
        if (not pos) then
            size_t = table.getn(sub_str_tab)
            table.insert(sub_str_tab,size_t+1,str);
            break;
        end

        local sub_str = string.sub(str, 1, pos - 1);
        local size_t = table.getn(sub_str_tab)
        table.insert(sub_str_tab,size_t+1,sub_str);
        local t = string.len(str);
        str = string.sub(str, pos + 1, t);
    end
    if isNum~=nil and isNum==true then return util.toNumber(sub_str_tab) end
    return sub_str_tab;
end

--字符串数组转数字数组
function util.toNumber(list)
    local num_tab = {};
    for i=1,#list do
        num_tab[i]=list[i]*1.0
    end
    return num_tab;
end

--坐标2维数组的转换,指针不变
function util.f2ccPos2(postable)
    for i=1,#postable do
        for j=1,#postable[i] do
            --postable[i][j][1]= 800-postable[i][j][1]
            postable[i][j][2]= 600-postable[i][j][2]
        end
    end
end

--坐标1维数组的转换,指针不变
function util.f2ccPos(postable)
    for i=1,#postable do
        --postable[i][1]= 800-postable[i][1]
        postable[i][2]= 600-postable[i][2]
    end
end

function util.max(p1,p2)
    if p1>p2 then
        return p1
    end
    return p2
end

function util.min(p1,p2)
    if p1<p2 then
        return p1
    end
    return p2
end

function util.reverse (table)
    if type(table)~="table" then
        return nil
    end
    local newtable={}
    local count=#table
    for i=1,count do
        newtable[i]=history.hostory[count-i+1]
    end
    return newtable
end


function util.printState()
    util.trace("----------当前加载纹理信息-------------")
    local info  = cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
    util.trace(info)
    local mem = collectgarbage("count")
    util.trace("Memory1 =%s ", mem)
end

function  util.getbit(num)
    num=num>=2
    num=num and 0x0000000F
    --return  bit._b2d(op1)
end
--a>b 1大于 0等于 -1 小于
function util.floatDiff(a,b)
    local c=a - b
    if c > 0.001 then return 1 end
    if -c > 0.001 then return -1 end
    return 0
end
util.addMoney=0.005
--获取数字的四舍五入 len位的的字符串
function util.getMoneyStr(num,len)
    if len==nil then
        len=2
    end
    if util.floatDiff(num, 0) == 0 then
        return "0"
    end
    --    if len<1 then
    --        return tostring(num)
    --    end
    local str= tostring(num)
    local idx=string.find(str, "%.")
    if idx  and idx + len <  string.len(str) then
        str=tostring(num + util.addMoney)
        idx=string.find(str, "%.")
        str= string.sub(str, 1, idx + len)--str.substring(0, idx + len + 1);
    end
    if len==0 then
        idx=string.find(str, "%.")
        if idx and idx>1 then
            str= string.sub(str, 1, idx-1)
        end
    end
    return str
end
--设置文本显示
function util.setNumText(txt,amount)
    txt:setString(util.getMoneyStr(amount))
end

function util.runFrameAction(sprite,frameFormat,from,to,speed)
    local frames={}
    for i=from,to do
        frames[i]=cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(frameFormat,i))
    end
    local animation=cc.Animation:createWithSpriteFrames(frames,speed)
    local animate=cc.Animate:create(animation)
    sprite:runAction(cc.RepeatForever:create(animate))
end


function util.runFrameActionCall(sprite,frameFormat,from,to,speed,call)
    local frames={}
    for i=from,to do
        frames[i]=cc.SpriteFrameCache:getInstance():getSpriteFrame(string.format(frameFormat,i))
    end
    local animation=cc.Animation:createWithSpriteFrames(frames,speed)
    local animate=cc.Animate:create(animation)
    sprite:runAction(cc.Sequence:create(animate, cc.CallFunc:create(call)))
end

local print = print
local tconcat = table.concat
local tinsert = table.insert
local srep = string.rep
local type = type
local pairs = pairs
local tostring = tostring
local next = next

function util.print(root)
    do return end
    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print("\n", _dump(root, "",""))
end

function util.isInNode(node, x, y)
    local rect = node:getBoundingBox()
    local b = cc.rectContainsPoint(rect, cc.p(x,y))
    return b
end

--连接多个表到第一个表
function util.join(...)
    local tables={...}
    local count=#tables
    if count<1 or type(tables[1])~="table" then
        return
    end
    local temp
    local len=#tables[1]
    for i=2,count do
        temp=tables[i]
        if  type(temp)=="table" then
            for j=1,#temp do
                len=len+1
                tables[1][len]=temp[j]
            end
        end
    end
end

--注册一个事件
function util.addEventListener(type,listener)
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    local listener = cc.EventListenerCustom:create(type,listener)
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

--移除监听的事件
function util.removeEventListener(type)
     cc.Director:getInstance():getEventDispatcher():removeCustomEventListeners(type)
end
--派发一个事件
function util.dispatchEvent(type,args)
    local event = cc.EventCustom:new(type)
    event.args = args
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

--注册事件
function util.registerScriptHandler(node,listennerFun,isMove,isEnd)
    --cocos不加begin报错
    local isBegin=true
--    if type(isBegin)~="boolean" then
--        isBegin=true
--    end
    if type(isMove)~="boolean" then
        isMove=true
    end
    if type(isEnd)~="boolean" then
        isEnd=true
    end    
  -- 创建一个事件监听器类型为 OneByOne 的单点触摸
    local  listenner = cc.EventListenerTouchOneByOne:create()
    
    -- ture 吞并触摸事件,不向下级传递事件;
    -- fasle 不会吞并触摸事件,会向下级传递事件;
    -- 设置是否吞没事件，在 onTouchBegan 方法返回 true 时吞没
    listenner:setSwallowTouches(true)

    if isBegin==true then
        -- 实现 onTouchBegan 事件回调函数
        listenner:registerScriptHandler(function(touch, event)
            --local location = touch:getLocation()
            --print("EVENT_TOUCH_BEGAN")
            listennerFun(1,touch, event)
            return true --true就不能向下传递,false相反
        end, cc.Handler.EVENT_TOUCH_BEGAN )
    end

    if isMove==true then
        -- 实现 onTouchMoved 事件回调函数
        listenner:registerScriptHandler(function(touch, event)
            --local locationInNodeX = self:convertToNodeSpace(touch:getLocation()).x     

            --print("EVENT_TOUCH_MOVED")
            listennerFun(2,touch, event)
            --return false
            return true
        end, cc.Handler.EVENT_TOUCH_MOVED )
    end
    
    -- 实现 onTouchEnded 事件回调函数
    if isEnd==true then
       listenner:registerScriptHandler(function(touch, event)
        --local locationInNodeX = self:convertToNodeSpace(touch:getLocation()).x

        --print("EVENT_TOUCH_ENDED")
        listennerFun(3,touch, event)
        --return false
        end, cc.Handler.EVENT_TOUCH_ENDED )
    end

    -- 添加监听器
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listenner, node)
end

--移除对象的所有事件
function util.removeEventListenersForTarget(node)
      cc.Director:getInstance():getEventDispatcher():removeEventListenersForTarget(node,true)
end

function util.pauseEventListenersForTarget(node)
      cc.Director:getInstance():getEventDispatcher():pauseEventListenersForTarget(node)
end

function util.resumeEventListenersForTarget(node)
      cc.Director:getInstance():getEventDispatcher():resumeEventListenersForTarget(node)
end

--移除某类型事件
function util.removeEventListenersForType(type)
      cc.Director:getInstance():getEventDispatcher():removeEventListenersForType(type)
end
--所有事件移除
function util.removeAllEventListeners()
      cc.Director:getInstance():getEventDispatcher():removeAllEventListeners()
end

--设置节点不可touch , 必须加个图层
function util.setNodeNotTouch(node)
    local layer=cc.Layer:create()
    local zorder=node:getLocalZOrder()
    node:getParent():addChild(layer,zorder)
    node:removeFromParent()
    layer:addChild(node)
    layer:setTouchEnabled(false)
    return layer
end

function util.vibrate()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_ANDROID == platform then
        local luaj = require("cocos.cocos2d.luaj")
        luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper","vibrate",{1500},"(I)V")
        --luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper","vibrateWithPattern",{{500,500,500},1},"([JI)V")
    elseif cc.PLATFORM_OS_IPHONE == platform then
        local luabridge = require "cocos.cocos2d.luaoc"
        luabridge.callStaticMethod("SimpleAudioEngine","vibrate",nil)
    end
end
-- {
--     warn          = {name="Warn",   fix="png", count=9,   start=0, speed = 0.07},
--     colour1       = {name="bigwin/Blue_",  fix="png", count=17,  start=0, speed = 0.05},
-- } 

function util.createAnimates(actionsDef)
    if util.animatesList==nil then
        util.animatesList={}
    end
    local animatesList=util.animatesList
    local animates={}
    for k,v in pairs(actionsDef) do  
        animates[k] = util.createAnimate(v)
    end
    util.push(animatesList,animates)
    return animates
end
--单个动画
-- {name="Warn",   fix="png", count=9,   start=0, speed = 0.07}
function util.createAnimate(actionDef)
    local frames = {} 
    local v=actionDef
    local tex       
    for i=1, v.count do
        tex=string.format("%s%d.%s",v.name, i-1+v.start, v.fix)      
        frames[i] = cc.SpriteFrameCache:getInstance():getSpriteFrame(tex)
        print(tex,frames[i])
    end
    local animation = cc.Animation:createWithSpriteFrames(frames, v.speed)
    local animate=cc.Animate:create(animation)
    animate:retain()
    return animate
end
--重复播放动画的精灵
function util.createAnimateSp(actionDef)
    local animate=util.createAnimate(actionDef)
    local sp=cc.Sprite:create()
    util.runRepeatAnimate(sp,animate,true)
    return sp
end
--精灵播放重复动画
function util.runRepeatAnimate(sp,animate,isNotClone)
    --默认是克隆的 不会释放
    if isNotClone==true then
        sp:runAction(cc.RepeatForever:create(animate))
    else
        sp:runAction(cc.RepeatForever:create(animate:clone()))    
    end
    
end
function util.runRepeatSequence(sp,actions)
    sp:runAction(cc.RepeatForever:create(cc.Sequence:create(unpack(actions))))
end

function util.runSequence(sp,actions)
    sp:runAction(cc.Sequence:create(unpack(actions)))
end
function util.delayCall(sp,time,fun)
    util.runSequence(sp,{cc.DelayTime:create(time),cc.CallFunc:create(fun)})
end

function util.repeatDelayCall(sp,time,fun)
    sp:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(fun))))
end

function util.delay(time,fun)
    local lobbyData = require(LobbyDir .. "LobbyData")
    local act = cc.Sequence:create(cc.DelayTime:create(time), cc.CallFunc:create(fun))
    lobbyData.scene:runAction(act)
end

function util.runAction(action)
    local lobbyData = require(LobbyDir .. "LobbyData")
    lobbyData.scene:runAction(action)
end

function util.playAndClearTipMc(tipMc,time)
    tipMc:resetPlay()
    util.delay(time,function ()
        tipMc:stop(false,true)
    end)
end

function util.releasePoolAnimates(animate)
    local animatesList=util.animatesList
    if animatesList~=nil then
        util.remove(animatesList,animate)
    end
    util.releaseAnimates(animate)
end

function util.releaseAnimates(animate)
    for k, v in pairs(animate) do
        if v ~= nil then
            v:release()
        end
    end
end

function util.releaseAllAnimates()
    local animatesList=util.animatesList
    if animatesList==nil then
        return
    end
    for i=1,#animatesList do
        util.releaseAnimate(animatesList[i])
    end
end
----游戏通用
function util.inGameStatus()
    local lobbyData = require(LobbyDir .. "LobbyData")
    local function onDisconnect()
        local loadingScene = require (LobbyDir .. "GameLoader")
        cc.Director:getInstance():purgeCachedData()
        local scenelobby = loadingScene.create(gameConfig.lobbyConfig)
        cc.Director:getInstance():replaceScene(scenelobby)
        lobbyData.runningGame = gameConfig.lobbyConfig
        g_currentGame = gameConfig.lobbyConfig
        lobbyData.status = lobbyData.eStatus.reconnect
    end
    if lobbyData.connect then
        lobbyData.status = lobbyData.eStatus.game
    else
        lobbyData.scene:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(onDisconnect)))
    end
end

-- add by common
function util.format_int(number)

  local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')

  -- reverse the int-string and append a comma to all blocks of 3 digits
  int = int:reverse():gsub("(%d%d%d)", "%1,")

  -- reverse the int-string back remove an optional comma and put the 
  -- optional minus and fractional part back
  return minus .. int:reverse():gsub("^,", "") .. fraction
end

function util.leaveGame()
    for k, v in pairs(s_preLoad) do
        if v[1] == "pic" then
            cc.Director:getInstance():getTextureCache():removeTextureForKey(v[2])
        elseif v[1] == "plist" then
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(v[2] .. ".plist")
            cc.Director:getInstance():getTextureCache():removeTextureForKey(v[2] .. ".png")
        end
    end

    for k, v in pairs(s_delayLoad) do
        if v[1] == "pic" then
            cc.Director:getInstance():getTextureCache():removeTextureForKey(v[2])
        elseif v[1] == "plist" then
            cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(v[2] .. ".plist")
            cc.Director:getInstance():getTextureCache():removeTextureForKey(v[2] .. ".png")
        end
    end

    for k, v in pairs(s_require) do
        trace("释放s_require %s %s",k,v)
        package.loaded[v] = nil
        _G[k]=nil
    end
    require("Config.MutilLobbyConfig")
    for k, v in pairs(s_require) do
        trace("释放s_require %s %s",k,v)
        package.loaded[v] = nil
        _G[k]=nil
    end
end

return util