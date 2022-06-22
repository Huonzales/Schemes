--!nocheck

------------- -------------------------- -------------
-- misc collection of code often used.
------------- -------------------------- -------------


--[=[

	---- all methods ----
	utils.debounce(second ,func) --> give [func] back but function is debounced by [second] second.	
	
	utils.accumulate(second ,func) --> give [func] back but function yield after [second] second.
			any attempts to call function meanwhile will stop that yield and issue new yield.
			
	utils.switch(func) --> give [func] back but first parameter is always [state] which indicate true,false.
			this will toggle between two in each function call.
	
--]=]


local utils = {}
---- locals


function utils.debounce(second ,func)
	local disabled = false
	
	return function(...)
		if disabled then
			return nil
			
		else -- not disabled.
			disabled = true
			
			task.delay(second ,function()
				disabled = false
			end)
			
			return func(...)
		end
	end
end
-- debouncing function.


function utils.accumulate(second ,func)
	local request = 0
	
	return function(...)
		request = request + 1
		local expect = request
		
		task.delay(second ,function(...)
			if not (expect == request) then
				return nil
				
			else -- same request ,run it.
				func(...)
			end
		end ,...)
	end
end
-- accumulating function.


function utils.switch(func)
	local state = false
	
	return function(...)
		state = not state
		return func(state ,...)
	end
end
-- switch function.


------------- -------------------------- -------------
---- prewritten autocomplete

export type method<a> = (a) -> ()

export type _ = {
	debounce : (delay : number ,func : method) -> (method);
	accumulate : (delay : number ,func : method) -> (method);
	switch : (func : method<boolean>) -> (method); 
}

return utils :: _
