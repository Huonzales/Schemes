--!nocheck

------------- -------------------------- -------------
-- ThemeEditor version : v1.05
------------- -------------------------- -------------

local tinyUtils = require(script.TinyUtils)
local content = require(script.Content)
local baseText = require(script.Scheme)
local utils = require(script.Utils)
local bricks = require(script.Brick)
-- Includes

local studioService = game:GetService("StudioService")
local players = game:GetService("Players")
local pluginFolder = script:FindFirstAncestor("ThemeEditor")
local encoder = require(pluginFolder.Browse.Encode)
local asset = pluginFolder:WaitForChild("Asset")
local bindable  = Instance.new("BindableEvent")
local studio = settings().Studio
utils.plugin = plugin
-- important

local topbar = plugin:CreateToolbar("Scheme")
local button = topbar:CreateButton("Editor" ,"Edit script editor color." ,"rbxassetid://9864788280")
-- topbars

local widget = utils:newWidget("Editor" ,700 ,350)
widget.Name = "SchemeEditor"
utils:add(widget ,asset.Layout)
utils:add(widget ,asset.Port)
utils:add(widget ,asset.Editor)
utils:add(widget ,asset.Final)
-- widgets

local editorList = widget.Editor.Contain.Lists
local selector = asset.Select:Clone()
local currentMode = "custom"
local heldingItem : {}
local currentColor = {}
local value = Instance.new('Color3Value' ,script)
value.Name = 'Value'
value.Value = Color3.fromRGB(0, 0, 0)
local hue = Instance.new('IntValue' ,script)
hue.Name = 'Hue'
hue.Value = 0
local luminance = Instance.new('IntValue' ,script)
luminance.Name = 'Luminance'
luminance.Value = 0
local saturation = Instance.new('IntValue' ,script)
saturation.Name = 'Saturation'
saturation.Value = 0
-- locals


local function _resizeEditor()
	local offset = 18
	if not (editorList.Warn.Visible) then
		offset = offset + 12
	end

	local layout : UIListLayout = editorList.Layout
	local contentSize = layout.AbsoluteContentSize.Y
	editorList.CanvasSize = UDim2.fromOffset(0 ,contentSize - offset)
end
-- call to auto resize editor.


local function _resize(list ,layout)
	local contentSize = layout.AbsoluteContentSize.Y
	list.CanvasSize = UDim2.fromOffset(0 ,contentSize)
end
-- traditional resize.


local function _search(text ,content)
	local text = text or ""
	local results = {}
	text = string.lower(text)
	
	for name in content do
		local offseted = string.sub(text ,1 ,math.clamp(#text - 1 ,1 ,math.huge))
		if string.find(string.lower(name) ,offseted) then
			results[name] = true
		end
	end
	
	return results
end
-- search by table index.


local function _fsearch(text ,content)
	local text = text or ""
	local results = {}
	text = string.lower(text)
	
	for name ,main in content do
		local alternatives = main.family
		
		local offseted = string.sub(text ,1 ,math.clamp(#text - 1 ,1 ,math.huge))
		if string.find(string.lower(name) ,offseted) then
			results[name] = true
		else
			for _,ralter in alternatives do
				if string.find(string.lower(ralter) ,offseted) then
					results[name] = true
				end
			end
		end
	end
	return results
end
-- search with families features.


local function _getproperties()
	local result = {}
	for _,category in content do
		for name ,property in category.contain do
			result[name] = property
		end
	end
	return result
end
-- get all property and their nickname.


local function _getPropers()
	local propers = {}	
	for _,proper in editorList:GetChildren() do		
		if (proper.Name == "Proper") then
			table.insert(propers ,proper)
		end
	end
	return propers
end
-- get all propers in editor lists.


local function _setFocusOutline(box)
	box.Focused:Connect(function()
		box.BorderColor3 
			= Color3.fromRGB(48, 113, 255)
	end)
	box.FocusLost:Connect(function()
		box.BorderColor3 
			= Color3.fromRGB(30 ,30 ,30)
	end)
end
-- setup textbox focus outline.


local function _setProperHover(proper)
	proper.Button.MouseEnter:Connect(function()
		proper.Button.BackgroundTransparency = 0.85
	end)

	proper.Button.MouseLeave:Connect(function()
		proper.Button.BackgroundTransparency = 1
	end)
end
-- set proper's hovering


local function _isEditing(proper)
	return (selector.Parent == proper) and selector.Visible
end
-- get bool is selector is on that color.


local function _state(proper ,color ,name ,property ,on)
	if not on then
		proper.Size = UDim2.new(1 ,-15 ,0 ,18)
		proper.Button.Stroke.Enabled = false
		heldingItem = nil
		selector.Visible = false
		
	else -- on
		proper.Size = UDim2.new(1 ,-15 ,0 ,175)
		proper.Button.Stroke.Enabled = true
		selector.Visible = true
		selector.Parent = proper
		heldingItem = {
			proper = proper;
			color = color;
			name = name;
			property = property;
		}
	end
end
-- toggle proper's state.


local function _paint(name ,color)
	for _,object in widget.Port.Contain:GetChildren() do
		if (object.Name == name) then
			object.BackgroundColor3 = color
		end
	end

	if (name == "ScriptBackground") then
		widget.Port.Contain.BackgroundColor3 = color
	end
end
-- paint other thing


--local function _getForm(name ,portString ,color)
--	local colorform = string.format("rgb(%d,%d,%d)" ,math.floor(color.R * 255) ,math.floor(color.G * 255) ,math.floor(color.B * 255))
--	return string.gsub(portString ,"&"..name ,colorform)
--end
-- get color format for richtext.


local function _try()
	selector.Parent.Button.Stroke.Enabled = true
	selector.Parent.Size = UDim2.new(1 ,-15 ,0 ,175)
	_resizeEditor()
end
-- try setting stroke back.


local function _updatePort(mode ,update ,override)
	local override = override or {}
	currentMode = mode

	if (mode == "using") then
	
		widget.Port.Topbar.Using.BackgroundColor3 = Color3.fromRGB(110, 117, 255)
		widget.Port.Topbar.Custom.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
		widget.Editor.Contain.Lists.Warn.Visible = true
		widget.Port.Contain.Apply.Visible = false
		widget.Port.Contain.Reset.Visible = false
		selector.Visible = false
		
		local portString = baseText.getThemeString(studio)
		for name ,property in _getproperties() do
			local color = studio[property]

			-- portString = _getForm(name ,portString ,color)
			_paint(name ,color)

			if update then
				for _,proper in _getPropers() do
					if (proper.Label.Text == name) then
						_state(proper ,color ,name ,property ,false)
						proper.Display.BackgroundColor3 = color
						proper.Box.Text = "#"..color:ToHex()
						proper.Box.TextEditable = false
						break
					end
				end
			end
		end
		widget.Port.Contain.Label.Text = portString

	elseif (mode == "custom") then
		widget.Port.Topbar.Custom.BackgroundColor3 = Color3.fromRGB(110, 117, 255)
		widget.Port.Topbar.Using.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
		widget.Editor.Contain.Lists.Warn.Visible = false
		widget.Port.Contain.Apply.Visible = true
		widget.Port.Contain.Reset.Visible = true
		-- selector.Visible = true
		-- pcall(_try)
		
		local laziness = override and type(override) == "table" and currentColor or override
		local portString = baseText.getThemeString(laziness)
		for name ,property in _getproperties() do
			local color = type(laziness) == "table" and laziness[name] or laziness[property]
			if override[property] then
				currentColor[name] = override[property]
			end

			-- portString = _getForm(name ,portString ,color)
			_paint(name ,color)

			if update then
				for _,proper in _getPropers() do
					if (proper.Label.Text == name) then
						proper.Display.BackgroundColor3 = color
						proper.Box.Text = "#"..color:ToHex()
						proper.Box.TextEditable = true
						break
					end
				end
			end
		end
		widget.Port.Contain.Label.Text = portString
	end
	_resizeEditor()
end
-- updating port.


local function _set(proper ,name)
	proper.Display.BackgroundColor3 = Color3.fromHex(proper.Box.Text)
	currentColor[name] = proper.Display.BackgroundColor3 
	_updatePort("custom" ,false)
end
-- set color.


------------- -------------------------- -------------
-- Initalizing Plugin UIs.


local portString = baseText.getThemeString(studio)
for _,category in content do
	
	local header = asset.Header:Clone()
	header.Label.Text = category.name
	header.Parent = editorList
	
	for name ,property in category.contain do
		local color = studio[property]
		local proper = asset.Proper:Clone()
		
		proper.Label.Text = name
		proper.Display.BackgroundColor3 = color
		proper.Box.Text = "#"..color:ToHex()
		proper.Parent = editorList
		
		-- Events --
		_setFocusOutline(proper.Box)
		_setProperHover(proper)
		-- Events --
		
		local textChanged = proper.Box:GetPropertyChangedSignal("Text")
		textChanged:Connect(function()
			if (currentMode == "custom") then
				pcall(_set ,proper ,name)
			end
		end)
		
		proper.Button.MouseButton1Click:Connect(function()
			if _isEditing(proper) then
				_state(proper ,color ,name ,property ,false)
			else
				_state(proper ,color ,name ,property ,true)
				for _,rproper in _getPropers() do
					if not (rproper == proper) then
						rproper.Button.Stroke.Enabled = false
						rproper.Size = UDim2.new(1 ,-15 ,0 ,18)
					end
				end
			end
			_resizeEditor()
			bindable:Fire(proper.Display.BackgroundColor3 ,proper)
		end)
		
		_paint(name ,color)
		currentColor[name] = color
	end
end _resizeEditor()
widget.Port.Contain.Label.Text = portString
-- setting up Editor colors list.


for name ,main in bricks do
	local color = main.color
	
	local newColor = asset.Color:Clone()
	newColor.Label.Text = string.gsub(name ," " ,"")
	newColor.Display.BackgroundColor3 = color
	newColor.Parent = selector.Bricks.Lists
	
	newColor.MouseButton1Click:Connect(function()
		if (currentMode == "custom") then
			bindable:Fire(color)
		end
	end)
end 
_resize(selector.Bricks.Lists ,selector.Bricks.Lists.Layout)
-- setting up Selector colors list.


local searching = widget.Editor.Topbar.Box:GetPropertyChangedSignal("Text")
local mainSearchingContent = _getproperties()

searching:Connect(function()
	local text = widget.Editor.Topbar.Box.Text
	local all = _search(text ,mainSearchingContent)
	local hidden = {}
	
	for _,proper in _getPropers() do
		local name = proper.Label.Text
		if not all[name] then
			hidden[name] = true
			proper.Visible = false
		else proper.Visible = true
		end
	end
	
	for _,category in content do
		local haveItem = false
		for name ,_ in category.contain do
			if not hidden[name] then
				haveItem = true
				break
			end
		end
		for _,item in editorList:GetChildren() do
			if (item.Name == "Header") 
				and (item.Label.Text == category.name)
			then
				if not haveItem then
					item.Visible = false
				else item.Visible = true
				end
			end
		end
	end
end)
-- searching for something.


local bsearching = selector.Bricks.Lists.Box:GetPropertyChangedSignal("Text")
local mainSearchingContent = bricks

bsearching:Connect(function()
	local text = selector.Bricks.Lists.Box.Text
	local all = _fsearch(text ,mainSearchingContent)
	
	for _ ,frame in selector.Bricks.Lists:GetChildren() do
		if (frame.Name == "Color")  then
			if all[frame.Label.Text] then
				frame.Visible = true
			else frame.Visible = false
			end
		end
	end
	
	_resize(selector.Bricks.Lists ,selector.Bricks.Lists.Layout)
end)
-- searching for something /brick color.


widget.Port.Contain.Reset.MouseButton1Click:Connect(function()
	selector.Visible = false
	if not (selector.Parent == editorList.Layout) and selector.Parent then
		selector.Parent.Size = UDim2.new(1 ,-15 ,0 ,18)
	end
	_updatePort("custom" ,true ,studio)
end)
-- rejecting color.


widget.Port.Contain.Apply.MouseButton1Click:Connect(function()

	widget.Final.Main.Visible = true
	local result = false
	local binds = {}

	binds[1] = widget.Final.Main.Yes.MouseButton1Click:Connect(function()
		result = true
		for _,connection in binds do
			connection:Disconnect()
		end
		binds = {}
	end)

	binds[2] = widget.Final.Main.No.MouseButton1Click:Connect(function()
		for _,connection in binds do
			connection:Disconnect()
		end
		binds = {}
	end)

	repeat task.wait(0.2)
	until (#binds <= 0)
	widget.Final.Main.Visible = false

	if not result then
		return nil
	end

	for name ,property in _getproperties() do
		local color = currentColor[name]
		if not (color == studio[property]) then
			studio[property] = color
		end
	end
	heldingItem = nil
	_updatePort("custom" ,true ,studio)
end)
-- applying color ,confirmation.


bindable.Event:Connect(function(color : Color3 ,rproper)
	if heldingItem then
		local rhue ,rsat ,rlum = color:ToHSV()
		
		luminance.Value = math.floor(240 * rlum + 0.5)
		hue.Value = math.floor(239 * rhue + 0.5)	
		saturation.Value	= math.floor(240 * rsat + 0.5)
		
		selector.Picker.SatLum.Contain.Knob.Position
			= UDim2.new(rsat ,0 ,1 - rlum ,0)
		
		selector.Picker.Hue.Contain.Knob.Position
			= UDim2.new(0.5 ,0 ,1 - rhue ,0)
		
		local proper = rproper or heldingItem.proper
		proper.Box.Text = "#"..color:ToHex()
	end
end)
-- previewing ,setting color.


for _,button in widget.Port.Topbar:GetChildren() do
	if button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			_updatePort(string.lower(button.Name) ,true)
		end)
	end
end
-- chaning Section.


_setFocusOutline(widget.Editor.Topbar.Box)
button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	button:SetActive(widget.Enabled)
end)


-------------- ---------------------------- --------------
-- others


local function _updateValue()
	local rhue, rsat, rlum = value.Value:ToHSV()	
	if math.floor(239*rhue+0.5) ~= hue.Value then
		rhue = hue.Value/239
	end
	if math.floor(240*rsat+0.5) ~= saturation.Value then
		rsat = saturation.Value/240
	end
	if  math.floor(240*rlum+0.5) ~= luminance.Value then
		rlum = luminance.Value/240
	end

	value.Value = Color3.fromHSV(rhue, rsat, rlum)
	selector.Picker.SatLum.Contain.Saturation.ImageColor3 = Color3.fromHSV(hue.Value /239, 1, 1)
	
	local proper = heldingItem.proper
	proper.Box.Text = "#"..value.Value:ToHex()
end
-- update a value Color.


local function _updateSelector(x ,y)
	
	-- saturation
	local sizeX = selector.Picker.SatLum.AbsoluteSize.X
	local percentageX	= math.clamp(x /sizeX ,0 ,1)
	saturation.Value = math.floor(240 * percentageX + 0.5)
	
	-- luminence
	local sizeY = selector.Picker.SatLum.AbsoluteSize.Y
	local percentageY	= math.clamp(y /sizeY ,0 ,1)
	luminance.Value = math.floor(240 * (1- percentageY) + 0.5)
end
-- update a selector SatLum.


local function _updateSelectorR(x ,y)
	local sizeY = selector.Picker.Hue.AbsoluteSize.Y		
	local percentage = math.clamp(y /sizeY ,0 ,1)
	hue.Value =  math.floor(239 *(1- percentage) + 0.5)
end
-- update a selector Hue.

selector.Picker.Hue.Button.MouseButton1Down:Connect(function()
	local button = selector.Picker.Hue.Button
	local bind 

	bind = button.InputChanged:Connect(function(input : InputObject)
		local x ,y = input.Position.X ,input.Position.Y
		local bind2 ,bind3

		bind2 = button.MouseButton1Up:Connect(function()
			bind:Disconnect()
			bind2:Disconnect()
			bind3:Disconnect()
		end)

		bind3 = button.MouseLeave:Connect(function()
			bind:Disconnect()
			bind2:Disconnect()
			bind3:Disconnect()
		end)

		x = x - selector.Picker.Hue.AbsolutePosition.X
		y = y - selector.Picker.Hue.AbsolutePosition.Y
		selector.Picker.Hue.Contain.Knob.Position = UDim2.new(0.5 ,0 ,0 ,y)

		_updateSelectorR(x ,y)
	end)
end)
-- Hue Selector

selector.Picker.SatLum.Button.MouseButton1Down:Connect(function()
	local button = selector.Picker.SatLum.Button
	local bind 
	
	bind = button.InputChanged:Connect(function(input : InputObject)
		local x ,y = input.Position.X ,input.Position.Y
		local bind2 ,bind3

		bind2 = button.MouseButton1Up:Connect(function()
			bind:Disconnect()
			bind2:Disconnect()
			bind3:Disconnect()
		end)
		
		bind3 = button.MouseLeave:Connect(function()
			bind:Disconnect()
			bind2:Disconnect()
			bind3:Disconnect()
		end)
		
		x = x - selector.Picker.SatLum.AbsolutePosition.X
		y = y - selector.Picker.SatLum.AbsolutePosition.Y
		selector.Picker.SatLum.Contain.Knob.Position = UDim2.fromOffset(x ,y)
		
		_updateSelector(x ,y)
	end)
end)
-- SatLum Selector


local function _getUsername()
	local userId = studioService:GetUserId()
	local name = players:GetNameFromUserIdAsync(userId)
	
	return not (userId == 0)
		and name
		or "__user?"
end
-- get username.



widget.Final.Copy.No.MouseButton1Click:Connect(function()
	widget.Final.Copy.Visible = false
end)
-- close copy window.



widget.Port.Contain.Copy.MouseButton1Click:Connect(function()
	local encoding = currentMode == "custom" 
		and currentColor 
		or studio
	
	local encoded = encoder.encode(
		widget.Final.Copy.Box.Text,
		_getUsername(),
		encoding
	)
	
	widget.Final.Copy.Main.Box.Text = encoded
	widget.Final.Copy.Visible = true
end)
-- copy theme.



widget.Final.Copy.Box:GetPropertyChangedSignal("Text"):Connect(function()
	local encoding = currentMode == "custom" 
		and currentColor 
		or studio
	
	local name = widget.Final.Copy.Box.Text
	name = string.gsub(name ,":" ,"")
	name = string.gsub(name ," " ,"-")
	
	local encoded = encoder.encode(
		name,
		_getUsername(),
		encoding
	)

	widget.Final.Copy.Main.Box.Text = encoded
end)
-- name changed.



luminance.Changed:Connect(_updateValue)
saturation.Changed:Connect(_updateValue)
hue.Changed:Connect(_updateValue)

pluginFolder.Setup.Event:Connect(function(context ,color)
	if (context == "loadTheme") then
		for i,v in color do
			currentColor[i] = v
		end
		
		_updatePort("custom" ,true)
	end
end)

pluginFolder.Setup:Fire(topbar ,plugin)



