local Screen 		= require "scripts.screens.Screen"
local Background 	= require "scripts.menu.Background" 

local JoinScreen = Core.class(Screen)

local BACKGROUND_MOVEMENT_SPEED = 25

function JoinScreen:load()
	self.background = Background.new()
	self:addChild(self.background)

	self.menuText = TextField.new()
	self.menuText:setText("JOIN GAME")
	self.menuText:setTextColor(0xFFFFFF)
	self:addChild(self.menuText)
	self.menuText:setPosition(screenWidth / 2 - self.menuText:getWidth() / 2, 10)

	self.backButton = TextField.new(nil, "Back")
	self.backButton:setScale(0.5)
	self.backButton:setTextColor(0xFFFFFF)
	self.backButton:setPosition(screenWidth - self.backButton:getWidth() - 5, screenHeight - self.backButton:getHeight())
	self:addChild(self.backButton)
	self.backButton:addEventListener(Event.TOUCHES_BEGIN, 
		function(e)
			if e:getTarget():hitTestPoint(e.touch.x, e.touch.y) then
				screenManager:loadScreen("MenuScreen")
			end
		end
	)

	self.time = 0

	self.buttonY = self.menuText:getHeight() * 3

	networkManager:startClient()
	networkManager:addEventListener("newServer", self.addServer, self)
	networkManager:addEventListener("startGame", self.startGame, self)
end

function JoinScreen:addServer(e)
	local button = TextField.new(nil, tostring(e.data.host))
	button:setTextColor(0xFFFFFF)
	button:setScale(0.5)
	button:setPosition(screenWidth / 2 - button:getWidth() / 2, self.buttonY)
	self:addChild(button)
	self.buttonY = self.buttonY + button:getHeight() * 2

	local serverIP = e.data.ip
	local serverID = e.data.id
	button:addEventListener(Event.TOUCHES_BEGIN, 
		function(e)
			if e:getTarget():hitTestPoint(e.touch.x, e.touch.y) then
				networkManager:connectToServer(serverID)
			end
		end
	)
end

function JoinScreen:startGame(e)
	screenManager:loadScreen("GameScreen", false)
end

function JoinScreen:update(deltaTime)
	self.time = self.time + deltaTime
	self.menuText:setY(self.menuText:getHeight() + 4 + math.sin(self.time * 4) * 1.5)
	self.background:move(BACKGROUND_MOVEMENT_SPEED * deltaTime)
end

return JoinScreen