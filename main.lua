-- ATA iPhone App
-- Version 1.1
-- Created by Gilbert Guerrero, http://ggnmd.com

--import external classes
local ui = require("ui")
local util = require("util")
local viewController = require("viewController")

local mainView, tabView, currentScreen, lastScreen, lastDetailID, tabBar

local function restorePreviousState()
	--#restore previous state, if any
	local path = system.pathForFile( "tmp.txt", system.DocumentsDirectory )		
	local file = io.open( path, "r" )
	local prevState
	if file then
		local contents = file:read( "*a" )
		prevState = util.explode(", ", contents)
								
		io.close( file )
	end
	if prevState[1] ~= "" then
		loadScreen(prevState[1])
		if prevState[2] then
			print("loading previous id: ".. prevState[2])
			currentScreen:showDetailScreen( prevState[2] )
		end
	else
		loadScreen("Calendar")
	end
end

local function savePreviousState()
	local detailID = currentScreen.detailID

	-- save states
	local path = system.pathForFile( "tmp.txt", system.DocumentsDirectory )		
	local file = io.open( path, "w+b" )
	file:write( lastScreen ..", ".. detailID) 		
	io.close( file )
end

local function onSystemEvent( event )
	print("event.type: ".. event.type)

	if event.type == "applicationStart" then	
		restorePreviousState()		
	elseif( event.type == "applicationExit" or event.type == "applicationSuspend" ) then
		savePreviousState()
	end
end

local function init(event)
	mainView = display.newGroup()	

	tabView = display.newGroup()	
	mainView:insert(tabView)

	--loadScreen("Calendar")
	
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

	--Check for system events to save state variables
	Runtime:addEventListener( "system", onSystemEvent )
end

function showScreen(event)
	local t = event.target
	local phase = event.phase
	 
	if phase == "ended" then 
		if lastScreen == "Calendar" then
			lastDetailID = currentScreen.detailID
			print(lastDetailID)
		end
	
		if t.id == 1 then
			loadScreen("Calendar")
			if lastDetailID then currentScreen:showDetailScreen( lastDetailID ) end
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
	
	--Save the screen name for the previous state variables
	lastScreen = newScreen
	
	return true
end

init()