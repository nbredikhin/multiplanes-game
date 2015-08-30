local utils = {}

function utils.clamp(val, lower, upper)
    assert(val and lower and upper, "math.clamp: number expected but got nil")
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

function utils.getScreenSize()
	local width = application:getDeviceWidth()
	local height = application:getDeviceHeight()

	if string.find(application:getOrientation(), "landscape") then
		width, height = height, width
	end

	return width, height
end

function utils.fileExists(path)
	local file = io.open(path)
	if file then
		file:close()
		return true
	end
	return false
end

function utils.wrapAngle(value)
	if not value then
		return 0
	end
	value = math.mod(value, 360)
	if value < 0 then
		value = value + 360
	end
	return value
end

utils.screenWidth, utils.screenHeight = utils.getScreenSize()
return utils