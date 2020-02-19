abcdefg=abcdefg or {0}
abcdefg[1]=abcdefg[1]+1
print("-----load sound---------",abcdefg[1])
require("utils.util")

if sound~=nil and sound.soundsrcLen~=nil then
   return sound
end

sound={}
local audio = cc.SimpleAudioEngine:getInstance()
local audioExt=".mp3"
local audioPre=""--为了不混淆mp3文件
local platform=cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == platform then
    audioExt=".ogg"
end

Languages=Languages or {}
if language=="CN" then
    Languages.lan0="zh"
else
    Languages.lan0="en"
end


--soundid.button得到的是value,
sound.soundid={}
sound.soundid.button=1
sound.soundid.chip=2
sound.soundid.sBJPost=3
sound.soundid.sBJRecoverPai=4
sound.soundid.dealerdnq=5
sound.soundid.DealerWin=6
sound.soundid.PlayerWin=7
sound.soundid.pleasebet=8
sound.soundid.push=9
sound.soundid.youwinm=10
sound.soundid.BJBust=11
sound.soundid.BJInsurance=12
sound.soundid.BJBlackJack=13
sound.soundid.BK_ONE=14
sound.soundid.PL_ONE=15
sound.soundid.BankerHas=16
sound.soundid.PlayerHas=17
sound.soundid.betlower=18
sound.soundid.seBJBlackJack=19

sound.soundsrc={
    "Music/Table/sBJButton",--1按钮
    "Music/Table/sBJChouMa",--2筹码
    "Music/Table/sBJPost",--3发牌
    "Music/Table/sBJRecoverPai",--4收牌
    "Music/Table/"..Languages.lan0.."/dealerdnq_male1",--5庄家无资格
    "Music/Table/"..Languages.lan0.."/seBJDealerWins",--6庄家赢
    "Music/Table/"..Languages.lan0.."/seBJPlayerWins",--7玩家赢
    "Music/Table/"..Languages.lan0.."/seBJPleaseBet",--8请下注
    "Music/Table/"..Languages.lan0.."/seBJPush",--9平手
    "Music/Table/"..Languages.lan0.."/youwinm",--10你赢了
    "Music/Table/"..Languages.lan0.."/seBJBust",--11爆牌
    "Music/Table/"..Languages.lan0.."/seBJInsurance",--12买保险吗
    "Music/Table/"..Languages.lan0.."/seBJBlackJack",--13 21点
    "Music/Table/"..Languages.lan0.."/BK_ONE",--14 庄家一张
    "Music/Table/"..Languages.lan0.."/PL_ONE",--15 玩家一张
    "Music/Table/"..Languages.lan0.."/BankerHas",--16 庄家有
    "Music/Table/"..Languages.lan0.."/PlayerHas",--17 玩家有
    "Music/Table/"..Languages.lan0.."/betlow",--18您的下注太低
    "Music/Table/"..Languages.lan0.."/seBJBlackJack",--19 杰克
}

sound.soundsrcLen=#sound.soundsrc
sound.sl=sound.soundsrcLen
local sounds={}
local soundsrc={}
function sound.getSounds()
    return soundsrc
end
function sound.load(_audioPre,isDef,notLoads)
    --bluestake获取到不是android
    if type(_audioPre)=="string" then
        audioPre=_audioPre
    end

    if isDef==true then
        local def = require(s_require.def)
        soundsrc=def.soundFiles
        sound.soundid=soundsrc
    else
        soundsrc=sound.soundsrc
    end
    if notLoads==nil then
        notLoads={}
    end
    -- do return end
    --背景音乐加这里就播放不了啦
    for k,v in pairs(soundsrc) do
        if notLoads[k]==nil then
            audio:preloadEffect(audioPre..v.. audioExt)
            --util.trace("sound.load->%s",v)
        end
    end
    --audio:preloadBackgroundMusic()
end

function sound.setSoundsrc()
    local def = require(s_require.def)
    soundsrc = def.soundFiles
end

function sound.playEffect(id, loop,stopBefore)
    -- util.trace("sound.playEffect(id)"..id)
    --一种特效重叠
    if stopBefore==true then
        sound.stopEffect(id)
    end
    if loop==nil then loop=false end
    if soundsrc[id]==nil then
        util.trace("声音资源没有找的 id:%s",id)
        --        for i=1,#soundsrc do
        --           util.trace("%s->%s",i,soundsrc[i])
        --        end
        return
    end
    local sndSrc=soundsrc[id]..audioExt
    --print("playEffect->%s",sndSrc)
    sounds[id]= audio:playEffect(audioPre..sndSrc,loop)
    return sounds[id]
end

function sound.pauseEffect(id)
    if type(sounds[id])=="number" then
        audio:pauseEffect(sounds[id])
    end
end

function sound.stopEffect(id)
    -- util.trace("sound.stopEffect(id)"..id)
    if type(sounds[id])=="number" then
        audio:stopEffect(sounds[id])
    end
end

function sound.stopAllEffects()
    audio:stopAllEffects()
end

function sound.playSrcEffect(sndSrc, loop)
    if loop==nil then loop=false end 
    sndSrc=sndSrc..audioExt
    return audio:playEffect(audioPre..sndSrc,loop)
end

function sound.playMusic(id, loop)
    if  type(id)=="number" and soundsrc[id]==nil then
        print("playMusic nil ",id)
        return 
    end
    if loop==nil then loop=true end   
    --audio:stopMusic()
    if type(id)=="number" then
        local src=audioPre..soundsrc[id]..audioExt
        util.trace("sound.playBgMusic(id %s) src %s",id,src)
        sounds[id]= audio:playMusic(src,loop)
        return sounds[id]
    end
    if type(id)=="string" then
        return audio:playMusic(id,true)
    end
end

function sound.playSrcMusic(sndSrc, loop)
    --if loop==nil then loop=true end 
    return audio:playMusic(audioPre..sndSrc..audioExt,true)
end
function sound.playBgMusic(id, loop)
    audio:stopMusic()
    util.trace("sound.playBgMusic")
    if type(id)=="number" then
        sound.playMusic(id, loop)
        return
    end
    audio:playMusic(audioPre..sound.bgmusic..audioExt,true)     
    --    sound.playMusic(sound.bgid, true)
end

function sound.playBGMusic(id, loop)
    sound.playMusic(id, loop)
end

function sound.pauseBackgroundMusic()
    audio:pauseBackgroundMusic()
end

function sound.resumeBackgroundMusic()
    audio:resumeBackgroundMusic()
end

function sound.stopBGMusic()
    audio:stopMusic()
end

function sound.pauseBGMusic()
    audio:pauseMusic()
end

function sound.resumeBGMusic()
    audio:resumeMusic()
end

function sound.getEffectsVolume ()
    return audio:getEffectsVolume ()
end

function sound.setEffectsVolume(volume)
    audio:setEffectsVolume(volume)
end

function sound.playAll()
    local count=#soundsrc
    local id=1
    DelayedCall.create(function(d,a)
        sound.playEffect(id)
        util.trace("测试声音id %s",id)
        id=id+1
        if id>=count then
            d:cancel()
            util.trace("全部测试完毕")
        end
    end,1,0):add()
end
function sound.leave()
    for k,v in pairs(soundsrc) do
        audio:unloadEffect(audioPre..v.. audioExt)
    end
    sound.stopAllEffects()
    audio:stopMusic()
end

function sound.playMutex(id, loop)
    if ccexp.AudioEngine:getState(soundsrc[id]) ~= 1 then
        sounds[id] = ccexp.AudioEngine:play2d(soundsrc[id] .. ".ogg", loop)
    end
end

--播放21点数
function sound.playBjEffect(num)
    if num<10 then
        num="0"..num
    end
    local sndSrc=string.format(audioPre.."Music/Table/%s/seBJ%s%s",Languages.lan,num,audioExt)
    audio:playEffect(sndSrc,false)
    return 1--声音的时间
end
--播放点数
function sound.playCardNum(num)
    local sndSrc=string.format("Music/Table/"..Languages.lan0.."/seBJ%02d%s",num,audioExt)
    return audio:playEffect(audioPre..sndSrc,false)
end

return sound
