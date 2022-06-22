
local pluginFolder = script:FindFirstAncestor("ThemeEditor")
-- studioService = game:GetService("StudioService")
local players = game:GetService("Players")
local setup = pluginFolder.Setup
local asset = pluginFolder.Asset
local topbar ,plugin = setup.Event:Wait()
local pluginSave = "themeEditor0x1"
-- preparation

local baseText = require(pluginFolder.Control.Scheme)
local utils = require(pluginFolder.Control.Utils)
local encoder = require(script.Encode)
-- imports

local button = topbar:CreateButton("Archives" ,"Where you save your themes." ,"rbxassetid://9864786437")
local widget = utils:newWidget("Archives" ,275 ,350)
widget.Name = "SchemeBrowser"
utils:add(widget ,asset.Browser)
utils:add(widget ,asset.Final.Copy)
-- topbar ,widget


local _l = plugin:GetSetting(pluginSave) or {
	{
	};
	{
	};
}


local defaults = require(script.Default)
for _,theme in defaults do
	if not table.find(_l[2] ,theme)
		and not table.find(_l[1] ,theme)
	then
		table.insert(_l[1] ,theme)
	end
end


plugin:SetSetting(pluginSave ,_l)
-- setting up default data


local function _cleanList()
	for _,child in widget.Browser.Contain.Lists:GetChildren() do
		if (child.Name == "Theme") then
			child:Destroy()
		end
	end
end
-- clean the list.



local function _fromBrowser()
	return {}
end
-- get theme list from browser.



local function _resize(list ,layout)
	local contentSize = layout.AbsoluteContentSize.Y
	list.CanvasSize = UDim2.fromOffset(0 ,contentSize)
end
-- traditional resize.



local function _paint(frame ,name ,color)
	for _,object in frame.Contain:GetChildren() do
		if (object.Name == name) then
			object.BackgroundColor3 = color
		end
	end

	if (name == "ScriptBackground") then
		frame.Contain.BackgroundColor3 = color
	end
end
-- paint other thing



local function _loadCategory(rname)
	_cleanList() -- clean the list.
	
	local load = not (rname == "Browser") 
		and plugin:GetSetting(pluginSave)[rname == "Owned" and 1 or 2] 
		or _fromBrowser()
	
	for _,button in widget.Browser.Pages:GetChildren() do
		if button:IsA("TextButton") then
			button.BackgroundColor3 = Color3.fromRGB(53, 53, 53)
		end
		widget.Browser.Pages[rname].BackgroundColor3 = Color3.fromRGB(110, 117, 255)
	end
	
	for index ,main in load do
		local name ,owner ,info = encoder.decode(main)
		
		local theme = asset.Theme:Clone()
		theme.Parent = widget.Browser.Contain.Lists
		theme.Contain.Label.Text = string.gsub(baseText.getThemeString(info) ,"plugin" ,"theme")
		
		theme.Own.Text = "@"..owner
		theme.Main.Text = name
		
		for name ,color in info do
			_paint(theme ,name ,color)
		end
		
		
		theme.Button.MouseButton1Click:Connect(function()
			for _,child in widget.Browser.Contain.Lists:GetChildren() do
				if (child.Name == "Theme") then
					child.Load.Visible = false
				end
			end
			theme.Load.Visible = true
		end)
		
		theme.Button.MouseEnter:Connect(function()
			theme.Frame.BackgroundColor3 = Color3.fromRGB(84, 84, 84)
			theme.Contain.BorderColor3 = theme.Frame.BackgroundColor3
			theme.Frame.BorderColor3  = theme.Frame.BackgroundColor3
		end)
		
		theme.Button.MouseLeave:Connect(function()
			theme.Frame.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
			theme.Contain.BorderColor3 = theme.Frame.BackgroundColor3
			theme.Frame.BorderColor3  = theme.Frame.BackgroundColor3
		end)
		
		theme.Load.No.MouseButton1Click:Connect(function()
			theme.Load.Visible = false
		end)
		
		theme.Load.Yes.MouseButton1Click:Connect(function()
			setup:Fire("loadTheme" ,info)
			theme.Load.Visible = false
		end)
		
		theme.Void.MouseButton1Click:Connect(function()
			theme.Voidr.Visible = true
		end)
		
		theme.Voidr.No.MouseButton1Click:Connect(function()
			theme.Voidr.Visible = false
		end)

		theme.Voidr.Yes.MouseButton1Click:Connect(function()
			local storage = plugin:GetSetting(pluginSave)
			local i = table.remove(storage[rname == "Owned" and 1 or 2] ,index)
			plugin:SetSetting(pluginSave ,storage)
			theme.Voidr.Visible = false
			_loadCategory(rname)
		end)
		
		theme.Favor.MouseButton1Click:Connect(function()
			local storage = plugin:GetSetting(pluginSave)
			if not (rname == "Favor") then
				table.remove(storage[1] ,index)
				table.insert(storage[2] ,main)
				plugin:SetSetting(pluginSave ,storage)
				_loadCategory(rname)
			else
				table.remove(storage[2] ,index)
				table.insert(storage[1] ,main)
				plugin:SetSetting(pluginSave ,storage)
				_loadCategory(rname)
			end
		end)
		
		theme.Share.MouseButton1Click:Connect(function()
			widget.Copy.Visible = true
			widget.Copy.Main.Box.Text = main
		end)
		
		if (rname == "Favor") then
			theme.Favor["Favorite-border"].Visible = false
			theme.Favor.Favorite.Visible = true
		end
	end
	widget.Browser.Contain.Lists.ZAdd.Visible = not (rname == "Favor")
	_resize(widget.Browser.Contain.Lists ,widget.Browser.Contain.Lists.Layout)
end
-- load a category.



for _,button in widget.Browser.Pages:GetChildren() do
	if button:IsA("TextButton") then
		button.MouseButton1Click:Connect(function()
			_loadCategory(button.Name)
		end)
	end
end _loadCategory("Owned")
-- category buttons.



widget.Copy.No.MouseButton1Click:Connect(function()
	widget.Copy.Visible = false
end)
widget.Copy.Box:Destroy()



widget.Browser.Contain.Lists.ZAdd.Add.MouseButton1Click:Connect(function()
	local encoded = widget.Browser.Contain.Lists.ZAdd.Box.Text
	local ok ,name ,owner ,info = pcall(function()
		return encoder.decode(encoded)
	end)
	if ok and name and owner and info then
		local storage = plugin:GetSetting(pluginSave)
		table.insert(storage[1] ,encoded)
		plugin:SetSetting(pluginSave ,storage)
		widget.Browser.Contain.Lists.ZAdd.Box.Text = ""
		_loadCategory("Owned")
	end
end)



button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
	button:SetActive(widget.Enabled)
end)
-- topbar button.