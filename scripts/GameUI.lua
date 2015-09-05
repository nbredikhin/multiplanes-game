local GameUI = Core.class(Sprite)

function GameUI:init(inputManager)
	self.BUTTON_ALPHA_UP = 0.2
	self.BUTTON_ALPHA_DOWN = 0.8

	self.inputManager = inputManager

	self.buttons = {}
	self.buttons["down"] = Bitmap.new(Texture.new("assets/ui/down.png"))
	self.buttons["down"]:setPosition(1, screenHeight - self.buttons["down"]:getHeight() - 1)

	self.buttons["fire"] = Bitmap.new(Texture.new("assets/ui/fire.png"))
	self.buttons["fire"]:setPosition(1, self.buttons["down"]:getY() - self.buttons["fire"]:getHeight() - 1)

	self.buttons["right"] = Bitmap.new(Texture.new("assets/ui/right.png"))
	self.buttons["right"]:setX(screenWidth - self.buttons["right"]:getWidth() - 1)
	self.buttons["right"]:setY(screenHeight - self.buttons["right"]:getHeight() - 1)

	self.buttons["left"] = Bitmap.new(Texture.new("assets/ui/left.png"))
	self.buttons["left"]:setX(self.buttons["right"]:getX() - self.buttons["left"]:getWidth() - 1)
	self.buttons["left"]:setY(self.buttons["right"]:getY())

	--[[self.buttons["fire"] = Bitmap.new(Texture.new("assets/ui/fire.png"))
	self.buttons["fire"]:setX(self.buttons["left"]:getX())
	self.buttons["fire"]:setY(self.buttons["left"]:getY() - self.buttons["fire"]:getHeight() - 1)]]

	self.bars = {}
	-- Power bar
	local powerBarBackground = Bitmap.new(Texture.new("assets/ui/bar.png"))
	powerBarBackground:setX(self.buttons["down"]:getX() + self.buttons["down"]:getWidth() + 1)
	powerBarBackground:setY(self.buttons["down"]:getY())
	self:addChild(powerBarBackground)

	self.bars["power"] = Bitmap.new(Texture.new("assets/ui/bar_l.png"))
	self.bars["power"]:setPosition(powerBarBackground:getPosition())
	self.bars["power"].posY = self.bars["power"]:getY()
	self:addChild(self.bars["power"])

	self:setBarValue("power", 1)

	for k, v in pairs(self.buttons) do
		v:setAlpha(self.BUTTON_ALPHA_UP)
		self:addChild(v)
		v:addEventListener(Event.TOUCHES_BEGIN, self.buttonTouchBegin, self)
	end

	self.scoreText = TextField.new(nil, "0:0")
	self.scoreText:setY(self.scoreText:getHeight() + 1)
	self.scoreText:setTextColor(0xFFFFFF)
	self.scoreText:setAlpha(0.5)
	self:addChild(self.scoreText)

	self:setScore(3, 5)

	stage:addEventListener(Event.TOUCHES_END, self.buttonTouchEnd, self)
end

function GameUI:setScore(score1, score2)
	self.scoreText:setText(score1 .. ":" .. score2)
	self.scoreText:setX(screenWidth / 2 - self.scoreText:getWidth() / 2)
end

function GameUI:setBarValue(name, value)
	if not self.bars[name] then
		return
	end
	self.bars[name]:setScaleY(value)
	self.bars[name]:setY(self.bars[name].posY + self.bars[name]:getHeight() / value - self.bars[name]:getHeight() - (1-value))
	self.bars[name]:setColorTransform(1 - value, value, 0, 1)
end

function GameUI:buttonTouch(button, isDown)
	local mul = 0
	if isDown then
		mul = 1
	end
	if button == self.buttons["right"] then
		self.inputManager.valueX = 1 * mul
	elseif button == self.buttons["left"] then
		self.inputManager.valueX = -1 * mul
	elseif button == self.buttons["down"] then
		self.inputManager.valueY = 1 * mul
	end
end

function GameUI:buttonTouchBegin(e)
	if not e:getTarget():hitTestPoint(e.touch.x, e.touch.y) then
		return
	end
	local button = e:getTarget()
	button:setAlpha(self.BUTTON_ALPHA_DOWN)
	if button == self.buttons["fire"] then
		self:dispatchEvent(Event.new("onFire")) 
	else
		self:buttonTouch(button, true)
	end
end

function GameUI:buttonTouchEnd(e)
	if not e:getTarget():hitTestPoint(e.touch.x, e.touch.y) then
		return
	end
	local button = e:getTarget()
	for k, v in pairs(self.buttons) do
		v:setAlpha(self.BUTTON_ALPHA_UP)
		self:buttonTouch(v, false)
	end
	
	--self:buttonTouch(button, false)
end

return GameUI