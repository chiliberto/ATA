module(..., package.seeall)

--import external classes
local scrollView = require("scrollView")
local util = require("util")

--initial values
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight


function new()
	local g = display.newGroup()

	-- Setup a scrollable content group
	local scrollView = scrollView.new{ top=0, bottom=48 }
			
	--Setup the Support Us screen	
	local supportUsText = "Artists' Television Access relies on the support of our members, individual donors, grants, and dedicated volunteers. Show your support ATA!"
	
	local supportUsInfo = util.wrappedText( supportUsText, 42, 14, "Helvetica", {255,255,255} )
	
	scrollView:insert( supportUsInfo )
	supportUsInfo.x = 24
	supportUsInfo.y = 85
	
	local supportBtn = { "Become a Member", "Donate", "Volunteer" }
	local supportLinks = { "http://www.atasite.org/membership/", "http://www.atasite.org/donate/", "http://www.atasite.org/volunteer/" }
	
	--Setup the linked buttons
	for i=1, #supportBtn do 
		local button = display.newGroup()
		local bg = display.newRoundedRect( 0, 0, screenW-100, 50, 6 ) 	
		bg:setFillColor( 255, 255, 255, 50 )
		bg:setStrokeColor( 255, 255, 255, 255 )
		bg.strokeWidth = 1
		bg.x = 0 
		button:insert( bg )
		local t = display.newText( supportBtn[i], 0, 0, "Helvetica", 14 )
		t:setTextColor( 255, 255, 255 )
		t.x = 0
		t.y = math.floor(bg.height/2) - 3
		button:insert( t )
		button.link = supportLinks[i]
		button:addEventListener("tap", util.aLink)
		button.x = screenW*0.5
		button.y = math.floor(supportUsInfo.y + supportUsInfo.height + (button.height + 24)*(i-1) + 24)
		scrollView:insert( button )	
	end

	--Add a background rectangle to provide a hit area for the touch
	local background = display.newRect(0, 0, screenW, scrollView.height)
	background:setFillColor(0,0,0)
	scrollView:insert(1, background)

	g:insert(scrollView)

	local headerBg = display.newRect(0,0,screenW,display.statusBarHeight)
	headerBg:setFillColor(0,0,0)
	headerBg.y = math.floor(display.screenOriginY + headerBg.height*0.5)
	g:insert(headerBg)
	
	local navBar = display.newImage("navBar.png", 0, 0, false)
	navBar.x = screenW*.5
	navBar.y = math.floor(headerBg.y + headerBg.height*0.5 + navBar.height*0.5)
	g:insert(navBar)
	
	local navHeader = display.newText("Support Us", 0, 0, native.systemFontBold, 16)
	navHeader:setTextColor(255, 255, 255)
	navHeader.x = screenW*.5
	navHeader.y = navBar.y
	g:insert(navHeader)

	function g:cleanUp()
		scrollView:cleanUp()
		g:removeSelf()
	end
	
	return g
end
