local Particle = Core.class(Bitmap)
	
function Particle:init()
	self.sx = math.random(-5, 5) / 10
	self.sy = math.random(-5, 5) / 10
	self:setRotation(math.random(360))
	self.lifetime = 0.5
end

function Particle:update(deltaTime)
	self:setPosition(self:getX() + self.sx * deltaTime, self:getY() + self.sy * deltaTime)
	self.lifetime = self.lifetime - deltaTime
	self:setAlpha(self.lifetime / 0.5)
	self:setScale(0.75 - self.lifetime / 0.8 + 0.25)
	self:setColorTransform(self.lifetime / 0.5, self.lifetime / 0.5, self.lifetime / 0.5, self.lifetime / 0.5)
end

return Particle