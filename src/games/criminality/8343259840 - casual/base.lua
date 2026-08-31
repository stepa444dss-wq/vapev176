local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local vape = shared.vape

for _, v in {'Invisible', 'HitBoxes', 'Killaura', 'TargetStrafe', 'Jesus', 'Timer', 'Swim'} do
	vape:Remove(v)
end

-- AntiFall stub for Criminality
vape:Remove('AntiFall')
vape.Categories.Blatant:CreateModule({
	Name = 'AntiFall',
	Function = function(callback)
		if callback then
			vape:CreateNotification('AntiFall', 'AntiFall is currently a stub for Criminality', 3, 'info')
		end
	end,
	Tooltip = 'Prevents you from falling into the void (WIP).'
})