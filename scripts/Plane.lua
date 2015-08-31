local Plane = Core.class(Sprite)

function Plane:init(isLocal)
	self.bitmap = Bitmap.new(Texture.new("assets/plane.png"))
	self.bitmap:setAnchorPoint(0.5, 0.5)
	self:addChild(self.bitmap)

	self.rotationSpeed = 360 / 3
	self.rotationLimit = 60
	self.rotationLimitMul = 2.5

	self.power = 1
	self.powerSpeed = 0.5

	self.speed = 30
	self.gravity = 20

	self.oldSetRotation = Sprite.setRotation

	self.isLocal = isLocal
	self.remoteVars = {}
	self.interpolationMul = 0.2

	if not isLocal then
		playerName = networkManager:getValue("username") or "Unknown"
 		self.nameText = TextField.new(nil, tostring(playerName))
		self.nameText:setScale(0.25)
		self.nameText:setPosition(-self.nameText:getWidth() / 2, - self.bitmap:getHeight())
		self.nameText:setTextColor(0xFFFFFF)
		self:addChild(self.nameText)
		self.bitmap:setColorTransform(0.2, 0.5, 1, 1)
	end
end

function Plane:update(deltaTime)
	if self.isLocal then
		-- Limit power
		if self:getRotation() >= 270 - self.rotationLimit and self:getRotation() <= 270 + self.rotationLimit then
			local rotationDiff = 1 - math.abs(270 - self:getRotation()) / self.rotationLimit
			self:setPower(self.power - self.powerSpeed * self.rotationLimitMul * rotationDiff * deltaTime)
		end
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
	else
		self.remoteVars["x"] = networkManager:getValue("px") or 0
		self.remoteVars["y"] = networkManager:getValue("py") or 0
		self.remoteVars["rotation"] = networkManager:getValue("rot") or 0

		for key, value in pairs(self.remoteVars) do
			local currentValue = self:get(key)
			if key == "rotation" then
				value = utils.wrapAngle(value)
				self:setRotation(currentValue - utils.differenceBetweenAngles(value, currentValue)* self.interpolationMul)
			else
				self:set(key, currentValue + (value - currentValue) * self.interpolationMul)
			end
		end
	end
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