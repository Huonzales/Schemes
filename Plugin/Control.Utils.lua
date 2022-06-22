
local utils = {}


function utils:bind(widget ,button ,onStart)
	button.Click:Connect(function()
		widget.Enabled = not widget.Enabled
		if onStart then
			onStart()
		end
	end)
end
-- bind toolbarButton with widget , optional onStart function when clicked


function utils:newWidget(name ,x ,y)
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float
		,true ,false,x ,y,x ,y
	)
	local widget = self.plugin:CreateDockWidgetPluginGui(name ,widgetInfo)
	widget.Title = name
	return widget
end
-- create new topbar.


function utils:add(widget ,child)
	child:Clone().Parent = widget
end
-- insert child into widget.


function _find(parent ,name)
	return parent[name]
end
-- find name in parent.


export type all = Plugin & Studio
return utils