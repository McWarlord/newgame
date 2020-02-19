--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
require "cocos.utils.init"

local PacketBuffer = class("PacketBuffer")

cc = cc or {}
cc.PacketBuffer = PacketBuffer

PacketBuffer.ENDIAN = cc.utils.ByteArray.ENDIAN_LITTLE

PacketBuffer.MASK1 = 0x86
PacketBuffer.MASK2 = 0x7b
PacketBuffer.RANDOM_MAX = 10000
PacketBuffer.PACKET_MAX_LEN = 2100000000

PacketBuffer.FLAG_LEN = 2	-- package flag at start, 1byte per flag
PacketBuffer.TYPE_LEN = 1	-- type of message, 1byte
PacketBuffer.CLASS_LEN = 1  -- length of message class, byte
PacketBuffer.METHODCODE_LEN = 2	-- length of message method code, short
PacketBuffer.BODY_LEN = 4	-- length of message body, int
PacketBuffer.META_NUM_LEN = 1	-- how much item in a message, 1byte

local _DATA_TYPE = 
{
	R = 0,	-- Unsigned Varint int
	S = 1,	-- String
	r = 2,	-- Varint int
    W = 3,  -- unsigned short
    s = 4,  -- short
    f = 5,  -- float
    D = 6,  -- double
    B = 7,  -- bool
    b = 8,  -- byte
}


local function _getDataTypeValue(__type)
--    print("Meta type : " .. __type)
	for __k, __v in pairs(_DATA_TYPE) do
		if __v == __type then return __k end
	end
	error(__type .. " is a unavailable type value! You can only use a type value in 012.")
	return nil
end

local function _getKeyFromi(i, __keys)
	if not __keys then return i end
	if __keys[i] then return __keys[i] end
	return i
end

--- metadata item description
function PacketBuffer._createMeta(__fmt)
	local __buf = PacketBuffer.getBaseBA()
	__buf:writeShort(#__fmt)
	for i=1,#__fmt do
		-- create a metadata description: data index(1byte) + data type(1byte)
        __buf:writeShort(bit.bor(bit.lshift(i-1, 8), _DATA_TYPE[__fmt:sub(i,i)]))
	end
	return __buf
end

function PacketBuffer._parseMeta(__buf)
	local __meta = {}
	local __metaNum = __buf:readShort()
	for i=1,__metaNum do
		local __metaDes = __buf:readShort()
		--- right shift __metaDes 3 bits, get the head 5 bits
		local __index = bit.rshift(__metaDes, 8) + 1
		--print("parseMeta, __index:", __index)
		-- 7 = b0000 0111, bit and __metaDes, get the last 3 bits. see PacketBuffer._createMeta
		local __type = _getDataTypeValue(bit.band(__metaDes, 255))
		--print("parseMeta, __type:", __type)
		__meta[i] = __type
	end
	return __meta
end

function PacketBuffer._createBody(__fmt, __body)
	assert(#__fmt == #__body, #__fmt.." ~= "..#__body.." The number of format string must be equivalent to body's!")
	--print("getBody, fmt:", __fmt)
	--print("getBody, body:", unpack(__body))
	local __buf = PacketBuffer.getBaseBA()
	for i=1,#__fmt do
		local __f = __fmt:sub(i,i)
		if __f == "R" then
			__buf:writeUInt(__body[i])
		elseif __f == "S" then
			__buf:writeStringUShort(__body[i])
		elseif __f == "r" then
			__buf:writeInt(__body[i])
        elseif __f == "W" then
            __buf:writeUShort(__body[i])
        elseif __f == "s" then
            __buf:writeShort(__body[i])
        elseif __f == "f" then
            __buf:writeFloat(__body[i])
        elseif __f == "D" then
           __buf:writeDouble(__body[i])
        elseif __f == "B" then
           __buf:writeBool(__body[i])
        elseif __f == "b" then
           __buf:writeByte(__body[i])
		else
			error(__f .. " is a unavailable type! You can only use a type in RSr.")
		end
	end
	return __buf
end

function PacketBuffer._parseBody(__buf, __meta)
	local __body = {}
    local __bodyByteBuffer = cc.utils.ByteArray.new()

	for i=1,#__meta do
		local __f = __meta[i]
		local __value = nil
		if __f == "R" then
			__value = (__buf:readUInt()) or 0
            __bodyByteBuffer:writeInt(__value)
		elseif __f == "S" then
			__value = (__buf:readStringUShort()) or ""
            __bodyByteBuffer:writeStringUShort(__value)
		elseif __f == "r" then
			__value = (__buf:readInt()) or 0
            __bodyByteBuffer:writeInt(__value)
        elseif __f == "W" then
            __value = (__buf:readUShort()) or 0
            __bodyByteBuffer:writeUShort(__value)
        elseif __f == "s" then
            __value = (__buf:readShort()) or 0
            __bodyByteBuffer:writeShort(__value)
        elseif __f == "f" then
            __value = (__buf:readFloat()) or 0
            __bodyByteBuffer:writeFloat(__value)
        elseif __f == "D" then
            __value = (__buf:readDouble()) or 0
            __bodyByteBuffer:writeDouble(__value)
        elseif __f == "B" then
            __value = (__buf:readBool()) or false
            __bodyByteBuffer:writeBool(__value)
        elseif __f == "b" then
            __value = (__buf:readByte()) or false
            __bodyByteBuffer:writeByte(__value)
		else
			error(__f .. " is a unavailable type! You can only use a type in RSr.")
		end
		local __key = _getKeyFromi(i, __keys)
		__body[__key] = __value
		--print("parseBody, f:", __f, " key:", __key, " value:", __value)
	end
    __bodyByteBuffer._pos = 1
	return __body, __bodyByteBuffer
end

function PacketBuffer.getBaseBA()
	return cc.utils.ByteArray.new(PacketBuffer.ENDIAN)
end

--- Create a formated packet that to send server
-- @param __msgDef the define of message, a table
-- @param __msgBodyTable the message body with key&value, a table
function PacketBuffer.createPacket(__msgCode, __msgFmt, __msgBodyTable) -- __msgType, __msgClass, __msgCode, __msgFmt, __msgBodyTable
	local __buf = PacketBuffer.getBaseBA()
	local __metaBA = PacketBuffer._createMeta(__msgFmt)
	local __bodyBA = PacketBuffer._createBody(__msgFmt, __msgBodyTable)
	--print("metaBA:", __metaBA:getLen())
	--print("bodyBA:", __bodyBA:getLen())
	local __bodyLen = __metaBA:getLen() + __bodyBA:getLen()
	-- write 2 flags and message type, for client, is always 0
	__buf:rawPack(
		"b2hi", 
		PacketBuffer.MASK1, 
		PacketBuffer.MASK2, 
--		__msgType,
--        __msgClass,
        __msgCode,
		__bodyLen
		)
	__buf:writeBuf(__metaBA:getPack())
	__buf:writeBuf(__bodyBA:getPack())
	return __buf
end

function PacketBuffer:ctor()
	self:init()
end

function PacketBuffer:init()
	self._buf = PacketBuffer.getBaseBA()
end

--- Get a byte stream and analyze it, return a splited table
-- Generally, the table include a message, but if it receive 2 packets meanwhile, then it includs 2 messages.
function PacketBuffer:parsePackets(__byteString)
	local __msgs = {}
	local __pos = 0
	self._buf:setPos(self._buf:getLen()+1)
	self._buf:writeBuf(__byteString)
	self._buf:setPos(1)
	local __flag1 = nil
	local __flag2 = nil
	local __preLen = PacketBuffer.FLAG_LEN + PacketBuffer.TYPE_LEN + PacketBuffer.CLASS_LEN + PacketBuffer.METHODCODE_LEN + PacketBuffer.BODY_LEN
	while self._buf:getAvailable() >= __preLen do
		__flag1 = self._buf:readByte()
		--printf("__flag1:%2X", __flag1)
		--if bit.band(__flag1 ,PacketBuffer.MASK1) == __flag1 then
		if __flag1 == PacketBuffer.MASK1 then
			__flag2 = self._buf:readByte()
			--printf("__flag2:%2X", __flag2)
			--if bit.band(__flag2, PacketBuffer.MASK2) == __flag2 then
			if __flag2 ==  PacketBuffer.MASK2 then
				-- skip type value, client isn't needs it
--                local __msgType = self._buf:readByte()
--                local __msgClass = self._buf:readByte()
                local __msgCode = self._buf:readUShort()
				local __bodyLen = self._buf:readInt()
				local __pos = self._buf:getPos()
				--printf("__bodyLen:%u", __bodyLen)
				-- buffer is not enougth, waiting...
				if self._buf:getAvailable() < __bodyLen then 					
					self._buf:setPos(self._buf:getPos() - __preLen)
					break 
				end
				if __bodyLen <= PacketBuffer.PACKET_MAX_LEN then
					local __meta = PacketBuffer._parseMeta(self._buf)
					local __msg = {}
					__msg.type = __msgType
                    __msg.class= __msgClass
                    __msg.code= __msgCode
					__msg.body, __msg.bodyByteBuffer = PacketBuffer._parseBody(self._buf, __meta)
					__msgs[#__msgs+1] = __msg
--					print("after get body position:%u", self._buf:getPos())
				end
			end
		end
	end
	-- clear buffer on exhausted
	if self._buf:getAvailable() <= 0 then
		self:init()
	else
		-- some datas in buffer yet, write them to a new blank buffer.
		print("cache incomplete buff,len: %u, available: %u", self._buf:getLen(), self._buf:getAvailable())
		local __tmp = PacketBuffer.getBaseBA()
		self._buf:readBytes(__tmp, 1, self._buf:getAvailable())
		self._buf = __tmp
		print("tmp len: %u, availabl: %u", __tmp:getLen(), __tmp:getAvailable())
		print("buf:", __tmp:toString())
	end
	return __msgs
end

return PacketBuffer



--endregion
