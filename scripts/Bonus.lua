local Bonus = Core.class(Sprite)

local BONUS_COLORS = {
	{1, 0.2, 0.2},
	{0.2, 0.2, 1},
	{0.2, 1, 0.2}
}

function Bonus:init(bonusTexture1, bonusTexture2, bonusType)
	if not bonusType then
		bonusType = math.random(1, 3)
	end
	self.FALLING_SPEED = 7

	self.container = Sprite.new()
	self:addChild(self.container)

	self.parachute = Bitmap.new(bonusTexture1)
	self.container:addChild(self.parachute)

	self.box = Bitmap.new(bonusTexture2)
	self.container:addChild(self.box)
	self.box:setPosition(4, 12)

	self.container:setPosition(-self.container:getWidth() * 0.5, -self.container:getHeight() * 0.2)

	self.time = 0

	self.box:setColorTransform(unpack(BONUS_COLORS[bonusType]))
end

function Bonus:update(deltaTime)
	self:setY(self:getY() + self.FALLING_SPEED * deltaTime)
	self.time = self.time + deltaTime

	self:setRotation(math.cos(self.time) / math.pi * 20)
end

return Bonus