--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require("cocos.net.PacketBuffer")

local ProtocolEncoder = class("ProtocolEncoder")
cc = cc or {}
cc.ProtocolEncoder = ProtocolEncoder


function ProtocolEncoder:create(__messageCode, __messageLen)
    return ProtocolEncoder.new(__messageCode, __messageLen)
end

function ProtocolEncoder:ctor(__messageCode, __messageLen)
    self._messageCode   = __messageCode
    self._messageLen    = __messageLen
	self._buf = {}
	self._pos = 1
    self._metaData = ""
    self._bodyData = {}
    self._gameid = 0
end

function ProtocolEncoder:SetGameId(__gameId)
    self._gameid = __gameId
end

function ProtocolEncoder:WriteWORD(__offset, __word)
    self._metaData = self._metaData .. "W"
    self._bodyData[#self._bodyData + 1] = __word
end

function ProtocolEncoder:WriteString(__offset, __string)
    self._metaData = self._metaData .. "S"
    self._bodyData[#self._bodyData + 1] = __string
end

function ProtocolEncoder:WriteShort(__offset, __short)
    self._metaData = self._metaData .. "s"
    self._bodyData[#self._bodyData + 1] = __word
end

function ProtocolEncoder:WriteInt(__offset, __int)
    self._metaData = self._metaData .. "r"
    self._bodyData[#self._bodyData + 1] = __int
end

function ProtocolEncoder:WriteFloat(__offset, __float)
    self._metaData = self._metaData .. "f"
    self._bodyData[#self._bodyData + 1] = __float
end

function ProtocolEncoder:WriteDouble(__offset, __double)
    self._metaData = self._metaData .. "D"
    self._bodyData[#self._bodyData + 1] = __double
end

function ProtocolEncoder:WriteBool(__bool)
    self._metaData = self._metaData .. "B"
    self._bodyData[#self._bodyData + 1] = __bool
end

function ProtocolEncoder:WriteBYTE(__byte)
    self._metaData = self._metaData .. "b"
    self._bodyData[#self._bodyData + 1] = __byte
end


function ProtocolEncoder:getByteArray()
    local __buf = cc.utils.ByteArray.new(cc.utils.ByteArray.ENDIAN_LITTLE)
    return __buf
end


function ProtocolEncoder:SendData()
    local __buf = cc.PacketBuffer.createPacket(self._messageCode, self._metaData, self._bodyData)
    cc.ConnectionMgr.send(__buf:getPack())
end


--endregion
