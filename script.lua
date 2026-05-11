-- Jump Boost + HitBox Drift Script
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local normalSpeed = humanoid.WalkSpeed
local boostPower = 130

-- Настройки дрифта
local driftEnabled = false
local driftVelocity = Vector3.zero
local driftFrames = 0
local maxDriftFrames = 22    -- длина дрифта (больше = длиннее)
local driftFriction = 0.78   -- трение (меньше = скользче)
local driftBoost = 1.6       -- усилитель импульса при посадке

-- Смещение хитбокса для имитации скольжения
local function shiftHitbox(offset)
    local hrp = root
    -- Сдвигаем CFrame персонажа относительно его направления
    hrp.CFrame = hrp.CFrame * CFrame.new(offset, 0, 0)
end

-- Главный drift loop через RunService
local RunService = game:GetService("RunService")

local driftConnection
local function startDriftLoop()
    if driftConnection then driftConnection:Disconnect() end

    driftConnection = RunService.Heartbeat:Connect(function(dt)
        if not driftEnabled or driftFrames <= 0 then
            driftEnabled = false
            driftFrames = 0
            driftVelocity = Vector3.zero
            if driftConnection then
                driftConnection:Disconnect()
                driftConnection = nil
            end
            return
        end

        -- Применяем скорость напрямую к хитбоксу
        root.Velocity = Vector3.new(
            driftVelocity.X,
            root.Velocity.Y,  -- сохраняем гравитацию
            driftVelocity.Z
        )

        -- Боковое смещение хитбокса (создаёт эффект «заноса»)
        local sideSlip = (driftFrames / maxDriftFrames)  -- от 1 до 0
        local slideOffset = sideSlip * 0.45

        -- Смещаем хитбокс вбок от направления движения
        local rightVec = root.CFrame.RightVector
        root.CFrame = CFrame.new(
            root.Position + rightVec * slideOffset * dt * 18,
            root.Position + root.CFrame.LookVector  -- смотрим вперёд
        )

        -- Затухание скорости
        driftVelocity = driftVelocity * driftFriction
        driftFrames = driftFrames - 1
    end)
end

-- Отслеживание состояний
humanoid.StateChanged:Connect(function(oldState, newState)

    -- ПРЫЖОК
    if newState == Enum.HumanoidStateType.Jumping then
        local look = root.CFrame.LookVector
        root.Velocity = Vector3.new(
            look.X * boostPower,
            root.Velocity.Y,
            look.Z * boostPower
        )

    -- ПРИЗЕМЛЕНИЕ — запуск хитбокс-дрифта
    elseif newState == Enum.HumanoidStateType.Landed then
        humanoid.WalkSpeed = normalSpeed

        local landVel = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        local mag = landVel.Magnitude

        if mag > 8 then
            driftEnabled = true
            driftFrames = maxDriftFrames
            -- Усиливаем импульс посадки + добавляем боковую составляющую
            local forwardBoost = landVel.Unit * mag * driftBoost
            local rightBoost = root.CFrame.RightVector * (mag * 0.4)  -- занос вбок
            driftVelocity = Vector3.new(
                forwardBoost.X + rightBoost.X,
                0,
                forwardBoost.Z + rightBoost.Z
            )
            startDriftLoop()
        end
    end
end)