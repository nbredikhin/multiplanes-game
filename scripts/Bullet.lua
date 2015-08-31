local Bullet = Core.class(Sprite)

function Bullet:init(texture)
	local bitmap = Bitmap.new(texture)
	bitmap:setAnchorPoint(0.5, 0.5)
	self:addChild(bitmap)

	self.speed = 60
end

function Bullet:update(deltaTime)
	local x = self:getX()
	local y = self:getY()
	
	local rotationRad = self:getRotation() / 180 * math.pi
	local moveX = math.cos(rotationRad) * self.speed * deltaTime
	local moveY = math.sin(rotationRad) * self.speed * deltaTime

	x = x + moveX
	y = y + moveY

	self:setPosition(x, y)
end

return Bullet