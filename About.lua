module(..., package.seeall)

function new(param)
	local statusBarH = display.statusBarHeight
	if system.getInfo("platformName") == "Android" then
		statusBarH = 0
	end
	local navBarH = 39
	local topBoundary = display.screenOriginY + statusBarH +  navBarH 

	local g = display.newGroup()

	-- Setup a scrollable content group
	local scrollView = scrollView.new{ top=topBoundary, bottom=display.screenOriginY+48 }
			
	--#Setup the About screen
	local aboutBg = display.newImage( "gradientRectBg.png" )
	scrollView:insert( aboutBg )
	aboutBg.x = screenW*0.5 
	aboutBg.y = math.floor(aboutBg.height*0.5)
	
	local logo = display.newImage( "ATA-logo.png", 0, 0, true )
	scrollView:insert( logo )
	logo.x = math.floor(screenW*0.5 - 8)
	logo.y = math.floor(logo.height*0.5) + 24

	local aboutInfoText = "Artists' Television Access is a nonprofit, artist-run, experimental media arts gallery, founded in 1984. ATA hosts film and video screenings, exhibitions, performances and a cable access television program.\n\n      Artists' Television Access\n      992 Valencia Street\n      San Francisco, CA 94110\n      http://www.atasite.org\n"
	local aboutInfo = util.wrappedText( aboutInfoText, 44, 14, "Helvetica", {255,255,255} )
	scrollView:insert( aboutInfo )
	aboutInfo.x = 24
	aboutInfo.y = logo.y + math.floor(aboutInfo.height*0.5) - 48
	
	local divLine = display.newRect( 24, 0, screenW-48, 1 ) 	
	divLine:setFillColor( 255, 255, 255 )
	scrollView:insert( divLine )
	divLine.y = aboutInfo.y + aboutInfo.height + 12

	--#multiple credits
	local credits = { "ggnmd", "glyphish", "ansca" }
	local creditLinks = { "http://www.ggnmd.com/iPhone/", "http://glyphish.com/", "http://anscamobile.com" }
	local creditBtn = {} 
	for i = 1, #credits do
		creditBtn[i] = util.newLink{ default="credit-"..credits[i]..".png", over="credit-"..credits[i].."_over.png", onRelease=util.aLink }
		creditBtn[i].link = creditLinks[i]
		scrollView:insert( creditBtn[i] )

		creditBtn[i].x = screenW*0.5 
		creditBtn[i].y = divLine.y + 80*(i-1) + 48
	end
	
	local footerText = "Artists' Television Access is supported in part by Grants for the Arts/San Francisco Hotel Tax Fund, The Christensen Fund, individual members, donors, and volunteers."
	local footerInfo = util.wrappedText( footerText, 48, 12, "Helvetica", {255,255,255} )
	scrollView:insert( footerInfo )
	footerInfo.x = 28
	footerInfo.y = creditBtn[#creditBtn].y + math.floor(creditBtn[#creditBtn].height) 

	local background = display.newRect(0, 0, screenW, scrollView.height+24)
	background:setFillColor(0,0,0)
	scrollView:insert(1, background)

	scrollView:addScrollBar( 255, 255, 255, 120 )

	g:insert(scrollView)

	local headerBg = display.newRect(0,0,screenW,statusBarH)
	g:insert(headerBg)
	headerBg:setFillColor(0,0,0)
	headerBg.y = math.floor(display.screenOriginY + headerBg.height*0.5)
	
	local navBar = display.newImage("navBar.png", 0, 0, false)
	g:insert(navBar)
	navBar.x = screenW*.5
	navBar.y = math.floor(headerBg.y + headerBg.height*0.5 + navBar.height*0.5)
	
	local navHeader = display.newText("About", 0, 0, native.systemFontBold, 16)
	navHeader:setTextColor(255, 255, 255)
	g:insert(navHeader)
	navHeader.x = screenW*.5
	navHeader.y = navBar.y

	function g:cleanUp()
		scrollView:cleanUp()
		g:removeSelf()
	end
		
	return g
end
