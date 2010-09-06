-- viewController.lua
-- Version 0.1

module(..., package.seeall)

--initial values
local screenW, screenH = display.contentWidth, display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

function newTabBar(params)
	local background = params.background
	local tabs = params.tabs
	local default = params.default
	local over = params.over
	local onRelease = params.onRelease

	local tabBar = display.newGroup()
	
	if background then
		local tabBG = display.newImage("tabBar.png")
		tabBar:insert(tabBG)
	end
	
	if not default then 
		default = {}
		for i=1, #tabs do
			table.insert(default, "tab".. i ..".png")	 
		end
	end
	if not over then 
		over = {}
		for i=1, #tabs do
			table.insert(over, "tab".. i .."_over.png")	 
		end
	end
	
	tabBar.y = math.floor(viewableScreenH - tabBar.height)
	tabBar.x = 0
		
	--create the tabs
	for i=1, #tabs do 
		local tab = ui.newButton{ 
				default = default[i], 
				over = over[i], 
				onRelease = onRelease,
				text = tabs[i],
				font = "Helvetica",
				size = 11,
				offset = 14
			}
		tabBar:insert(tab)
		
		local numberOfTabs = #tabs
		local tabButtonWidth = tab.width
		local totalButtonWidth = tabButtonWidth * numberOfTabs
		local tabSpacing = (screenW - totalButtonWidth)/(numberOfTabs+1)

		tab.x = math.floor(tab.width*(i-1) + tabSpacing * i + tab.width*0.5)
		tab.y = math.floor(tab.height*0.5) + 1

		tab.id = i
	end

	tabBar.selected = function(target)
			if not target then target = tabBar[2] end
			if tabBar.highlight then tabBar:remove(tabBar.highlight) end
			
			local highlight = ui.newButton{ 
					default = over[target.id], 
					over = default[target.id], 
					onRelease = onRelease,
					text = tabs[target.id],
					font = "Helvetica",
					size = 11,
					offset = 14
				}
			highlight.id = target.id
			tabBar:insert(highlight)
			
			highlight.x = target.x
			highlight.y = target.y 

			tabBar.highlight = highlight
	end
		
	return tabBar
end
