local Background 		= require "scripts.menu.Background"
local Bonus 			= require "scripts.Bonus"
local Bullet 			= require "scripts.Bullet"
local ExplosionParticle = require "scripts.ExplosionParticle"
local GameUI 			= require "scripts.GameUI"
local InputManager 		= require "scripts.InputManager"
local Particle 			= require "scripts.Particle"
local Plane 			= require "scripts.Plane"
local Screen 			= require "scripts.screens.Screen"

local GameScreen = Core.class(Screen)

function GameScreen:load(isHost)
	self.WORLD_WIDTH = 160
	self.mainCameraContainer = Sprite.new()
	self:addChild(self.mainCameraContainer)
	self.shakeDelay = 0

	-- Create background
	self.background = Background.new(2)
	self.mainCameraContainer:addChild(self.background)

	-- Create world container
	self.world = Sprite.new()
	self.mainCameraContainer:addChild(self.world)

	self.bonuses = {}
	self.bonusTexture1 = Texture.new("assets/bonus1.png")
	self.bonusTexture2 = Texture.new("assets/bonus2.png")

	-- Create players
	local remotePlayerColor = "blue"
	local localPlayerColor = "red"
	if not isHost then
		remotePlayerColor = "red"
		localPlayerColor = "blue"
	end
	self.remotePlayer = Plane.new(false, remotePlayerColor)
	self.world:addChild(self.remotePlayer)
	self.remotePlayer:setPosition(32, 32)

	self.localPlayer = Plane.new(true, localPlayerColor)
	self.world:addChild(self.localPlayer)
	self.localPlayer:setPosition(16, 32)

	-- Setup input
	self.inputManager = InputManager.new(false, true)
	self:addChild(self.inputManager)

	-- Bullets
	self.bulletTexture = Texture.new("assets/bullet.png")
	self.bullets = {}

	-- Particles
	self.particlesTextures = {}
	self.particlesTextures["smoke"] = Texture.new("assets/particles/smoke.png")
	self.particlesTextures["fire"] = Texture.new("assets/particles/fire.png")
	self.particles = {}

	-- Explosions
	self.explosionsParticles = {}

	-- User interface layer
	self.uiContainer = GameUI.new(self.inputManager)
	self:addChild(self.uiContainer)
	self.uiContainer:addEventListener("onFire", self.shoot, self)

	-- Networking stuff
	self.isHost = isHost

	networkManager:addEventListener("remoteUpdateName", self.remoteUpdateName, self)
	networkManager:addEventListener("remoteShoot", self.remoteShoot, self)
	networkManager:addEventListener("remoteHit", self.remoteHit, self)
	networkManager:addEventListener("remoteDeath", self.remotePlayerDeath, self)
	networkManager:addEventListener("remoteRespawn", self.remotePlayerRespawn, self)

	networkManager:triggerRemoteEvent("remoteUpdateName", networkManager.username)

	self.world:addEventListener(Event.TOUCHES_BEGIN, self.onTouch, self)
	networkManager:setValue("username", networkManager.username)

	self.shootDelay = 0
	self.respawnDelay = 0
end

function GameScreen:onTouch(e)
	local x, y = self.world:globalToLocal(e.touch.x, e.touch.y)
	--self:createBonus(x)
	--self:playerDeath(self.localPlayer)
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

function GameScreen:createBonus(posX)
	local bonus = Bonus.new(self.bonusTexture1, self.bonusTexture2)
	bonus:setX(posX)
	bonus:setY(-bonus:getHeight())
	self.world:addChild(bonus)
	table.insert(self.bonuses, bonus)
end

function GameScreen:removeBullet(index)
	if not self.bullets[index] then
		return
	end
	self.world:removeChild(self.bullets[index])
	table.remove(self.bullets, index)
end

function GameScreen:shoot()
	if self.shootDelay >= 0 or self.localPlayer.isDead then
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

function GameScreen:createExplosionFire(explosion)
	local particle = Particle.new(self.particlesTextures["fire"])
	particle:setPosition(explosion.x, explosion.y)
	particle:update(0)
	self.world:addChild(particle)
	table.insert(self.particles, particle)
end

function GameScreen:createExplosion(x, y)
	for i = 1, 10 do
		local particle = ExplosionParticle.new()
		particle.x = x
		particle.y = y
		table.insert(self.explosionsParticles, particle)
	end
end

function GameScreen:remotePlayerDeath()
	self:playerDeath(self.remotePlayer)
end

function GameScreen:playerDeath(player)
	if player.isDead then
		return
	end
	player.health = 100
	player.isDead = true
	player:setVisible(false)
	self:createExplosion(player:getPosition())

	if player == self.localPlayer then
		self.respawnDelay = 3
		networkManager:triggerRemoteEvent("remoteDeath")
	end
	self:shakeCamera(1)
end

function GameScreen:remotePlayerRespawn()
	self:playerRespawn(self.remotePlayer)
end

function GameScreen:playerRespawn(player)
	if not player then
		return
	end
	if not player.isDead then
		return
	end
	player.health = 100
	player:setVisible(true)
	player.isDead = false
	if player == self.localPlayer then
		player:setPosition(16, 32)
		player.power = 1
		player:setRotation(0)
		networkManager:triggerRemoteEvent("remoteRespawn")
	end
end

function GameScreen:shakeCamera(delay)
	self.shakeDelay = delay
end

function GameScreen:update(deltaTime)
	self.shootDelay = self.shootDelay - deltaTime

	networkManager:setValue("px", self.localPlayer:getX())
	networkManager:setValue("py", self.localPlayer:getY())
	networkManager:setValue("rot", self.localPlayer:getRotation())
	networkManager:setValue("pow", self.localPlayer.power)

	-- Update players
	self.localPlayer:update(deltaTime)
	self.remotePlayer:update(deltaTime)

	-- Ground hit
	if self.localPlayer:getY() > screenHeight then
		self:playerDeath(self.localPlayer)
	elseif self.localPlayer:getY() < 0 then
		self.localPlayer:setPower(self.localPlayer.power - self.localPlayer.powerSpeed * deltaTime * 2)
	end

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
	-- Explosions
	for i, explosion in ipairs(self.explosionsParticles) do
		explosion:update(deltaTime)
		if explosion.particleDelay <= 0 then
			self:createExplosionFire(explosion)
		end
		if explosion.lifetime <= 0 then
			table.remove(self.explosionsParticles, i)
		end
	end

	-- Update UI
	self.uiContainer:setBarValue("power", self.localPlayer.power)

	-- Update bullets
	for i, bullet in ipairs(self.bullets) do
		bullet:update(deltaTime)
		local bx, by = bullet:getPosition()
		bx, by = self.world:localToGlobal(bx, by)
		if not self.localPlayer.isDead and not bullet.isLocal and self.localPlayer.bitmap:hitTestPoint(bx, by) then
			self.localPlayer.health = self.localPlayer.health - 25
			if self.localPlayer.health <= 0 then
				self:playerDeath(self.localPlayer)
			end
			networkManager:triggerRemoteEvent("remoteHit", self.localPlayer.health)
			self:removeBullet(i)	
		elseif not self.remotePlayer.isDead and bullet.isLocal and self.remotePlayer.bitmap:hitTestPoint(bx, by) then
			self:removeBullet(i)	
		elseif bullet.lifetime <= 0 then
			self:removeBullet(i)
		end
	end

	-- Update bonuses
	for i, bonus in ipairs(self.bonuses) do
		bonus:update(deltaTime)
		if bonus:getY() - bonus:getHeight() > screenHeight then
			self.world:removeChild(bonus)
			table.remove(self.bonuses, i)
		end
	end

	-- World bounds
	if self.localPlayer:getX() > self.WORLD_WIDTH then
		self.localPlayer:setX(0)
	elseif self.localPlayer:getX() < 0 then
		self.localPlayer:setX(self.WORLD_WIDTH)
	end

	-- Camera following player
	local worldX = -self.localPlayer:getX() + screenWidth / 2
	worldX = math.max(worldX, -self.WORLD_WIDTH + screenWidth)
	worldX = math.min(worldX, 0)
	self.background:move(worldX - self.world:getX())
	self.world:setX(worldX)

	-- Camera shaking
	if self.shakeDelay > 0 then	
		local shakeX = math.random() * self.shakeDelay * 4 - self.shakeDelay * 2
		local shakeY = math.random() * self.shakeDelay * 3 - self.shakeDelay * 1.5
		self.mainCameraContainer:setPosition(shakeX, shakeY)
		self.shakeDelay = self.shakeDelay - deltaTime
	else
		self.mainCameraContainer:setPosition(0, 0)
	end

	-- Input
	if not self.localPlayer.isDead then
		self.localPlayer:setRotation(self.localPlayer:getRotation() + self.inputManager.valueX * self.localPlayer.rotationSpeed * deltaTime)
		local valueY = 0
		if self.inputManager.valueY > 0 then
			valueY = self.inputManager.valueY
		else
			valueY = -1
		end
		self.localPlayer:setPower(self.localPlayer.power - valueY * self.localPlayer.powerSpeed * deltaTime)
	end

	-- Respawn
	if self.localPlayer.isDead then
		self.respawnDelay = self.respawnDelay - deltaTime
		if self.respawnDelay <= 0 then
			self:playerRespawn(self.localPlayer)
		end
	end
end

return GameScreen