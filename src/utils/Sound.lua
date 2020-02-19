local AztecSound = {}

local def = require(s_require.def)
local sounds = {}
local instance = cc.SimpleAudioEngine:getInstance()
local platform = cc.Application:getInstance():getTargetPlatform()
local audioExt=".mp3"
local platform=cc.Application:getInstance():getTargetPlatform()
if cc.PLATFORM_OS_ANDROID == platform then
    --audioExt=".ogg"
    audioExt=".ogg"
end

function AztecSound.load()
    for k,v in pairs(def.soundFiles) do
        instance:preloadEffect(v.. audioExt)
    end
end

function AztecSound.preLoadeEffect(v)
    instance:preloadEffect(v.. audioExt)
end

function AztecSound.playEffect(id, loop, stop)
    if cc.PLATFORM_OS_ANDROID ~= platform then
        --return
    end
    if stop == nil or stop == true then
        if sounds[id] ~= nil then
            --ccexp.AudioEngine:stop(sounds[id])
            instance:stopEffect(sounds[id])
        end
    end
    sounds[id] = instance:playEffect(def.soundFiles[id] .. audioExt, loop)
    return sounds[id]
    --sounds[id] = ccexp.AudioEngine:play2d(def.soundFiles[id] .. audioExt, loop)
end

function AztecSound.playMutex(id, loop)
    if ccexp.AudioEngine:getState(def.soundFiles[id]) ~= 1 then
        sounds[id] = ccexp.AudioEngine:play2d(def.soundFiles[id] .. audioExt, loop)
    end
end

function AztecSound.pauseEffect(id)
    if cc.PLATFORM_OS_ANDROID ~= platform then
        --return
    end
    if sounds[id] == nil then
        return
    end
    instance:pauseEffect(sounds[id])
    --ccexp.AudioEngine:pause(sounds[id])
end

function AztecSound.resumeEffect(id)
    if cc.PLATFORM_OS_ANDROID ~= platform then
        --return
    end
    if sounds[id] == nil then
        return
    end
    instance:resumeEffect(sounds[id])
    --ccexp.AudioEngine:resume(sounds[id])
end

function AztecSound.stopEffect(id)
    if cc.PLATFORM_OS_ANDROID ~= platform then
        --return
    end
    if sounds[id] == nil then
        return
    end
    --ccexp.AudioEngine:stop(sounds[id])
    instance:stopEffect(sounds[id])
end

function AztecSound.stopAllEffects()
    if cc.PLATFORM_OS_ANDROID ~= platform then
        --return
    end
    --ccexp.AudioEngine:stopAll()
    instance:stopAllEffects()
end

function AztecSound.playBGMusic(id, loop)
    instance:playMusic(def.soundFiles[id] .. audioExt,loop)
end

function AztecSound.stopBGMusic()
    instance:stopMusic()
end

function AztecSound.pauseBGMusic()
    instance:pauseMusic()
end

function AztecSound.resumeBGMusic()
    instance:resumeMusic()
end

function AztecSound.leave()
    for k, v in pairs(def.soundFiles) do
        instance:unloadEffect(v .. audioExt)
    end
    instance:stopMusic()
    --ccexp.AudioEngine:uncacheAll()
end

return AztecSound