-- [ESP Script with respawn support]

_G.FriendColor = Color3.fromRGB(0, 0, 255)
_G.EnemyColor = Color3.fromRGB(255, 0, 0)
_G.UseTeamColor = true

--------------------------------------------------------------------
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

local UnloadCharacter -- forward declaration

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

	-- Highlight ESP
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

	-- Respawn support: CharacterAdded fires every time they spawn
	v.CharacterAdded:Connect(function()
		task.wait(0.1) -- small delay so character loads properly
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

-- Load existing players
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

-- Local player respawn support
local plr = game:GetService("Players").LocalPlayer
plr.CharacterAdded:Connect(function()
	task.wait(0.5)
	-- Refresh ESP on all players after local respawn
	for _, v in pairs(game:GetService("Players"):GetPlayers()) do
		if v ~= plr then
			pcall(UnloadCharacter, v)
			task.wait(0.1)
			pcall(LoadCharacter, v)
		end
	end
end)