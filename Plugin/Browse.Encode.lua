
local pluginFolder = script:FindFirstAncestor("ThemeEditor")
local content = require(pluginFolder.Control.Content)

local nicknames = {}
local module = {}
module.ordered = {
	[[Selection Background Color]];
	[[Text Color]];
	[[Selection Color]];
	[[Current Line Highlight Color]];
	[[Background Color]];
	[[Number Color]];
	[[String Color]];
	[[Bracket Color]];
	[["nil" Color]];
	[["self" Color]];
	[[Bool Color]];
	[[Operator Color]];
	[["function" Color]];
	[[Luau Keyword Color]];
	[[Keyword Color]];
	[["local" Color]];
	[[Built-in Function Color]];
	[[Function Name Color]];
	[[Method Color]];
	[[Property Color]];
	[[Whitespace Color]];
	[[Comment Color]];
	[["TODO" Color]];
	[[Warning Color]];
	[[Find Selection Background Color]];
	[[Matching Word Background Color]];
	[[Debugger Current Line Color]];
	[[Error Color]];
	[[Debugger Error Line Color]];
	[[Secondary Text Color]];
	[[Menu Item Background Color]];
	[[Primary Text Color]];
	[[Selected Menu Item Background Color]];
	[[Script Editor Scrollbar Handle Color]];
	[[Ruler Color]];
	[[Script Editor Scrollbar Background Color]];
}

for _ ,rmain in module.ordered do
	local rname
	
	for _,category in content do
		if rname then
			break
		end
		for name ,property in category.contain do
			if (rmain == property) then
				rname = name ;break
			end
		end
	end
	nicknames[rname] = rmain
end


function module.encode(name ,owner ,content)
	
	local name = name == "" and "UnnamedTheme" or name
	local configured = {}
	if (type(content) == "table") then
		for index ,v in content do
			if nicknames[index] then
				configured[nicknames[index]] = v
			else configured[index] = v
			end
		end
		
	else 
		configured = content
	end
	
	local encodeString = name..":"..owner..":"
	for ix = 1 ,#module.ordered ,1 do
		encodeString = encodeString..configured[module.ordered[ix]]:ToHex()
	end
	
	return encodeString
end
-- not exactly encode but it works


function module.decode(encoded)
	local parts = string.split(encoded ,":")
	
	local total = parts[3]
	local own = parts[2]
	local name = parts[1]
	local colors = {}
	
	repeat 
		local now = 0
		for _ in colors do
			now = now + 1
		end
		
		local part = string.sub(total ,1 ,6)
		total = string.sub(total ,7 ,#total)
		
		local aproperty = module.ordered[now + 1]
		local usingName 
		
		for _,category in content do
			if usingName then
				break
			end
			for name ,property in category.contain do
				if (aproperty == property) then
					usingName = name ;break
				end
			end
		end
		
		colors[usingName] = Color3.fromHex("#"..part)
	until (#total <= 0)
	
	return name ,own ,colors
end
-- rearrage a Color3


return module
