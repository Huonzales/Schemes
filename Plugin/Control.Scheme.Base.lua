
local pluginFolder = script:FindFirstAncestor("ThemeEditor")
local content = require(pluginFolder.Control.Content)


local function assign(text ,property ,bold)
	local form = "<font color=\"&"..property.."&\">%s"..text.."%s</font>"
	return bold
		and string.format(form ,"<b>" ,"</b>") 
		or string.format(form ,"" ,"")
end

local baseText = [[|<-- TODO ,23 ,true>| |<: try this cool plugin! ,22 ,true>|

|<local ,16 ,true>| |<function ,13 ,true>| |<_yield ,18 ,false>||<() ,8 ,false>|
	|<return ,15 ,true>| |<wait ,17 ,true>||<&a ,8 ,false>||<1 ,6 ,false>||<&b ,8 ,false>| |<, ,12 ,false>||<print ,17 ,false>||<&a ,8 ,false>||<"done" ,7 ,false>||<&b ,8 ,false>|
|<end ,15 ,true>|

|<local ,16 ,true>| |<bool ,2 ,false>| |<, ,12 ,false>||<self ,10 ,true>| |<= ,12 ,false>| |<true ,11 ,true>| |<, ,12 ,false>||<nil ,9 ,true>|
|<export type ,14 ,true>| |<testing ,2 ,false>| |<= ,12 ,false>| |<{} ,8 ,false>|

|<local ,16 ,true>| |<part ,2 ,false>| |<: ,12 ,false>| |<Part ,2 ,false>|
|<part ,2 ,false>||<. ,12 ,false>||<Anchored ,20 ,false>| |<= ,12 ,false>| |<bool ,2 ,false>|
|<part ,2 ,false>||<: ,12 ,false>||<Destroy ,19 ,false>||<() ,8 ,false>|

|<local ,16 ,true>| |<selectedText ,3 ,false>|
|<local ,16 ,true>| |<MatchingText ,2 ,false>|
|<MatchingText ,2 ,false>| |<= ,12 ,false>| |<nil ,9 ,true>|

|<local ,16 ,true>| |<FindingText ,2 ,false>|
|<ocal ,2 ,false>|
]]

local properties = {
	[1] = [[Selection Background Color]];
	[2] = [[Text Color]];
	[3] = [[Selection Color]];
	[4] = [[Current Line Highlight Color]];
	[5] = [[Background Color]];
	[6] = [[Number Color]];
	[7] = [[String Color]];
	[8] = [[Bracket Color]];
	[9] = [["nil" Color]];
	[10] = [["self" Color]];
	[11] = [[Bool Color]];
	[12] = [[Operator Color]];
	[13] = [["function" Color]];
	[14] = [[Luau Keyword Color]];
	[15] = [[Keyword Color]];
	[16] = [["local" Color]];
	[17] = [[Built-in Function Color]];
	[18] = [[Function Name Color]];
	[19] = [[Method Color]];
	[20] = [[Property Color]];
	[21] = [[Whitespace Color]];
	[22] = [[Comment Color]];
	[23] = [["TODO" Color]];
	[24] = [[Warning Color]];
	[25] = [[Find Selection Background Color]];
	[26] = [[Matching Word Background Color]];
	[27] = [[Debugger Current Line Color]];
	[28] = [[Error Color]];
	[29] = [[Debugger Error Line Color]];
	[30] = [[Secondary Text Color]];
	[31] = [[Menu Item Background Color]];
	[32] = [[Primary Text Color]];
	[33] = [[Selected Menu Item Background Color]];
	[34] = [[Script Editor Scrollbar Handle Color]];
	[35] = [[Ruler Color]];
	[36] = [[Script Editor Scrollbar Background Color]];
}

local skip = 0
for reading = 1 ,math.huge ,1 do
	if (skip > reading) then
		continue
	elseif (#baseText < reading) then
		break
	end
	
	local char = string.sub(baseText ,reading ,reading +1)
	if (char == "|<") then
		local ended = string.find(baseText ,">|" ,reading)
		if ended then
			local request = string.sub(baseText ,reading +2 ,ended -1)
			local params = string.split(request ," ,")
			
			local numuric = tonumber(params[2])
			local fullname = properties[numuric]
			
			local index
			for _,category in content do
				if index then
					break
				end
				for name ,full in category.contain do
					if (full == fullname) then
						index = name
						break
					end
				end
			end
			
			local bold = (params[3] == "true")
			local text = params[1] 
			local property = index
			
			local format = assign(text ,property ,bold)
			baseText = string.sub(baseText ,1 ,reading -1)
				..format
				..string.sub(baseText ,ended +2 ,#baseText)
			
			skip = ended + 1
		end
	end
end

baseText = string.gsub(baseText ,"&a" ,"(")
baseText = string.gsub(baseText ,"&b" ,")")

return baseText