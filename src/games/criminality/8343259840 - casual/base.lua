local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local vape = shared.vape

for _, v in {'Invisible', 'HitBoxes'} do
	vape:Remove(v)
end