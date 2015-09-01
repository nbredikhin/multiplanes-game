local Background 	= require "scripts.menu.Background"
local Bullet 		= require "scripts.Bullet"
local InputManager 	= require "scripts.InputManager"
local Plane 		= require "scripts.Plane"
local Screen 		= require "scripts.screens.Screen"
local Particle 		= require "scripts.Particle"
local GameUI 		= require "scripts.GameUI"

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
	self.inputManager = InputManager.new(false, true)
	self:addChild(self.inputManager)

	-- Bullets
	self.bulletTexture = Texture.new("assets/bullet.png")
	self.bullets = {}

	-- Particles
	self.particlesTextures = {}
	self.particlesTextures["smoke"] = Texture.new("assets/particles/smoke.png")
	self.particles = {}

	-- User interface layer
	self.uiContainer = GameUI.new(self.inputManager)
	self:addChild(self.uiContainer)
	self.uiContainer:addEventListener("onFire", self.shoot, self)

	-- Networking stuff
	self.isHost = isHost

	networkManager:addEventListener("remoteUpdateName", self.remoteUpdateName, self)
	networkManager:addEventListener("remoteShoot", self.remoteShoot, self)
	networkManager:addEventListener("remoteHit", self.remoteHit, self)

	networkManager:triggerRemoteEvent("remoteUpdateName", networkManager.username)

	self.inputManager:addEventListener(InputManager.TOUCH_BEGIN, self.shoot, self)
	networkManager:setValue("username", networkManager.username)

	self.shootDelay = 0
end

function GameScreen:remoteUpdateName(e)
	local name = tostring(e.data)
	self.remotePlayer.nameText:setText(tostring(name))
end

function GameScreen:createBullet(x, y, rotation, isLocal)
	if not x or not y or not rotation then
		return
	end
	local bullet = Bullet.new(self.bulletTexture, isLocal)
	bullet:setPosition(x, y)
	bullet:setRotation(rotation)
	self.world:addChild(bullet)

	table.insert(self.bullets, bullet)
end

function GameScreen:removeBullet(index)
	if not self.bullets[index] then
		return
	end
	self.world:removeChild(self.bullets[index])
	table.remove(self.bullets, index)
end

function GameScreen:shoot()
	if self.shootDelay >= 0 then
		return
	end
	local x, y, rotation = self.localPlayer:getX(), self.localPlayer:getY(), self.localPlayer:getRotation()
	networkManager:triggerRemoteEvent("remoteShoot", json.encode({x, y, rotation}))
	self:createBullet(x, y, rotation, true)

	self.shootDelay = 0.5
end

function GameScreen:remoteShoot(e)
	local x, y, rotation = unpack(json.decode(e.data))
	self:createBullet(x, y, rotation, false)
end

function GameScreen:remoteHit(e)
	local newHealth = tonumber(e.data)
	if not newHealth then
		return
	end
	self.remotePlayer.health = newHealth
end

function GameScreen:createPlaneSmoke(plane, deltaTime)
	if plane.health > 75 then
		return
	end
	plane.smokeDelay = plane.smokeDelay - deltaTime
	if plane.smokeDelay <= 0 then
		plane.smokeDelay = math.max(0, (plane.health - 25) / 75 / 2)
		local particle = Particle.new(self.particlesTextures["smoke"])
		particle:setPosition(plane:getX(), plane:getY())
		self.world:addChild(particle)
		table.insert(self.particles, particle)
	end
end

function GameScreen:update(deltaTime)
	self.shootDelay = self.shootDelay - deltaTime

	networkManager:setValue("px", self.localPlayer:getX())
	networkManager:setValue("py", self.localPlayer:getY())
	networkManager:setValue("rot", self.localPlayer:getRotation())

	-- Update players
	self.localPlayer:update(deltaTime)
	self.remotePlayer:update(deltaTime)
	-- Particles
	self:createPlaneSmoke(self.localPlayer, deltaTime)
	self:createPlaneSmoke(self.remotePlayer, deltaTime)
	for i, particle in ipairs(self.particles) do
		particle:update(deltaTime)
		if particle.lifetime <= 0 then
			self.world:removeChild(particle)
			table.remove(self.particles, i)	
		end
	end

	-- Update UI
	self.uiContainer:setBarValue("power", self.localPlayer.power)

	-- Update bullets
	for i, bullet in ipairs(self.bullets) do
		bullet:update(deltaTime)
		local bx, by = bullet:getPosition()
		bx, by = self.world:localToGlobal(bx, by)
		if not bullet.isLocal and self.localPlayer:hitTestPoint(bx, by) then
			self.localPlayer.health = self.localPlayer.health - 25
			networkManager:triggerRemoteEvent("remoteHit", self.localPlayer.health)
			self:removeBullet(i)	
		elseif bullet.isLocal and self.remotePlayer:hitTestPoint(bx, by) then
			self:removeBullet(i)	
		elseif bullet.lifetime <= 0 then
			self:removeBullet(i)
		end
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