module(..., package.seeall)

--import external classes
local tableView = require("tableView")
local util = require("util")
local scrollView = require("scrollView")

--initial values
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

function new()
	local resDir = system.ResourceDirectory
	local docDir = system.DocumentsDirectory
	local xmlFile = "ATAiPhoneRSS.xml"
	local dataURL = "http://atasite.org/xml/".. xmlFile	
	local detailID, detailScreen, detailDate, detailTitle, imageDir 
	local doLoadXML, connectionMade, newerXMLReady

	local data = {} 
	local prevImages = {}
	
	local myList, detailScreen, detailScrollView, backBtn
	
	--Setup the main screen group
	local g = display.newGroup()
	
	local function showDetails()											
		detailScrollView:remove(detailDate)
		local t = data[detailID].eventDateValue .. data[detailID].eventInfoValue
		detailDate = util.wrappedText( t, 52, 13, "Helvetica", {255,255,255} )       
		detailDate.x = 12
		detailDate.y = 60
		detailScrollView:insert( detailDate )
	
		detailScrollView:remove(detailImage)
		local detailImgName = data[detailID].imageName
		if( detailImgName == "" ) then detailImgName = "img-default.png" end
		detailImage = display.newImage( detailImgName, data[detailID].imageDir )
		detailImage.x = math.floor(detailImage.width*0.5) + detailDate.x 
		detailImage.y = detailDate.y + detailDate.height + 6 - math.floor(detailImage.height*0.5) + 80 
		detailScrollView:insert( detailImage )
		
	    --Setup the background for each item
		detailScrollView:remove(detailImageShadow)
		detailImageShadow = display.newImage( "imgShadow.png" )
		detailImageShadow.x = detailImage.x 
		detailImageShadow.y = detailImage.y
		detailScrollView:insert( detailImageShadow )
	
		detailScrollView:remove(detailTitle)
		detailTitle = util.wrappedText( data[detailID].eventTitleValue, 24, 16, "Helvetica-Bold", {255,255,255} )       
		detailTitle.x = math.floor(detailImage.width) + detailDate.x + 12
		detailTitle.y = math.floor(detailDate.y + detailDate.height)
		detailScrollView:insert( detailTitle )
	
		detailScrollView:remove(detailExcerpt)
		detailExcerpt = util.wrappedText( data[detailID].excerptValue, 36, 13, "Helvetica", {255,255,255} )       
		detailExcerpt.x = math.floor(detailImage.width) + detailDate.x + 12
		detailExcerpt.y = math.floor(detailTitle.y + detailTitle.height)
		detailScrollView:insert( detailExcerpt )
	
		detailScrollView:remove(titleLine)
		local topH = math.floor(detailTitle.height + detailExcerpt.height + 12)
		if( detailImage.height > (topH - 24) ) then
			topH = math.ceil(detailImage.height) + 24
		end
		titleLine = display.newRect( 12, 0, screenW-24, 1 ) 	
		titleLine:setFillColor( 255, 255, 255 )
		titleLine.x = screenW*0.5
		titleLine.y = detailTitle.y + topH
		detailScrollView:insert( titleLine )
	
		detailScrollView:remove(detailDescription)
	    detailDescription = util.wrappedText(data[detailID].eventDescriptionValue, 44, 14, "Helvetica", {255,255,255} );
		detailDescription.x = detailDate.x
		detailDescription.y = titleLine.y + 2
		detailScrollView:insert( detailDescription )
			
		infoLine.y = detailDescription.y + math.floor(detailDescription.height) + 24
		ATAlogoMid.y = math.floor(ATAlogoMid.height*0.5) + infoLine.y + 18 	
		detailATAInfo.y = infoLine.y + 6
	
		--detailScreen.x = calendarScreen.x + calendarScreen.width
		detailScrollView.y = display.screenOriginY
		
	end

	local function btnRelease( event )
		transition.to(myList, {time=400, x=0, transition=easing.outExpo })
		transition.to(detailScreen, {time=400, x=detailScreen.width, transition=easing.outExpo })
		transition.to(backBtn, {time=400, x=math.floor(backBtn.width*0.5)+backBtn.width, transition=easing.outExpo })
		transition.to(backBtn, {time=400, alpha=0 })
		delta, velocity = 0, 0
	end
	
	local function listButtonRelease( event )
		self = event.target
		local id = self.id
		detailID = self.id
		
		if event.target.data.categoryValue == "Sponsors" then
			system.openURL( event.target.data.permalinkValue )
		else
			showDetails()
					
			transition.to(myList, {time=400, x=-screenW, transition=easing.outExpo })
			transition.to(detailScreen, {time=400, x=0, transition=easing.outExpo })
			transition.to(backBtn, {time=400, x=math.floor(backBtn.width*0.5) + screenOffsetW*.5, transition=easing.outExpo })
			transition.to(backBtn, {time=400, alpha=1 })		
			delta, velocity = 0, 0
		end
	end

	local function setupCalendar()
		--specify the order for the groups in each category
		local headers = { "This Week", "Upcoming", "Gallery and Window Installations", "Sponsors" }
		
		if myList then myList:removeSelf()	end
		-- Create a list with header titles
		myList = tableView.newList{
			data=data, 
			default="boxBg.png",
			over="boxBg_over.png",
			onRelease=listButtonRelease,
			top=display.screenOriginY + 60,
			bottom=72,
			cat="categoryValue",
			order=headers,
			categoryBackground="catBg.png",
			callback=function(row) 
						local gg = display.newGroup()
						gg:insert(row.group)
						local d = display.newText(row.eventDateShortValue, 0, 0, native.systemFontBold, 12)
						d:setTextColor(255, 255, 255)
						d.x = math.floor(d.width*0.5 + row.group.width) + 24
						d.y = 21
						if(row.categoryValue == "Sponsors") then 
							d.isVisible = false
						end
						gg:insert(d) 
						local t
						if(row.categoryValue == "Sponsors") then 
							t = util.wrappedText( row.eventDescriptionValue, 30, 13, native.systemFont, {255,255,255} )
							t.x = 12 
							t.y = 6
						else
							t = util.wrappedText( row.eventTitleValue, 26, 14, native.systemFontBold, {255,255,255} )
							t.x = math.floor(row.group.width + 24) 
							t.y = 24
						end
						gg:insert(t) 
	
						return gg
					end
		}
	
		g:insert(1, myList)
	end
	
	local function checkForUpdate()	
		--get the size of the locally stored XML file
		local path = system.pathForFile( xmlFile, docDir ) --default xml file path
		local file = io.open( path, "r" ) 
		if not file then
			path = system.pathForFile( xmlFile, resDir ) 
			file = io.open( path, "r" ) 
		end
		local size = file:seek("end") 
		io.close( file )	

		--try to connect and get download size
		local size2get = 0
		local http = require("socket.http")
		local ltn12 = require("ltn12")
		local r, c, h = http.request {method = "HEAD", url = dataURL}
		if c == 200 then
		   size2get = tonumber(h["content-length"])
		   connectionMade = true
		else 
			print("Error contacting remote host.")
			connectionMade = false
		end

		--compare the size of the files
		if not size2get then
			print("something went wrong. not attempting download.") 
		else
			if size2get ~= size and connectionMade then
				remoteXMLNewer = true 				
			else 
				remoteXMLNewer = false 
			end
		end

	end

	local function onSystemEvent( event )
		print("event.type: ".. event.type)
	
		if( event.type == "applicationExit" or event.type == "applicationSuspend" ) then
			print("exiting...")

			--###  need to add some code to grab the relevant values to save out  ###--
						
			-- save states
			local path = system.pathForFile( "tmp.txt", docDir )		
			local file = io.open( path, "w+b" )
			file:write( currentTargetVal ..", ".. currentTarget.y ..", ".. calendarScreen.x ..", ".. detailScreen.x ..", ".. detailID) 		
			io.close( file )
		end
	end
	
	local function restorePreviousState()
		--#restore previous state, if any
		local prevStatePath = system.pathForFile( "tmp.txt", docDir )		
		local prevStateFile = io.open( prevStatePath, "r" )
		if file then
			local contents = prevStateFile:read( "*a" )
			local prevState = util.explode(", ", contents)
							
			--### need to add some code here to grab previous state variables  ###--
						
			io.close( prevStateFile )
		end
	end

	local function updateXML()	
		--store previous images in an array
		local path = system.pathForFile( xmlFile, docDir ) --default xml file path
		local file = io.open( path, "r" ) 

		if file then
			local localContents = file:read( "*a" )
			local localDataTable = util.collect(localContents)		
			io.close( file )
			
			local i = 4 --start at the 4th value in the array  
		    while i <= #localDataTable[2][1] do
				table.insert(prevImages, localDataTable[2][1][i][4]['xarg']['file']) 
				i = i + 1    -- get next index and its value
		    end
			localDataTable = nil --kill the array storing data to free up memory
		end		
		
		--start downloading new xml file
		if connectionMade then
			path = system.pathForFile( xmlFile, docDir )		
			file = io.open( path, "w+b" ) 		
			local http = require("socket.http")
			local ltn12 = require("ltn12")
			http.request{ url = dataURL, sink = ltn12.sink.file(file) }
					
			doLoadXML = true
		end
	end
			
	function loadImages(event)		
	    local i = 1 
	    while i <= #data do
			data[i].group = display.newGroup()
			
	    	local imageName = data[i].imageName
			if (imageName ~= "") then
				--save the path to the image for later use
				data[i].imageDir = imageDir
				--try to open the image that's stored from a previous download first
				local imagePath = system.pathForFile( imageName, imageDir )
				local imageFile = io.open( imagePath, "r" ) 	
				
				if not imageFile then 
					if connectionMade then 
						imagePath = system.pathForFile( imageName, imageDir )
						imageFile = io.open( imagePath, "w+b" ) 	
						local http = require("socket.http")
						local ltn12 = require("ltn12")
						http.request{ url = data[i].imageURL, sink = ltn12.sink.file(imageFile) }
					else
						--Can't download image, use default image instead
						data[i].imageDir = resDir
						imageName = "img-default.png"
					end
				else 
					io.close( imageFile )
				end
			else 
				imageName = "img-default.png"
				data[i].imageDir = resDir
			end
	
			data[i].image = display.newImage( imageName, data[i].imageDir )
			local xVal = math.floor(data[i].image.width*0.5) + 12
			local showThis = 1
			if( data[i].categoryValue == "Sponsors" ) then
				xVal = screenW - math.floor(data[i].image.width*0.5) - 12
				showThis = 0
			end
			data[i].image.x = xVal
			data[i].image.y = math.floor(data[i].image.height*0.5) + 12
			data[i].group:insert( data[i].image )
	
		    --Setup the background for each item
			data[i].bgTop = display.newImage( "imgShadow.png" )
			data[i].bgTop.x = math.floor(data[i].bgTop.width*0.5) + 12
			data[i].bgTop.y = math.ceil(data[i].bgTop.height*0.5) + 11
			data[i].bgTop.alpha = showThis
			data[i].group:insert( data[i].bgTop )
	
			i = i + 1         -- get next index and its value
	     end
			
	    --find and delete old images
	    if #prevImages > 0 then 
		    local i = 1 
		    while i <= #prevImages do
				local foundInTable = false
			    
			    local j = 1
			    while j <= #data do
					if prevImages[i] == data[j].imageName then
						foundInTable = true
					end
					j = j + 1   
				end
				
				if ( (not foundInTable) and (data[i].imageDir ~= resDir) ) then
					local deletePath = system.pathForFile( prevImages[i], data[i].imageDir )
					os.remove(deletePath)  --delete the image 
				end
				
				i = i + 1         -- get next index and its value
			end
		end
	end
		
	
	local function loadXML()	
		--check the app sandbox for an xml file
		local path = system.pathForFile( xmlFile, docDir )
		local file = io.open( path, "r" ) 
		if not file then
			path = system.pathForFile( xmlFile, resDir ) 
			file = io.open( path, "r" ) 
		end
		io.close( file )	
		
		local dataFile = io.open( path, "r" ) 
		local contents = dataFile:read( "*a" )
		local dataTable = util.collect(contents)	
		io.close( dataFile )	
			
		--#Load the data 
		--for k,v in pairs(dataTable[2][1][4][4]['xarg']) do print(k,v) end
	    for i=4, #dataTable[2][1] do
			data[i-3] = {}
	
			data[i-3].eventTitleValue		= 	dataTable[2][1][i][1][1] or ""
			data[i-3].eventDateValue 		= 	dataTable[2][1][i][2][1] or ""
			data[i-3].eventInfoValue 		= 	dataTable[2][1][i][3][1] or ""
			data[i-3].permalinkValue 		= 	dataTable[2][1][i][4][1] or ""
			data[i-3].imageURL 				= 	dataTable[2][1][i][5]['xarg']['url'] or ""
			data[i-3].imageName 			= 	dataTable[2][1][i][5]['xarg']['file'] or ""
			data[i-3].eventDescriptionValue = 	dataTable[2][1][i][6][1] or ""
			data[i-3].excerptValue 			= 	dataTable[2][1][i][7][1] or ""
			data[i-3].eventDateShortValue 	= 	dataTable[2][1][i][8][1] or ""
			data[i-3].categoryValue 		= 	dataTable[2][1][i][9][1] or ""
			data[i-3].imageDir 				= 	imageDir --set default location for each image
			
	    end

		dataTable = nil --kill the array storing data to free up memory	
	end
	
	function setupDetailScreen()			
		--setup a destination for the list items
		detailScreen = display.newGroup()
		detailScrollView = scrollView.new{ top=display.screenOriginY, bottom=80 }
					
		detailScreenTextBg = display.newImage( "gradientRectBg.png")
		detailScrollView:insert( detailScreenTextBg )
		detailScreenTextBg.x = screenW*0.5 
		detailScreenTextBg.y = math.floor(detailScreenTextBg.height*0.5) + 57
		
		infoLine = display.newRect( 12, 0, screenW-24, 1 ) 	
		infoLine:setFillColor( 255, 255, 255 )
		detailScrollView:insert( infoLine )
		
		ATAlogoMid = util.newLink{ default="logo-mid.png", over="logo-mid_over.png", onRelease=util.aLink }
		ATAlogoMid.link = "http://www.atasite.org"
		ATAlogoMid.x = math.floor(ATAlogoMid.width*0.5) + 6 
		detailScrollView:insert( ATAlogoMid )
	
		ATAInfo = "Artists' Television Access\n992 Valencia Street\nSan Francisco, CA 94110\nhttp://www.atasite.org\n"
		detailATAInfo = util.wrappedText( ATAInfo, 52, 14, "Helvetica", {255,255,255} );
		detailATAInfo.x = ATAlogoMid.x + ATAlogoMid.width - detailATAInfo.width*0.5 + 24
		detailScrollView:insert( detailATAInfo )
	
		local background = display.newRect(0, 0, screenW, detailScrollView.height)
		background:setFillColor(0,0,0)
		detailScrollView:insert(1, background)	
	
		detailScreen:insert(detailScrollView)
	
		detailScreen.x = screenW
		g:insert(1, detailScreen)
	end
	
	function setupNav()	
		local headerBg = display.newRect(0,0,screenW,display.statusBarHeight)
		headerBg:setFillColor(0,0,0)
		headerBg.y = math.floor(display.screenOriginY + headerBg.height*0.5)
		g:insert(headerBg)
		
		local navBar = display.newImage("navBar.png", 0, 0, false)
		navBar.x = screenW*.5
		navBar.y = math.floor(headerBg.y + headerBg.height*0.5 + navBar.height*0.5)
		g:insert(navBar)
		
		local navHeader = display.newText("Calendar", 0, 0, native.systemFontBold, 16)
		navHeader:setTextColor(255, 255, 255)
		navHeader.x = screenW*.5
		navHeader.y = navBar.y
		g:insert(navHeader)

		local titleBottomLine = display.newRect( 0, 60, screenW, 1 ) 
		titleBottomLine:setFillColor( 38, 38, 38 )
		g:insert( titleBottomLine )
	
		backBtn = ui.newButton{ 
			default="button-calendar.png", 
			over="button-calendar_over.png", 
			onRelease=btnRelease
		}
		backBtn.x = math.floor(backBtn.width*0.5) + 6 + screenOffsetW
		backBtn.y = navBar.y 
		backBtn.alpha = 0
		g:insert(backBtn)
	end	
		
	function setupLoop()
		if remoteXMLNewer then
			remoteXMLNewer = false
			
			print("Updating XML...")
			updateXML()			
		else 
			if doLoadXML then
				doLoadXML = false 
				print("Loading XML...")
				loadXML()			
				
				print("Loading images...")
				loadImages()
				
				print("Setting up calendar...")
				setupCalendar()	
				
				--print("Restoring previous state...")
				--restorePreviousState()
								
				print("Checking for update...")
				checkForUpdate()
			else
				--Remove the activity indicator
				native.setActivityIndicator( false )

				print("Setup done!")
				Runtime:removeEventListener("enterFrame", setupLoop)
			end
		end

	end	

	function init()
		doLoadXML = true
		detailID = 1
	    imageDir = docDir

		setupNav()		
		setupDetailScreen()

		-- Start the activity indicator
		native.setActivityIndicator( true )			
		
		--Start the setup loop
		Runtime:addEventListener("enterFrame", setupLoop)

		--Check for system events to save state variables
		--Runtime:addEventListener( "system", onSystemEvent )
	end
	
	function g:cleanUp()
		--Remove the activity indicator
		native.setActivityIndicator( false )

		myList:cleanUp()
		detailScrollView:cleanUp()

		Runtime:removeEventListener("enterFrame", setupLoop)

		g:removeSelf()
	end
	
	--Start the program!
	init()

	return g
end

