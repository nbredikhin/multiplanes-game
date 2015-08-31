json 	= require "json"
utils 	= require "scripts.utils"
local ScreenManager 	= require "scripts.screens.ScreenManager"
local NetworkManager 	= require "scripts.NetworkManager" 

-- Screen size and game scale
screenWidth, screenHeight = utils:getScreenSize()
mainScale = screenHeight / 64
screenWidth, screenHeight = screenWidth / mainScale, screenHeight / mainScale

-- Setup network manager
networkManager = NetworkManager.new()

-- Setup screen manager
screenManager = ScreenManager.new()
screenManager:setScale(mainScale)
stage:addChild(screenManager)
screenManager:loadScreen("MenuScreen")