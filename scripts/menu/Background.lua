local Background = Core.class(Sprite)

local BACKGROUND_LAYERS_COUNT 	= 3
local BACKGROUND_MAX_WIDTH 		= 256
local BACKGROUND_LAYERS_DEPTHS 	= {0, 0.5, 0.75}

function Background:init()
	self.layers = {}
	for i = 1, BACKGROUND_LAYERS_COUNT do
		local layerTexture = Texture.new("assets/background/" .. tostring(i) .. ".png")

		local bitmap1 = Bitmap.new(layerTexture)
		local bitmap2 = Bitmap.new(layerTexture)
		bitmap2:setX(bitmap1:getWidth())

		local layer = Sprite.new()
		layer:addChild(bitmap1)
		layer:addChild(bitmap2)

		self:addChild(layer)
		table.insert(self.layers, layer)
	end
end

function Background:move(dx)
	for i, layer in ipairs(self.layers) do
		layer:setX(layer:getX() + dx * BACKGROUND_LAYERS_DEPTHS[i])
		if layer:getX() + layer:getWidth() < screenWidth then
			layer:setX(layer:getX() + layer:getWidth() / 2)
		elseif layer:getX() > 0 then
			layer:setX(layer:getX() - layer:getWidth() / 2)
		end
	end
end

return Background