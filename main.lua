-- ATA iPhone App
-- Version 1.1
-- Created by Gilbert Guerrero, http://ggnmd.com

--import external classes
ui = require("ui")
util = require("util")
tableView = require("tableView")
scrollView = require("scrollView")
viewController = require("viewController")

--initial values
screenW, screenH = display.contentWidth, display.contentHeight
viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local mainView, tabView, currentScreen, lastScreen, lastDetailID, lastY, tabBar
local firstRun = true

local function restorePreviousState()
	local prevState = {}

	--#restore previous state, if any
	local path = system.pathForFile( "tmp.txt", system.DocumentsDirectory )		
	local file = io.open( path, "r" )
	if file then
		local contents = file:read( "*a" )
		prevState = util.explode(", ", contents)
		io.close( file )
	end
	
	if prevState[1] and prevState[1] ~= "" then
	
		loadScreen(prevState[1], firstRun)
		if prevState[1] == "About" then
			tabBar.selected(tabBar[3])
		elseif prevState[1] == "SupportUs" then
			tabBar.selected(tabBar[4])		
		end

		if prevState[1] == "Calendar" then
			currentScreen:scrollTo(prevState[2]) 
			if prevState[3] and prevState[3] ~= "" then
				print("loading previous id: ".. prevState[3])
				currentScreen:showDetailScreen( prevState[3] )
			end
		end

	else
		loadScreen("Calendar", firstRun)
	end
	
	firstRun = false
end

local function savePreviousState()
	local detailID, saveY = "", ""
	if lastScreen == "Calendar" then
		detailID = currentScreen.detailID or ""
		saveY = currentScreen[1].y or ""
	end

	-- save states
	local path = system.pathForFile( "tmp.txt", system.DocumentsDirectory )		
	local file = io.open( path, "w+b" )
	file:write( lastScreen ..", ".. saveY ..", ".. detailID) 		
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
			lastY = currentScreen[1].y
		end
	
		if t.id == 1 then
			loadScreen("Calendar", firstRun)
			currentScreen:scrollTo(lastY) 
			if lastDetailID then 
				currentScreen:showDetailScreen( lastDetailID )
			end
		elseif t.id == 2 then
			loadScreen("About")
		elseif t.id == 3 then
			loadScreen("SupportUs")
		end

		tabBar.selected(t)
	end

	return true
end

function loadScreen(newScreen, param)
	if currentScreen then
		currentScreen:cleanUp()
	end
	currentScreen = require(newScreen).new(param)
	tabView:insert(currentScreen)
	
	--Save the screen name for the previous state variables
	lastScreen = newScreen
	
	return true
end

init()