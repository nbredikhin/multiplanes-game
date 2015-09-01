local ExplosionParticle = Core.class()

function ExplosionParticle:init()
	self.x = 0
	self.y = 0
	local maxSpeedX = 150
	local maxSpeedY = 150
	self.sx = math.random(-maxSpeedX, maxSpeedX) / 10
	self.sy = math.random(-maxSpeedY, maxSpeedY) / 10
	self.gravity = 10
	self.lifetime = math.abs(self.sy / maxSpeedY * 10) + 0.5
	self.particleDelayMax = 0.04
	self.particleDelay = 0
end

function ExplosionParticle:update(deltaTime)
	self.sy = self.sy + self.gravity * deltaTime
	self.x = self.x + self.sx * deltaTime
	self.y = self.y + self.sy * deltaTime
	self.lifetime = self.lifetime - deltaTime
	if self.particleDelay <= 0 then
		self.particleDelay = self.particleDelayMax
	end
	self.particleDelay = self.particleDelay - deltaTime
end

return ExplosionParticle