local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local userInputService = cloneref(game:GetService('UserInputService'))
local lplr = playersService.LocalPlayer
local vape = shared.vape

-- Remove unwanted universal modules
for _, v in {'Invisible', 'HitBoxes', 'Killaura', 'TargetStrafe', 'Jesus', 'Timer', 'Swim'} do
	vape:Remove(v)
end

-- AntiFall (No Fall Damage for Criminality)
vape:Remove('AntiFall')
run(function()
	local NoFallDamageHookOriginal
	local AntiFall
	local function installNoFallDamageHook()
		if NoFallDamageHookOriginal or not hookmetamethod or not getnamecallmethod then return end

		local events = replicatedStorage:FindFirstChild('Events')
		local fall_event = events and events:FindFirstChild('__RZDONL')

		local function namecallHook(self, ...)
			local method = getnamecallmethod()
			if AntiFall and AntiFall.Enabled and method == 'FireServer' and (self == fall_event or tostring(self) == '__RZDONL') then
				local args = { ... }
				if args[1] == 'FlllD' or args[1] == 'FllH' or args[1] == 'FallH' or args[1] == 'FallD' then
					return
				end
			end
			return NoFallDamageHookOriginal(self, ...)
		end

		if newcclosure then
			namecallHook = newcclosure(namecallHook)
		end

		local ok, orig = pcall(hookmetamethod, game, '__namecall', namecallHook)
		if ok then
			NoFallDamageHookOriginal = orig
		end
	end

	AntiFall = vape.Categories.Blatant:CreateModule({
		Name = 'AntiFall',
		Function = function(callback)
			if callback then
				installNoFallDamageHook()
			end
		end,
		Tooltip = 'Prevents fall damage by blocking fall damage remotes.'
	})
end)

-- Fly (Criminality Bypass)
vape:Remove('Fly')
run(function()
	local Fly
	local FlySpeed
	local RotateWithCamera
	local VerticalSpeed
	local remoteSpamToken = 0
	local frozenBodyCFrames = {}
	local bodyOffsets = {}
	local lastFlyCFrame

	local function freezeBodyPartsExceptTorso(char, torso, keepSavedCFrames)
		if not char then return end
		for _, inst in ipairs(char:GetChildren()) do
			if inst:IsA('BasePart') and inst ~= torso and inst.Name ~= 'HumanoidRootPart' then
				if keepSavedCFrames then
					frozenBodyCFrames[inst] = frozenBodyCFrames[inst] or inst.CFrame
					inst.CFrame = frozenBodyCFrames[inst]
				end
				inst.AssemblyLinearVelocity = Vector3.zero
				inst.AssemblyAngularVelocity = Vector3.zero
				inst.Velocity = Vector3.zero
				inst.RotVelocity = Vector3.zero
			end
		end
	end

	local function placeBodyPartsOnTorso(char, torso)
		if not char or not torso then return end
		for _, inst in ipairs(char:GetChildren()) do
			if inst:IsA('BasePart') and inst ~= torso and inst.Name ~= 'HumanoidRootPart' then
				inst.CFrame = bodyOffsets[inst] and (torso.CFrame * bodyOffsets[inst]) or torso.CFrame
				inst.AssemblyLinearVelocity = Vector3.zero
				inst.AssemblyAngularVelocity = Vector3.zero
				inst.Velocity = Vector3.zero
				inst.RotVelocity = Vector3.zero
			end
		end
	end

	Fly = vape.Categories.Blatant:CreateModule({
		Name = 'Fly',
		Function = function(callback)
			if callback then
				local char = lplr.Character
				local Torso = char and (char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso') or char:FindFirstChild('HumanoidRootPart'))
				local hum = char and char:FindFirstChildOfClass('Humanoid')
				if not char or not Torso or not hum then
					Fly:Toggle()
					return
				end

				hum.PlatformStand = true
				local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
				local SPEED = 0
				local flyCF = Torso.CFrame
				local desiredVel = Vector3.zero
				frozenBodyCFrames = {}
				bodyOffsets = {}
				lastFlyCFrame = flyCF

				for _, inst in ipairs(char:GetChildren()) do
					if inst:IsA('BasePart') and inst ~= Torso and inst.Name ~= 'HumanoidRootPart' then
						bodyOffsets[inst] = Torso.CFrame:ToObjectSpace(inst.CFrame)
					end
				end

				freezeBodyPartsExceptTorso(char, Torso, true)

				remoteSpamToken = remoteSpamToken + 1
				local token = remoteSpamToken

				local events = replicatedStorage:FindFirstChild('Events')
				local Event = events and events:FindFirstChild('__RZDONL')

				task.spawn(function()
					while Fly.Enabled and token == remoteSpamToken do
						local c = lplr.Character
						local hrp = c and c:FindFirstChild('HumanoidRootPart')
						if hrp and Event then
							pcall(function()
								Event:FireServer('-r__r3', Vector3.zero, hrp.CFrame)
							end)
						end
						runService.Heartbeat:Wait()
					end
				end)

				local torsoAttachment = Torso:FindFirstChildOfClass('Attachment')
				if not torsoAttachment then
					torsoAttachment = Instance.new('Attachment')
					torsoAttachment.Name = 'FlyAttachment'
					torsoAttachment.Parent = Torso
					Fly:Clean(torsoAttachment)
				end

				local BG = Instance.new('AlignOrientation')
				local BV = Instance.new('LinearVelocity')

				BG.RigidityEnabled = true
				BG.Parent = workspace
				BG.Attachment0 = torsoAttachment
				BG.Mode = Enum.OrientationAlignmentMode.OneAttachment
				BG.CFrame = flyCF
				Fly:Clean(BG)

				BV.Parent = workspace
				BV.Attachment0 = torsoAttachment
				BV.VectorVelocity = Vector3.zero
				BV.MaxForce = math.huge
				Fly:Clean(BV)

				local function updateFlyCFOrientation()
					if not RotateWithCamera.Enabled then return end
					local cam = workspace.CurrentCamera
					if not cam then return end
					local pos = flyCF.Position
					local look = cam.CFrame.LookVector
					local flatLook = Vector3.new(look.X, 0, look.Z)
					if flatLook.Magnitude < 1e-3 then return end
					flyCF = CFrame.lookAt(pos, pos + flatLook)
				end

				Fly:Clean(runService.PreSimulation:Connect(function(dt)
					if not Fly.Enabled then return end
					local c = lplr.Character
					local t = c and (c:FindFirstChild('Torso') or c:FindFirstChild('UpperTorso') or c:FindFirstChild('HumanoidRootPart'))
					if not t then return end

					flyCF = flyCF + (desiredVel * dt)
					updateFlyCFOrientation()
					lastFlyCFrame = flyCF

					t.CFrame = flyCF
					BG.CFrame = flyCF
					BV.VectorVelocity = desiredVel

					t.Velocity = Vector3.new(50, 50, 50)
					t.RotVelocity = Vector3.zero
					freezeBodyPartsExceptTorso(c, t, true)

					local h = c:FindFirstChildOfClass('Humanoid')
					if h then
						h.PlatformStand = true
					end
				end))

				Fly:Clean(runService.PostSimulation:Connect(function()
					if not Fly.Enabled then return end
					local c = lplr.Character
					local t = c and (c:FindFirstChild('Torso') or c:FindFirstChild('UpperTorso') or c:FindFirstChild('HumanoidRootPart'))
					if not t then return end

					updateFlyCFOrientation()
					lastFlyCFrame = flyCF
					t.CFrame = flyCF

					t.AssemblyLinearVelocity = desiredVel
					t.AssemblyAngularVelocity = Vector3.zero
					t.Velocity = Vector3.new(50, 50, 50)
					t.RotVelocity = Vector3.zero
					freezeBodyPartsExceptTorso(c, t, true)
				end))

				Fly:Clean(userInputService.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					local speedMultiplier = FlySpeed.Value
					if input.KeyCode == Enum.KeyCode.W then
						CONTROL.F = speedMultiplier
					elseif input.KeyCode == Enum.KeyCode.S then
						CONTROL.B = -speedMultiplier
					elseif input.KeyCode == Enum.KeyCode.A then
						CONTROL.L = -speedMultiplier
					elseif input.KeyCode == Enum.KeyCode.D then
						CONTROL.R = speedMultiplier
					elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E then
						CONTROL.Q = VerticalSpeed.Value
					elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
						CONTROL.E = -VerticalSpeed.Value
					end
				end))

				Fly:Clean(userInputService.InputEnded:Connect(function(input, gpe)
					if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
						CONTROL.F = userInputService:IsKeyDown(Enum.KeyCode.W) and FlySpeed.Value or 0
						CONTROL.B = userInputService:IsKeyDown(Enum.KeyCode.S) and -FlySpeed.Value or 0
					elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
						CONTROL.L = userInputService:IsKeyDown(Enum.KeyCode.A) and -FlySpeed.Value or 0
						CONTROL.R = userInputService:IsKeyDown(Enum.KeyCode.D) and FlySpeed.Value or 0
					elseif input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.Q then
						CONTROL.Q = (userInputService:IsKeyDown(Enum.KeyCode.Space) or userInputService:IsKeyDown(Enum.KeyCode.E)) and VerticalSpeed.Value or 0
						CONTROL.E = (userInputService:IsKeyDown(Enum.KeyCode.LeftControl) or userInputService:IsKeyDown(Enum.KeyCode.Q)) and -VerticalSpeed.Value or 0
					end
				end))

				task.spawn(function()
					while Fly.Enabled do
						if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
							SPEED = 50
						else
							SPEED = 0
						end

						local cam = workspace.CurrentCamera
						if cam and SPEED ~= 0 then
							desiredVel = ((cam.CFrame.LookVector * (CONTROL.F + CONTROL.B))
								+ ((cam.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position)
								- cam.CFrame.Position)) * SPEED
						else
							desiredVel = Vector3.zero
						end

						local c = lplr.Character
						local t = c and (c:FindFirstChild('Torso') or c:FindFirstChild('UpperTorso') or c:FindFirstChild('HumanoidRootPart'))
						if t then
							t.Velocity = Vector3.new(50, 50, 50)
							freezeBodyPartsExceptTorso(c, t, true)
						end

						runService.Heartbeat:Wait()
					end
				end)
			else
				remoteSpamToken = remoteSpamToken + 1
				local char = lplr.Character
				if char then
					local hum = char:FindFirstChildOfClass('Humanoid')
					local t = char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso') or char:FindFirstChild('HumanoidRootPart')
					if t then
						if lastFlyCFrame then
							t.CFrame = lastFlyCFrame
						end
						placeBodyPartsOnTorso(char, t)
						t.AssemblyLinearVelocity = Vector3.zero
						t.AssemblyAngularVelocity = Vector3.zero
						t.Velocity = Vector3.zero
						t.RotVelocity = Vector3.zero
					end
					if hum then
						task.defer(function()
							runService.Heartbeat:Wait()
							if hum.Parent then
								hum.PlatformStand = false
							end
						end)
					end
				end
				frozenBodyCFrames = {}
				bodyOffsets = {}
				lastFlyCFrame = nil
			end
		end,
		Tooltip = 'Criminality Bypass Fly (Freezes body parts and bypasses anti-cheat).'
	})

	FlySpeed = Fly:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 10,
		Default = 1,
		Suffix = function(val)
			return val == 1 and 'x' or 'x'
		end
	})

	VerticalSpeed = Fly:CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 10,
		Default = 2,
		Suffix = function(val)
			return val == 1 and 'x' or 'x'
		end
	})

	RotateWithCamera = Fly:CreateToggle({
		Name = 'Rotate with camera',
		Default = true
	})
end)