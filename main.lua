-- ATA iPhone App
-- Version 1.1
-- Created by Gilbert Guerrero, http://ggnmd.com

--import external classes
local ui = require("ui")

--import external classes
local ui = require("ui")
local viewController = require("viewController")

local mainView, tabView, currentScreen, tabBar
	
local function init(event)
	mainView = display.newGroup()	

	tabView = display.newGroup()	
	mainView:insert(tabView)

	loadScreen("Calendar")
	
	tabBar = viewController.newTabBar{ 
			background = "tabBar.png", 
			tabs = { "Calendar", "About", "Support Us" }, 
			default = {"tabBtn-1.png", "tabBtn-2.png", "tabBtn-3.png", }, 
			over = {"tabBtn-1_over.png", "tabBtn-2_over.png", "tabBtn-3_over.png", }, 
			onRelease = showScreen 
		}
	tabBar.y = display.contentHeight - tabBar.height - display.screenOriginY
	mainView:insert(tabBar)
		
	tabBar.selected()
end

function showScreen(event)
	local t = event.target
	local phase = event.phase
	 
	if phase == "ended" then 
		if t.id == 1 then
			loadScreen("Calendar")
		elseif t.id == 2 then
			loadScreen("About")
		elseif t.id == 3 then
			loadScreen("SupportUs")
		end

		tabBar.selected(t)
	end

	return true
end

function loadScreen(newScreen)
	if currentScreen then
		currentScreen:cleanUp()
	end
	currentScreen = require(newScreen).new()
	tabView:insert(currentScreen)
	
	return true
end

init()