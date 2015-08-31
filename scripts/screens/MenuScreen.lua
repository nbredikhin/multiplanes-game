local Screen 		= require "scripts.screens.Screen"
local Background 	= require "scripts.menu.Background" 

local MenuScreen = Core.class(Screen)

local BACKGROUND_MOVEMENT_SPEED = 25

function MenuScreen:load()
	self.background = Background.new()
	self:addChild(self.background)

	self.menuText = TextField.new()
	self.menuText:setText("MAIN MENU")
	self.menuText:setTextColor(0xFFFFFF)
	self:addChild(self.menuText)
	self.menuText:setPosition(screenWidth / 2 - self.menuText:getWidth() / 2, 10)

	self.time = 0

	self.hostButton = TextField.new(nil, "Host game")
	self.hostButton:setTextColor(0xFFFFFF)
	self.hostButton:setScale(0.5)
	self:addChild(self.hostButton)
	self.hostButton:setPosition(screenWidth / 2 - self.hostButton:getWidth() / 2, screenHeight / 2 + self.hostButton:getHeight() / 2)

	-- Just for test
	self.joinButton = TextField.new(nil, "Join game")
	self.joinButton:setTextColor(0xFFFFFF)
	self.joinButton:setScale(0.5)
	self:addChild(self.joinButton)
	self.joinButton:setPosition(screenWidth / 2 - self.joinButton:getWidth() / 2, self.hostButton:getY() + self.hostButton:getHeight() * 2)
	
	self:addEventListener(Event.TOUCHES_BEGIN, self.buttonTouch, self)

	networkManager:disconnect()
end

function MenuScreen:buttonTouch(e)
	if self.hostButton:hitTestPoint(e.touch.x, e.touch.y) then
		screenManager:loadScreen("HostScreen")
	elseif self.joinButton:hitTestPoint(e.touch.x, e.touch.y) then
		screenManager:loadScreen("JoinScreen")
	end
end

function MenuScreen:update(deltaTime)
	self.time = self.time + deltaTime
	self.menuText:setY(self.menuText:getHeight() + 4 + math.sin(self.time * 4) * 1.5)
	self.background:move(BACKGROUND_MOVEMENT_SPEED * deltaTime)
end

return MenuScreen