local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local lplr = playersService.LocalPlayer

if lplr then
	lplr:Kick('Please load into a gamemode to use the script!')
end