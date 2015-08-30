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

	self.startButton = TextField.new(nil, "Start")
	self.startButton:setTextColor(0xFFFFFF)
	self.startButton:setScale(0.5)
	self:addChild(self.startButton)
	self.startButton:setPosition(screenWidth / 2 - self.startButton:getWidth() / 2, screenHeight / 2 + self.startButton:getHeight() / 2)

	self:addEventListener(Event.TOUCHES_BEGIN, self.buttonTouch, self)
end

function MenuScreen:buttonTouch(e)
	if self.startButton:hitTestPoint(e.touch.x, e.touch.y) then
		screenManager:loadScreen("GameScreen")
	end
end

function MenuScreen:update(deltaTime)
	self.time = self.time + deltaTime
	self.menuText:setY(self.menuText:getHeight() + 4 + math.sin(self.time * 4) * 1.5)
	self.background:move(BACKGROUND_MOVEMENT_SPEED * deltaTime)
end

return MenuScreen