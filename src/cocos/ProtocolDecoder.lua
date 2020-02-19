--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "cocos.utils.init"

local ProtocolDecoder = class("ProtocolDecoder")
cc = cc or {}
cc.ProtocolDecoder = ProtocolDecoder

local byteArray = cc.utils.ByteArray.new()
function ProtocolDecoder:setBodyData(__bodyByteArray)
    byteArray = __bodyByteArray
end

function ProtocolDecoder:ReadFloat()
    return byteArray:readFloat()
end

function ProtocolDecoder:ReadBYTE()
    return byteArray:readByte()
end

function ProtocolDecoder:ReadInt()
    return byteArray:readInt()
end

function ProtocolDecoder:ReadString()
    return byteArray:readStringUShort()
end

function ProtocolDecoder:ReadShort()
    return byteArray:readShort()
end

function ProtocolDecoder:ReadBool()
    return byteArray:readBool()
end

function ProtocolDecoder:ReadWORD()
    return byteArray:readUShort()
end

function ProtocolDecoder:ReadDouble()
    return byteArray:readDouble()
end

function ProtocolDecoder:Offset()
end
--endregion
