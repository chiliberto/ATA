module(..., package.seeall)

--import external classes
local scrollView = require("scrollView")
local util = require("util")

--initial values
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight


function new(param)
	local g = display.newGroup()

	-- Setup a scrollable content group
	local scrollView = scrollView.new{ top=display.screenOriginY, bottom=80 }
			
	--#Setup the About screen
	local aboutBg = display.newImage( "gradientRectBg.png" )
	aboutBg.x = screenW*0.5 
	aboutBg.y = math.floor(aboutBg.height*0.5) + 57
	scrollView:insert( aboutBg )
	
	local logo = display.newImage( "ATA-logo.png" )
	logo.x = math.floor(screenW*0.5 - 8)
	logo.y = math.floor(logo.height*0.5) + 85
	scrollView:insert( logo )

	local aboutInfoText = "Artists' Television Access is a nonprofit, artist-run, experimental media arts gallery, founded in 1984. ATA hosts film and video screenings, exhibitions, performances and a cable access television program.\n\n      Artists' Television Access\n      992 Valencia Street\n      San Francisco, CA 94110\n      http://www.atasite.org\n"
	local aboutInfo = util.wrappedText( aboutInfoText, 44, 14, "Helvetica", {255,255,255} )
	aboutInfo.x = 24
	aboutInfo.y = logo.y + math.floor(aboutInfo.height*0.5) - 48
	scrollView:insert( aboutInfo )
	
	local divLine = display.newRect( 24, 0, screenW-48, 1 ) 	
	divLine:setFillColor( 255, 255, 255 )
	divLine.y = aboutInfo.y + aboutInfo.height + 12
	scrollView:insert( divLine )

	--#multiple credits
	local credits = { "ggnmd", "glyphish", "ansca" }
	local creditLinks = { "http://www.ggnmd.com/iPhone/", "http://glyphish.com/", "http://anscamobile.com" }
	local creditBtn = {} 
	for i = 1, #credits do
		creditBtn[i] = util.newLink{ default="credit-"..credits[i]..".png", over="credit-"..credits[i].."_over.png", onRelease=util.aLink }
		creditBtn[i].link = creditLinks[i]
		creditBtn[i].x = screenW*0.5 
		creditBtn[i].y = divLine.y + 80*(i-1) + 48
		scrollView:insert( creditBtn[i] )
	end
	
	local footerText = "Artists' Television Access is supported in part by Grants for the Arts/San Francisco Hotel Tax Fund, The Christensen Fund, individual members, donors, and volunteers."
	local footerInfo = util.wrappedText( footerText, 48, 12, "Helvetica", {255,255,255} )
	footerInfo.x = 28
	footerInfo.y = creditBtn[#creditBtn].y + math.floor(creditBtn[#creditBtn].height) 
	scrollView:insert( footerInfo )

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
	
	local navHeader = display.newText("About", 0, 0, native.systemFontBold, 16)
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
