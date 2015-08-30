local Background 	= require "scripts.menu.Background"
local InputManager 	= require "scripts.InputManager"
local Plane 		= require "scripts.Plane"
local Screen 		= require "scripts.screens.Screen"

local GameScreen = Core.class(Screen)

function GameScreen:load()
	-- Create world container
	self.world = Sprite.new()
	self:addChild(self.world)

	-- Create background
	local background = Background.new()
	self.world:addChild(background)

	-- Create player
	self.player = Plane.new()
	self.world:addChild(self.player)
	self.player:setPosition(32, 16)

	-- Setup input
	self.inputManager = InputManager.new()
	self:addChild(self.inputManager)
end

function GameScreen:update(deltaTime)
	self.player:update(deltaTime)

	-- Input
	self.player:setRotation(self.player:getRotation() + self.inputManager.valueX * self.player.rotationSpeed * deltaTime)
	self.player:setPower(self.player.power - self.inputManager.valueY * self.player.powerSpeed * deltaTime)
end

return GameScreen