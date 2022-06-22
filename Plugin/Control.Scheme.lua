
local pluginFolder = script:FindFirstAncestor("ThemeEditor")
local content = require(pluginFolder.Control.Content)
local scheme = {}

function scheme.getThemeString(theme)
	local baseText = require(script.Base)

	for _,category in content do
		for name ,property in category.contain do
			local color = type(theme) == "table" and theme[name] or theme[property]
			local format = "rgb(%d,%d,%d)"
			local ok = pcall(function()
				format = string.format(format,
					math.floor(color.R * 255),
					math.floor(color.G * 255),
					math.floor(color.B * 255)
				)
			end)
		
			baseText = string.gsub(baseText ,"&"..name.."&" ,format)
		end
	end
	
	return baseText
end
-- format whole basetext.


return scheme