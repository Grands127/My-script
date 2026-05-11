local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RespawnFlingGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
mainFrame.BackgroundColor3 = Color3.new(0,0,0)
mainFrame.BackgroundTransparency = 0.8
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local btnFlingAll = Instance.new("TextButton")
btnFlingAll.Size = UDim2.new(0, 160, 0, 40)
btnFlingAll.Position = UDim2.new(0.5, -80, 0.5, -20)
btnFlingAll.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
btnFlingAll.BackgroundTransparency = 0.15
btnFlingAll.BorderSizePixel = 0
btnFlingAll.Text = "FLING ALL"
btnFlingAll.TextColor3 = Color3.fromRGB(255, 255, 200)
btnFlingAll.TextScaled = true
btnFlingAll.Font = Enum.Font.GothamBold
btnFlingAll.Parent = mainFrame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = btnFlingAll

local tgLabel = Instance.new("TextLabel")
tgLabel.Size = UDim2.new(1, -10, 0, 20)
tgLabel.Position = UDim2.new(0.5, -95, 1, -22)
tgLabel.BackgroundTransparency = 1
tgLabel.Text = "@httpssCookie | t.me/surweee"
tgLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
tgLabel.TextSize = 10
tgLabel.Font = Enum.Font.GothamBold
tgLabel.TextWrapped = true
tgLabel.Parent = mainFrame

local textButton = Instance.new("TextButton")
textButton.Size = tgLabel.Size
textButton.Position = tgLabel.Position
textButton.BackgroundTransparency = 1
textButton.Text = ""
textButton.Parent = mainFrame
textButton.MouseButton1Click:Connect(function()
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://t.me/surweee")
    end)
end)

local dragging = false
local dragStartPos, dragStartMousePos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = mainFrame.Position
        dragStartMousePos = input.Position
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartMousePos
        mainFrame.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + delta.Y)
    end
end)

local function notify(text, color)
    pcall(function()
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = text,
            Color = color or Color3.fromRGB(255,255,255)
        })
    end)
end

local function SkidFling(targetPlayer)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = humanoid and humanoid.RootPart
    local tChar = targetPlayer.Character
    if not tChar then return false end

    local tHumanoid = tChar:FindFirstChildOfClass("Humanoid")
    local tRootPart = tHumanoid and tHumanoid.RootPart
    local tHead = tChar:FindFirstChild("Head")
    local accessory = tChar:FindFirstChildOfClass("Accessory")
    local handle = accessory and accessory:FindFirstChild("Handle")

    if not (character and humanoid and rootPart) then return false end

    if rootPart.Velocity.Magnitude < 50 then
        getgenv().OldPos = rootPart.CFrame
    end

    if tHumanoid and tHumanoid.Sit then return false end

    if tHead then workspace.CurrentCamera.CameraSubject = tHead
    elseif handle then workspace.CurrentCamera.CameraSubject = handle
    elseif tHumanoid and tRootPart then workspace.CurrentCamera.CameraSubject = tHumanoid
    end

    if not tChar:FindFirstChildWhichIsA("BasePart") then return false end

    local function FPos(basePart, pos, ang)
        rootPart.CFrame = CFrame.new(basePart.Position) * pos * ang
        character:SetPrimaryPartCFrame(CFrame.new(basePart.Position) * pos * ang)
        rootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
        rootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
    end

    local function SFBasePart(basePart)
        local timeout = 1.5
        local startTime = tick()
        local angle = 0
        repeat
            if rootPart and tHumanoid then
                if basePart.Velocity.Magnitude < 50 then
                    angle = angle + 100
                    FPos(basePart, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection * basePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, 1.5, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0) + tHumanoid.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                    task.wait()
                else
                    FPos(basePart, CFrame.new(0, 1.5, tHumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, -tHumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, 1.5, tHumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                    task.wait()
                    FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                    task.wait()
                end
            end
        until startTime + timeout < tick()
    end

    workspace.FallenPartsDestroyHeight = 0/0

    local bv = Instance.new("BodyVelocity")
    bv.Parent = rootPart
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    if tRootPart then SFBasePart(tRootPart)
    elseif tHead then SFBasePart(tHead)
    elseif handle then SFBasePart(handle)
    else
        bv:Destroy()
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = humanoid
        return false
    end

    bv:Destroy()
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = humanoid

    if getgenv().OldPos then
        local tries = 0
        while (rootPart.Position - getgenv().OldPos.p).Magnitude > 25 and tries < 10 do
            rootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
            character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Velocity = Vector3.new()
                    part.RotVelocity = Vector3.new()
                end
            end
            task.wait()
            tries = tries + 1
        end
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    end
    return true
end

local isFlingingAll = false
btnFlingAll.MouseButton1Click:Connect(function()
    if isFlingingAll then return end
    isFlingingAll = true
    btnFlingAll.Visible = false

    local playersList = Players:GetPlayers()
    local index = 0

    local function waitForRespawn()
        while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0 do
            task.wait(0.5)
        end
        task.wait(0.5)
    end

    local function processNext()
        index = index + 1
        if index > #playersList then
            isFlingingAll = false
            btnFlingAll.Visible = true
            notify("✅ Цикл флинга завершён", Color3.fromRGB(100,255,100))
            return
        end
        local target = playersList[index]
        if target == LocalPlayer then
            processNext()
            return
        end

        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0 then
            notify("⏳ Вы умерли, ожидание респавна...", Color3.fromRGB(255,200,100))
            waitForRespawn()
            notify("✅ Возродились, продолжаем флинг", Color3.fromRGB(100,255,100))
        end

        local targetChar = target.Character
        local myChar = LocalPlayer.Character
        if myChar and targetChar and targetChar:FindFirstChild("HumanoidRootPart") and myChar:FindFirstChild("HumanoidRootPart") then
            myChar:SetPrimaryPartCFrame(targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 1.5, 0))
            task.wait(0.1)
            SkidFling(target)
        end
        task.wait(0.8)
        processNext()
    end
    processNext()
end)

notify("⚡ Fling GUI v8 загружен. При смерти ждём респавна и продолжаем.", Color3.fromRGB(100,255,100))
