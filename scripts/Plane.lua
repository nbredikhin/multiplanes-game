local Plane = Core.class(Sprite)

function Plane:init()
	local bitmap = Bitmap.new(Texture.new("assets/plane.png"))
	bitmap:setAnchorPoint(0.5, 0.5)
	self:addChild(bitmap)

	self.rotationSpeed = 360 / 3
	self.rotationLimit = 60
	self.rotationLimitMul = 2.5

	self.power = 1
	self.powerSpeed = 0.5

	self.speed = 20
	self.gravity = 20

	self.oldSetRotation = Sprite.setRotation
end

function Plane:update(deltaTime)
	local x = self:getX()
	local y = self:getY()
	
	local rotationRad = self:getRotation() / 180 * math.pi
	local moveX = math.cos(rotationRad)
	local moveY = math.sin(rotationRad)

	local moveSpeed = self.speed * self.power
	local gravitySpeed = moveY + self.gravity * (1 - self.power)

	x = x + moveX * moveSpeed * deltaTime
	y = y + (moveY * moveSpeed + gravitySpeed) * deltaTime

	self:setPosition(x, y)
end

function Plane:setPower(power)
	if not power then
		return
	end
	power = math.max(power, 0)
	power = math.min(power, 1)
	self.power = power
end

function Plane:setRotation(rotation)
	Sprite.setRotation(self, utils.wrapAngle(rotation))
end

return Plane