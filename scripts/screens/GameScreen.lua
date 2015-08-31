local Background 	= require "scripts.menu.Background"
local InputManager 	= require "scripts.InputManager"
local Plane 		= require "scripts.Plane"
local Screen 		= require "scripts.screens.Screen"

local GameScreen = Core.class(Screen)

function GameScreen:load(isHost)
	-- Create world container
	self.world = Sprite.new()
	self:addChild(self.world)

	-- Create background
	self.background = Background.new()
	self.world:addChild(self.background)

	-- Create local player
	self.localPlayer = Plane.new(true)
	self.world:addChild(self.localPlayer)
	self.localPlayer:setPosition(32, 16)

	-- Create remote player
	self.remotePlayer = Plane.new(false)
	self.world:addChild(self.remotePlayer)
	self.remotePlayer:setPosition(0, 0)

	-- Setup input
	self.inputManager = InputManager.new()
	self:addChild(self.inputManager)

	self.isHost = isHost
end

function GameScreen:update(deltaTime)
	networkManager:setValue("px", self.localPlayer:getX())
	networkManager:setValue("py", self.localPlayer:getY())
	networkManager:setValue("rot", self.localPlayer:getRotation())

	self.localPlayer:update(deltaTime)
	self.remotePlayer:update(deltaTime)
	
	-- World bounds
	if self.localPlayer:getX() > self.background:getWidth() then
		self.localPlayer:setX(0)
	elseif self.localPlayer:getX() < 0 then
		self.localPlayer:setX(self.background:getWidth())
	end

	-- Camera following player
	local worldX = -self.localPlayer:getX() + screenWidth / 2
	worldX = math.max(worldX, -self.background:getWidth() + screenWidth)
	worldX = math.min(worldX, 0)
	self.world:setX(worldX)

	-- Input
	self.localPlayer:setRotation(self.localPlayer:getRotation() + self.inputManager.valueX * self.localPlayer.rotationSpeed * deltaTime)
	self.localPlayer:setPower(self.localPlayer.power - self.inputManager.valueY * self.localPlayer.powerSpeed * deltaTime)
end

return GameScreen