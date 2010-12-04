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

	local supportBg = display.newImage( "gradientRectBg.png", 0, 0, true )
	scrollView:insert( supportBg )
	supportBg.x = screenW*0.5 
	supportBg.y = math.floor(supportBg.height*0.5)
			
	--Setup the Support Us screen	
	local supportUsText = "Artists' Television Access relies on the support of our members, individual donors, grants, and dedicated volunteers. Show your support ATA!"
	local supportUsInfo = util.wrappedText( supportUsText, 42, 14, "Helvetica", {255,255,255} )	
	scrollView:insert( supportUsInfo )
	supportUsInfo.x = 24
	supportUsInfo.y = 18
	
	local supportBtn = { "Become a Member", "Donate", "Volunteer" }
	local supportLinks = { "http://www.atasite.org/membership/", "http://www.atasite.org/donate/", "http://www.atasite.org/volunteer/" }
	
	--Setup the linked buttons
	for i=1, #supportBtn do 
		local button = display.newGroup()
		local bg = display.newRoundedRect( 0, 0, screenW-100, 50, 6 ) 	
		bg:setFillColor( 255, 255, 255, 50 )
		bg:setStrokeColor( 255, 255, 255, 255 )
		bg.strokeWidth = 1
		button:insert( bg )
		bg.x = 0 

		local t = display.newText( supportBtn[i], 0, 0, "Helvetica", 14 )
		t:setTextColor( 255, 255, 255 )
		button:insert( t )
		t.x = 0
		t.y = math.floor(bg.height/2) - 3

		button.link = supportLinks[i]
		button:addEventListener("tap", util.aLink)
		scrollView:insert( button )	
		button.x = screenW*0.5
		button.y = math.floor(supportUsInfo.y + supportUsInfo.height + (button.height + 24)*(i-1) + 24)
	end

	--Add a background rectangle to provide a hit area for the touch
	local background = display.newRect(0, 0, screenW, scrollView.height + 24)
	background:setFillColor(0,0,0)
	scrollView:insert(1, background)

	if scrollView.height > screenH then
		scrollView:addScrollBar( 255, 255, 255, 120 )
	end

	g:insert(scrollView)

	local headerBg = display.newRect(0,0,screenW,statusBarH)
	headerBg:setFillColor(0,0,0)
	g:insert(headerBg)
	headerBg.y = math.floor(display.screenOriginY + headerBg.height*0.5)
	
	local navBar = display.newImage("navBar.png", 0, 0, false)
	g:insert(navBar)
	navBar.x = screenW*.5
	navBar.y = math.floor(headerBg.y + headerBg.height*0.5 + navBar.height*0.5)
	
	local navHeader = display.newText("Support Us", 0, 0, native.systemFontBold, 16)
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
