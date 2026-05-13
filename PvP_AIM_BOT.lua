_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

local Holder = Instance.new("Folder", game.CoreGui)
Holder.Name = "ESP"

local Box = Instance.new("BoxHandleAdornment")
Box.Name = "nilBox"
Box.Size = Vector3.new(1, 2, 1)
Box.Color3 = Color3.new(100/255, 100/255, 100/255)
Box.Transparency = 0.7
Box.ZIndex = 0
Box.AlwaysOnTop = false
Box.Visible = false

local NameTag = Instance.new("BillboardGui")
NameTag.Name = "nilNameTag"
NameTag.Enabled = false
NameTag.Size = UDim2.new(0, 200, 0, 50)
NameTag.AlwaysOnTop = true
NameTag.StudsOffset = Vector3.new(0, 1.8, 0)
local Tag = Instance.new("TextLabel", NameTag)
Tag.Name = "Tag"
Tag.BackgroundTransparency = 1
Tag.Position = UDim2.new(0, -50, 0, 0)
Tag.Size = UDim2.new(0, 300, 0, 20)
Tag.TextSize = 15
Tag.TextColor3 = Color3.new(100/255, 100/255, 100/255)
Tag.TextStrokeColor3 = Color3.new(0/255, 0/255, 0/255)
Tag.TextStrokeTransparency = 0.4
Tag.Text = "nil"
Tag.Font = Enum.Font.SourceSansBold
Tag.TextScaled = false

local UnloadCharacter

local LoadCharacter = function(v)
	repeat task.wait() until v.Character ~= nil
	v.Character:WaitForChild("Humanoid")
	local vHolder = Holder:FindFirstChild(v.Name)
	if not vHolder then return end
	vHolder:ClearAllChildren()

	local b = Box:Clone()
	b.Name = v.Name .. "Box"
	b.Adornee = v.Character
	b.Parent = vHolder

	local t = NameTag:Clone()
	t.Name = v.Name .. "NameTag"
	t.Enabled = true
	t.Parent = vHolder
	t.Adornee = v.Character:WaitForChild("Head", 5)
	if not t.Adornee then
		return UnloadCharacter(v)
	end
	t.Tag.Text = v.Name

	b.Color3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
	t.Tag.TextColor3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)

	local Update
	local UpdateNameTag = function()
		if not pcall(function()
			v.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end) then
			if Update then Update:Disconnect() end
		end
	end
	UpdateNameTag()
	Update = v.Character.Humanoid.Changed:Connect(UpdateNameTag)

	if not v.Character:FindFirstChild("GetReal") then
		local highlight = Instance.new("Highlight")
		highlight.RobloxLocked = true
		highlight.Name = "GetReal"
		highlight.Adornee = v.Character
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = _G.UseTeamColor
			and v.TeamColor.Color
			or ((game:GetService("Players").LocalPlayer.TeamColor == v.TeamColor)
				and _G.FriendColor
				or _G.EnemyColor)
		highlight.Parent = v.Character
	end
end

UnloadCharacter = function(v)
	local vHolder = Holder:FindFirstChild(v.Name)
	if vHolder then
		vHolder:ClearAllChildren()
	end
end

local LoadPlayer = function(v)
	if Holder:FindFirstChild(v.Name) then return end
	local vHolder = Instance.new("Folder", Holder)
	vHolder.Name = v.Name

	v.CharacterAdded:Connect(function()
		task.wait(0.1)
		pcall(LoadCharacter, v)
	end)

	v.CharacterRemoving:Connect(function()
		pcall(UnloadCharacter, v)
	end)

	v.Changed:Connect(function(prop)
		if prop == "TeamColor" then
			UnloadCharacter(v)
			task.wait()
			pcall(LoadCharacter, v)
		end
	end)

	pcall(LoadCharacter, v)
end

local UnloadPlayer = function(v)
	pcall(UnloadCharacter, v)
	local vHolder = Holder:FindFirstChild(v.Name)
	if vHolder then vHolder:Destroy() end
end

for _, v in pairs(game:GetService("Players"):GetPlayers()) do
	task.spawn(function() pcall(LoadPlayer, v) end)
end

game:GetService("Players").PlayerAdded:Connect(function(v)
	pcall(LoadPlayer, v)
end)

game:GetService("Players").PlayerRemoving:Connect(function(v)
	pcall(UnloadPlayer, v)
end)

game:GetService("Players").LocalPlayer.NameDisplayDistance = 0

local plr = game:GetService("Players").LocalPlayer
plr.CharacterAdded:Connect(function()
	task.wait(0.5)
	for _, v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= plr then
			pcall(UnloadCharacter, v)
			task.wait(0.1)
			pcall(LoadCharacter, v)
		end
	end
end)

local Settings = {
	ESP = {
		Enabled = true,
		ShowBox = true,
		ShowTracer = true,
		ShowName = true,
		ShowHealth = true,
		ShowDistance = true,
		ShowWeapon = true,
		TeamCheck = true,
		MaxDistance = 300,
		BoxColor = Color3.fromRGB(255, 0, 0),
		TracerColor = Color3.fromRGB(0, 255, 0)
	},
	Aimbot = {
		Enabled = true,
		Silent = false,
		Smoothness = 8,
		FOV = 120,
		HitPart = "Head",
		CheckVisible = true,
		AutoShoot = true,
		Triggerbot = true,
		TriggerKey = "MouseButton2"
	},
	Utility = {
		NoSpread = true,
		NoRecoil = true,
		FastReload = true,
		InfiniteJump = true,
		AntiAFK = true,
		Flying = false,
		Speed = 50,
		TeleportKey = "T",
		EspKey = "E"
	}
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local EspObjects = {}
local function CreateEsp(plr)
	if EspObjects[plr] then return end
	local box = Instance.new("BoxHandleAdornment")
	local tracer = Instance.new("LineHandleAdornment")
	local nameTag = Instance.new("BillboardGui")
	local textLabel = Instance.new("TextLabel")

	box.Adornee = plr.Character
	box.Size = Vector3.new(3, 5, 1)
	box.Color3 = Settings.ESP.BoxColor
	box.Transparency = 0.5
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Parent = plr.Character

	tracer.Adornee = plr.Character
	tracer.Color3 = Settings.ESP.TracerColor
	tracer.Transparency = 0.4
	tracer.AlwaysOnTop = true
	tracer.ZIndex = 9
	tracer.Parent = plr.Character

	nameTag.AlwaysOnTop = true
	nameTag.Size = UDim2.new(0, 200, 0, 50)
	nameTag.StudsOffset = Vector3.new(0, 3, 0)
	nameTag.Parent = plr.Character

	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextScaled = true
	textLabel.Parent = nameTag

	EspObjects[plr] = {box, tracer, nameTag, textLabel}
end

local function UpdateEsp()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then continue end
		local distance = (plr.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
		if distance > Settings.ESP.MaxDistance then
			if EspObjects[plr] then
				for _, obj in ipairs(EspObjects[plr]) do obj:Destroy() end
				EspObjects[plr] = nil
			end
			continue
		end
		if not EspObjects[plr] then CreateEsp(plr) end
		if EspObjects[plr] then
			local txt = ""
			if Settings.ESP.ShowName then txt = plr.Name .. " " end
			if Settings.ESP.ShowHealth then txt = txt .. "♥" .. math.floor(plr.Character.Humanoid.Health) .. " " end
			if Settings.ESP.ShowDistance then txt = txt .. "(" .. math.floor(distance) .. "m)" end
			if Settings.ESP.ShowWeapon then
				local tool = plr.Character:FindFirstChildOfClass("Tool")
				if tool then txt = txt .. " [" .. tool.Name .. "]" end
			end
			EspObjects[plr][4].Text = txt
		end
	end
end

local function GetClosestPlayer()
	local closest = nil
	local closestDistance = Settings.Aimbot.FOV
	local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == LocalPlayer then continue end
		if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
		local hrp = plr.Character.HumanoidRootPart
		local screenPoint, onScreen = Camera:WorldToScreenPoint(hrp.Position)
		if not onScreen then continue end
		local delta = Vector2.new(screenPoint.X - center.X, screenPoint.Y - center.Y)
		local dist = math.sqrt(delta.X^2 + delta.Y^2)
		if dist < closestDistance then
			closest = plr
			closestDistance = dist
		end
	end
	return closest
end

local closestTarget = nil

spawn(function()
	while true do
		if Settings.Aimbot.Enabled then
			closestTarget = GetClosestPlayer()
		end
		wait(1)
	end
end)

local AimbotTarget = nil
RunService.RenderStepped:Connect(function()
	if not Settings.Aimbot.Enabled then return end
	local target = closestTarget
	if target and target.Character and target.Character:FindFirstChild(Settings.Aimbot.HitPart) then
		local hitPart = target.Character[Settings.Aimbot.HitPart]
		if Settings.Aimbot.Silent then
			local oldCast = Raycast
			Raycast = function(origin, direction, ...)
				local newDir = (hitPart.Position - origin).Unit
				return oldCast(origin, newDir * direction.Magnitude, ...)
			end
		else
			AimbotTarget = hitPart
			local cameraCF = Camera.CFrame
			local targetPos = hitPart.Position
			local delta = (targetPos - cameraCF.Position).Unit
			local targetCF = CFrame.new(cameraCF.Position, cameraCF.Position + delta)
			if Settings.Aimbot.Smoothness > 1 then
				TweenService:Create(Camera, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {CFrame = targetCF}):Play()
			else
				Camera.CFrame = targetCF
			end
		end
	end
end)

local mouse = LocalPlayer:GetMouse()
if Settings.Aimbot.AutoShoot or Settings.Aimbot.Triggerbot then
	RunService.RenderStepped:Connect(function()
		local target = closestTarget
		if target and target.Character and target.Character:FindFirstChild(Settings.Aimbot.HitPart) then
			local hitPart = target.Character[Settings.Aimbot.HitPart]
			local ray = Ray.new(Camera.CFrame.Position, (hitPart.Position - Camera.CFrame.Position).Unit * 500)
			local part, pos = workspace:FindPartOnRay(ray, LocalPlayer.Character)
			if Settings.Aimbot.CheckVisible and part and part:IsDescendantOf(target.Character) then
				mouse1click()
			elseif not Settings.Aimbot.CheckVisible then
				mouse1click()
			end
		end
	end)
end

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

if Settings.Utility.NoSpread or Settings.Utility.NoRecoil then
	for _, v in pairs(getconnections(Character:FindFirstChildWhichIsA("Humanoid").Updated)) do
		v:Disable()
	end
	Character:FindFirstChildWhichIsA("Humanoid").CameraOffset = Vector3.new(0, 0, 0)
end

if Settings.Utility.FastReload then
	for _, tool in ipairs(Character:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:FindFirstChild("ReloadTime") then
				tool.ReloadTime.Value = 0
			end
		end
	end
end

local infiniteJumpEnabled = Settings.Utility.InfiniteJump
local humanoid = Character:WaitForChild("Humanoid")
UserInputService.JumpRequest:Connect(function()
	if infiniteJumpEnabled then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		wait(0.1)
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

if Settings.Utility.AntiAFK then
	local vu = game:GetService("VirtualUser")
	LocalPlayer.Idled:connect(function()
		vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		wait(1)
		vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)
end

local flying = false
local bodyVelocity = nil
UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode.X and not gpe then
		flying = not flying
		if flying then
			local humanoidRootPart = Character:WaitForChild("HumanoidRootPart")
			bodyVelocity = Instance.new("BodyVelocity")
			bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
			bodyVelocity.Parent = humanoidRootPart
			while flying do
				local direction = Vector3.new()
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end
				bodyVelocity.Velocity = direction.Unit * Settings.Utility.Speed
				RunService.RenderStepped:Wait()
			end
			bodyVelocity:Destroy()
		end
	end
end)

local function TeleportToPlayer(targetPlayer)
	if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
		LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode[Settings.Utility.TeleportKey] and not gpe then
		local target = closestTarget
		if target then TeleportToPlayer(target) end
	end
end)

local espEnabled = Settings.ESP.Enabled
UserInputService.InputBegan:Connect(function(input, gpe)
	if input.KeyCode == Enum.KeyCode[Settings.Utility.EspKey] and not gpe then
		espEnabled = not espEnabled
		Settings.ESP.Enabled = espEnabled
		if not espEnabled then
			for _, v in pairs(EspObjects) do
				for _, obj in ipairs(v) do obj:Destroy() end
			end
			table.clear(EspObjects)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if Settings.ESP.Enabled then
		UpdateEsp()
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 400)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local function AddButton(text, ypos, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 280, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, ypos)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Parent = Frame
	btn.MouseButton1Click:Connect(callback)
end

AddButton("Toggle ESP (E)", 40, function() espEnabled = not espEnabled end)
AddButton("Toggle Silent Aim", 80, function() Settings.Aimbot.Silent = not Settings.Aimbot.Silent end)
AddButton("Toggle Flying (X)", 120, function() flying = not flying end)
AddButton("Teleport to nearest (T)", 160, function()
	local target = closestTarget
	if target then TeleportToPlayer(target) end
end)
AddButton("Toggle Infinite Jump", 200, function() infiniteJumpEnabled = not infiniteJumpEnabled end)
AddButton("Unload Script", 350, function()
	ScreenGui:Destroy()
	for _, v in pairs(EspObjects) do
		for _, obj in ipairs(v) do obj:Destroy() end
	end
end)