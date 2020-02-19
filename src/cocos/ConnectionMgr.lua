--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

require("cocos.ProtocolEncoder")
require("cocos.ProtocolDecoder")

cc = cc or {}

cc.ConnectionMgr = class("ConnectionMgr")
cc.net 					= require("cocos.net.init")

function cc.ConnectionMgr:create()
    if connectionMgrInstance == nil then
        connectionMgrInstance = cc.ConnectionMgr.new()
    end
    return connectionMgrInstance
end

function cc.ConnectionMgr:ctor()
    self._buf = cc.PacketBuffer.new()
    self._isLoggedIn = false
    self._firstConnect = true
end

function cc.ConnectionMgr:initNetworkTable(__callbackTable)
    self._callbackTable = __callbackTable
end

function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function cc.ConnectionMgr:connect(__connectID, __strUserID, __strPwd, __strIP, __port, __useHeartbeat)
    
    self._connectID = __connectID
    self._userID = __strUserID
    self._pwd = __strPwd
    self._ip = __strIP
    self._port = __port
    self._useHeartbeat = __useHeartbeat

    self._socket = cc.net.SocketTCP.new(__strIP, __port, false)
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self,self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self,self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self,self.onStatus))
	self._socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self,self.onData))
    self._socket:connect(__strIP, __port, __useHeartbeat)
end

function cc.ConnectionMgr:reConnect()
    self._socket:connect(self._ip, self._port, self._useHeartbeat)
end


function cc.ConnectionMgr:__requestLogin()
    local protocolEncoder = cc.ProtocolEncoder:create(1, 10)

    --added by jaison

    protocolEncoder:WriteString(0, self._userID)
    protocolEncoder:WriteString(0, self._pwd)

    local platform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_ANDROID == platform or cc.PLATFORM_OS_IPHONE == platform then
        protocolEncoder:WriteBYTE(1)
    else
        protocolEncoder:WriteBYTE(0)
    end

    protocolEncoder:SendData()
end

function cc.ConnectionMgr:sendData(data)
    self._lastSendTime    = os.time()
    local realSendData = 
    self._socket:send(data)
end

function cc.ConnectionMgr.send(buf)
    connectionMgrInstance:sendData(buf)
end

function cc.ConnectionMgr:processHeartbeat()
--    print("processing heartbeat")
    if not self._socket.isConnected then
        print("not connected")
        return
    end
    if os.time() - self._lastSendTime > 10 then
        local protocolEncoder = cc.ProtocolEncoder:create(0xFF, 10)
        protocolEncoder:SendData()
    end
    
    if os.time() - self._lastReceiveTime > 60 then
        self._socket:disconnect()
        print("overload 60")
    end
end


function cc.ConnectionMgr:onStatus(__event)
    --print("socket status: %s", __event.name)
    if __event.name == cc.net.SocketTCP.EVENT_CONNECTED then
        if not self._firstConnect then
            self._callbackTable[3]()

            --by jaison
            self._callbackTable[13]()
            -------------------------
        end
        self._callbackTable[1]()

        --by jaison
        --self:__requestLogin()
        if self._firstConnect then
            self._callbackTable[12]()
        end
        -----------------------------

        self._firstConnect = false
        self._lastReceiveTime = os.time()
        self._lastSendTime    = os.time()
    elseif __event.name == cc.net.SocketTCP.EVENT_CLOSED then
        self._callbackTable[5]()
        self:reConnect()
    elseif __event.name == cc.net.SocketTCP.EVENT_CONNECT_FAILURE then
--        self._callbackTable[9]()
    elseif __event.name == cc.net.SocketTCP.EVENT_CLOSE then

        --commented by jaison 20170818
        --self:reConnect()
        ------------------------------

        self._callbackTable[6]("loginning")
    end
end


function cc.ConnectionMgr:onData(__event)
	--print("socket receive raw data:", cc.utils.ByteArray.toString(__event.data, 16))
	local __msgs = self._buf:parsePackets(__event.data)
	for i=1,#__msgs do
		local __msg = __msgs[i]
        self:onProcessPacket(__msg)
	end
    self._lastReceiveTime = os.time()
end

function cc.ConnectionMgr:onProcessPacket(__packet)
    if __packet.code == 1 then
        local loginResult = __packet.body[1]
        if loginResult == 0 then
            self._isLoggedIn = true

            local level = __packet.body[2]
            local gift = __packet.body[3]
            local nickname = __packet.body[4]
            local useDeposit = __packet.body[5]
            local useWithDraw = __packet.body[6]

            local useAccur = __packet.body[7]
            local useO2o = __packet.body[8]
            local useChatting = __packet.body[9]
            self._callbackTable[4](level, gift, nickname, useDeposit, useWithDraw, useAccur, useO2o, useChatting)
        else
            self._callbackTable[6](loginResult)
        end
    else
        cc.ProtocolDecoder:setBodyData(__packet.bodyByteBuffer)
        self._callbackTable[8](__packet.code)
    end
end
--endregion
