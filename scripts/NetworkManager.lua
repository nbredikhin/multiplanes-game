local NetworkManager = Core.class(EventDispatcher)

function NetworkManager:init()
	self.username = "User" .. math.random(1000)
	self.type = "none"
	self.remoteData = {}
end

-- CLIENT

function NetworkManager:startClient()
	if self.serverlink then
		self:disconnect()
	end
	self.type = "client"

	self.serverlink = Client.new({username=self.username})
	self.serverlink:addEventListener("newServer", self.onNewServer, self)
	self.serverlink:addEventListener("onAccepted", self.onAccepted, self)
	self.serverlink:startListening()

	print("CLIENT: Client started")
end

function NetworkManager:onNewServer(e)
	self:dispatchEvent(e)
	print("CLIENT: New server: " .. tostring(e.data.host))
end

function NetworkManager:connectToServer(id)
	if not self.serverlink then
		return false
	end
	self.serverlink:connect(id)
end

function NetworkManager:onAccepted(e)
	print("CLIENT: Got accepted")
	self:setupRPC()
	self:dispatchEvent(Event.new("startGame"))
end

-- SERVER

function NetworkManager:startServer()
	if self.serverlink then
		self:disconnect()
	end
	self.type = "server"

	self.serverlink = Server.new({username=self.username})
	self.serverlink:addEventListener("newClient", self.onNewClient, self)
	self.serverlink:startBroadcast()

	print("SERVER: Server started")
end

function NetworkManager:onNewClient(e)
	self.serverlink:accept(e.data.id)
	print("SERVER: Accepted client: " .. tostring(e.data.id))
	self.serverlink:stopBroadcast()
	self:setupRPC()
	self:dispatchEvent(Event.new("startGame"))
end

-- CLIENT AND SERVER

function NetworkManager:disconnect()
	if not self.serverlink then
		return false
	end
	if self.type == "client" then
		self.serverlink:stopListening()
	elseif self.type == "server" then
		self.serverlink:stopBroadcast()
	end
	self.serverlink:close()
	self.serverlink = nil
	self.type = "none"
	return true
end

function NetworkManager:setupRPC()
	if not self.serverlink then
		return
	end

	self.remoteData = {}
	self.serverlink:addMethod("setValue", self.RPC_setValue, self)
end

function NetworkManager:setValue(key, value)
	if not self.serverlink then
		return
	end
	self.serverlink:callMethod("setValue", key, value)
end

function NetworkManager:getValue(key)
	return self.remoteData[key]
end

function NetworkManager:RPC_setValue(key, value)
	self.remoteData[key] = value
end

return NetworkManager