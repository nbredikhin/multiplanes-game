local Background 	= require "scripts.menu.Background"
local Bullet 		= require "scripts.Bullet"
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

	-- Create remote player
	self.remotePlayer = Plane.new(false)
	self.world:addChild(self.remotePlayer)
	self.remotePlayer:setPosition(0, 0)

	-- Create local player
	self.localPlayer = Plane.new(true)
	self.world:addChild(self.localPlayer)
	self.localPlayer:setPosition(32, 16)

	-- Setup input
	self.inputManager = InputManager.new()
	self:addChild(self.inputManager)

	-- Bullets
	self.bulletTexture = Texture.new("assets/bullet.png")
	self.bullets = {}

	-- Networking stuff
	self.isHost = isHost

	networkManager:addEventListener("remoteUpdateName", self.remoteUpdateName, self)
	networkManager:addEventListener("remoteShoot", self.remoteShoot, self)

	networkManager:triggerRemoteEvent("remoteUpdateName", networkManager.username)

	self.inputManager:addEventListener(InputManager.TOUCH_BEGIN, self.shoot, self)
	networkManager:setValue("username", networkManager.username)
end

function GameScreen:remoteUpdateName(e)
	local name = tostring(e.data)
	self.remotePlayer.nameText:setText(tostring(name))
end

function GameScreen:createBullet(x, y, rotation)
	if not x or not y or not rotation then
		return
	end
	local bullet = Bullet.new(self.bulletTexture)
	bullet:setPosition(x, y)
	bullet:setRotation(rotation)
	self.world:addChild(bullet)

	table.insert(self.bullets, bullet)
end

function GameScreen:shoot()
	local x, y, rotation = self.localPlayer:getX(), self.localPlayer:getY(), self.localPlayer:getRotation()
	networkManager:triggerRemoteEvent("remoteShoot", json.encode({x, y, rotation}))
	self:createBullet(x, y, rotation)
end

function GameScreen:remoteShoot(e)
	local x, y, rotation = unpack(json.decode(e.data))
	self:createBullet(x, y, rotation)
end

function GameScreen:update(deltaTime)
	networkManager:setValue("px", self.localPlayer:getX())
	networkManager:setValue("py", self.localPlayer:getY())
	networkManager:setValue("rot", self.localPlayer:getRotation())

	-- Update players
	self.localPlayer:update(deltaTime)
	self.remotePlayer:update(deltaTime)

	-- Update bullets
	for i, bullet in ipairs(self.bullets) do
		bullet:update(deltaTime)
	end

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