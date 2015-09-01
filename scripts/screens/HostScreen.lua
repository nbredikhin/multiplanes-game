local Screen 		= require "scripts.screens.Screen"
local Background 	= require "scripts.menu.Background" 

local HostScreen = Core.class(Screen)

local BACKGROUND_MOVEMENT_SPEED = 25

function HostScreen:load()
	self.background = Background.new()
	self:addChild(self.background)

	self.menuText = TextField.new()
	self.menuText:setText("HOST GAME")
	self.menuText:setTextColor(0xFFFFFF)
	self:addChild(self.menuText)
	self.menuText:setPosition(screenWidth / 2 - self.menuText:getWidth() / 2, 10)

	self.time = 0

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


	local info = TextField.new(nil, "Room name: " .. networkManager.username)
	info:setTextColor(0xFFFFFF)
	info:setScale(0.4)
	info:setPosition(screenWidth / 2 - info:getWidth() / 2, screenHeight / 2)
	self:addChild(info)

	self.waitingText = TextField.new(nil, "Waiting for another player to connect...")
	self.waitingText:setTextColor(0xFFFFFF)
	self.waitingText:setScale(0.35)
	self.waitingText:setPosition(screenWidth / 2 - self.waitingText:getWidth() / 2, info:getY() + info:getHeight() + self.waitingText:getHeight())
	self:addChild(self.waitingText)

	networkManager:startServer()
	networkManager:addEventListener("startGame", self.startGame, self)
end

function HostScreen:update(deltaTime)
	self.time = self.time + deltaTime
	self.menuText:setY(self.menuText:getHeight() + 4 + math.sin(self.time * 4) * 1.5)
	self.background:move(BACKGROUND_MOVEMENT_SPEED * deltaTime)

	self.waitingText:setAlpha(math.sin(self.time * 6) * 0.4 + 0.6)
end

function HostScreen:startGame(e)
	screenManager:loadScreen("GameScreen", true)
end

return HostScreen