local Plane = Core.class(Sprite)

function Plane:init(isLocal, colorName)
	local texturePath = "assets/plane_red.png"
	if not colorName then
		texturePath = "assets/plane_red.png"
		if not isLocal then
			texturePath = "assets/plane_blue.png"
		end
	else
		texturePath = "assets/plane_" .. tostring(colorName) .. ".png"
	end

	self.bitmap = Bitmap.new(Texture.new(texturePath))
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
	self.interpolationMul = 0.08

	self.isDead = false

	if not isLocal then
		playerName = networkManager:getValue("username") or "Unknown"
 		self.nameText = TextField.new(nil, tostring(playerName))
		self.nameText:setScale(0.25)
		self.nameText:setPosition(-self.nameText:getWidth() / 2, - self.bitmap:getHeight())
		self.nameText:setTextColor(0xFFFFFF)
		--self:addChild(self.nameText)
	end

	self.health = 100
	self.smokeDelay = 0.1
end

function Plane:update(deltaTime)
	if self.isDead then
		return
	end
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

	if not self.isLocal then
		self.remoteVars["x"] = networkManager:getValue("px") or self:getX()
		self.remoteVars["y"] = networkManager:getValue("py") or self:getY()
		self.remoteVars["rotation"] = networkManager:getValue("rot") or self:getRotation()
		self:setPower(networkManager:getValue("pow"))

		for key, value in pairs(self.remoteVars) do
			local currentValue = self:get(key)
			if key == "rotation" then
				value = utils.wrapAngle(value)
				self:setRotation(currentValue - utils.differenceBetweenAngles(value, currentValue) * 0.2)
			else
				--self:set(key, currentValue + (value - currentValue) * self.interpolationMul)
			end
		end

		self:setX(self:getX() + (self.remoteVars["x"] - self:getX()) * self.interpolationMul)
		self:setY(self:getY() + (self.remoteVars["y"] - self:getY()) * self.interpolationMul)


		if math.abs(self.remoteVars["x"] - self:getX()) > 5 then
			self:setX(self:getX() + (self.remoteVars["x"] - self:getX()) * 0.5)
		end
		if math.abs(self.remoteVars["y"] - self:getY()) > 5 then
			self:setY(self:getY() + (self.remoteVars["y"] - self:getY()) * 0.5)
		end

		if math.abs(self.remoteVars["x"] - self:getX()) > 16 then
			self:setX(self.remoteVars["x"])
		end
		if math.abs(self.remoteVars["y"] - self:getY()) > 16 then
			self:setY(self.remoteVars["y"])
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