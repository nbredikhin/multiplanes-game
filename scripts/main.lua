utils = require "scripts.utils"

-- Screen size and game scale
screenWidth, screenHeight = utils:getScreenSize()
mainScale = screenHeight / 64
screenWidth, screenHeight = screenWidth / mainScale, screenHeight / mainScale

-- Setup screen manager
local ScreenManager = require "scripts.screens.ScreenManager"
screenManager = ScreenManager.new()
screenManager:setScale(mainScale)
stage:addChild(screenManager)
screenManager:loadScreen("GameScreen")