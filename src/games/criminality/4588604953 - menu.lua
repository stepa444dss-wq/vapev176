local vape = shared.vape

for _, v in {'Invisible', 'HitBoxes'} do
	vape:Remove(v)
end

task.spawn(function()
	task.wait(1)
	if vape and vape.CreateNotification then
		vape:CreateNotification('Criminality', 'Please load into a gamemode to use the script!', 10, 'alert')
	end
end)