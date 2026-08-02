--[[
    AutoPanel.lua
    Auto Combat toggle + Auto Quest via quest click
]]

local AutoPanel = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local gui, frame = nil, nil
local autoCombatBtn = nil
local autoCombatEnabled = false
local currentTarget = nil  -- Lock target until dead

-- Auto quest state
local autoQuestActive = false
local autoQuestTarget = nil  -- monster type to kill

local ATTACK_RANGE = 30
local ATTACK_INTERVAL = 0.8

-- Get specific monster by type (no range limit for quest)
local function getMonsterByType(monsterType)
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then return nil end
    
    local nearest = nil
    local nearestDist = math.huge  -- No range limit for quest targets
    
    for _, monster in ipairs(monsterFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP") or 0
        local mId = monster:GetAttribute("MonsterId") or ""
        if hp > 0 and mId == monsterType then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = monster
            end
        end
    end
    
    return nearest, nearestDist
end

-- Get nearest monster (any type)
local function getNearestMonster()
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then return nil end
    
    local nearest = nil
    local nearestDist = ATTACK_RANGE
    
    for _, monster in ipairs(monsterFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP") or 0
        if hp > 0 then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = monster
            end
        end
    end
    
    return nearest, nearestDist
end

-- Move toward target
local function moveToward(targetPos)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid:MoveTo(targetPos)
end

-- Stop moving
local function stopMoving()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        humanoid:MoveTo(rootPart.Position)
    end
end

-- Auto combat loop with target lock
local function autoCombatLoop()
    while autoCombatEnabled do
        -- Check if current target is still valid
        if currentTarget then
            local hp = currentTarget:GetAttribute("CurrentHP") or 0
            if hp <= 0 or not currentTarget.Parent then
                currentTarget = nil  -- Target dead, find new one
                stopMoving()
            end
        end
        
        -- Find target if none
        if not currentTarget then
            if autoQuestActive and autoQuestTarget then
                currentTarget = getMonsterByType(autoQuestTarget)
            end
            if not currentTarget then
                currentTarget = getNearestMonster()
            end
        end
        
        -- Attack or move
        if currentTarget then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if rootPart and humanoid then
                    local dist = (currentTarget.Position - rootPart.Position).Magnitude
                    if dist <= 15 then
                        -- In range: attack
                        stopMoving()
                        local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                        if AttackEvent then
                            AttackEvent:FireServer(currentTarget)
                        end
                    else
                        -- Move closer (keep calling MoveTo)
                        humanoid:MoveTo(currentTarget.Position)
                    end
                end
            end
        end
        
        task.wait(0.3)  -- Check more frequently for responsive movement
    end
    
    currentTarget = nil
    stopMoving()
end

-- Start auto quest (called when clicking quest in tracker)
function AutoPanel:StartAutoQuest(monsterType)
    autoQuestActive = true
    autoQuestTarget = monsterType
    
    -- Enable auto combat too
    if not autoCombatEnabled then
        autoCombatEnabled = true
        autoCombatBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        autoCombatBtn.Text = "Auto [ON]"
        autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentTarget = nil
        task.spawn(autoCombatLoop)
    else
        currentTarget = nil  -- Reset target to switch to quest target
    end
    
    print("[AutoPanel] Auto Quest started: kill " .. monsterType)
end

-- Stop auto quest
function AutoPanel:StopAutoQuest()
    autoQuestActive = false
    autoQuestTarget = nil
    print("[AutoPanel] Auto Quest stopped")
end

function AutoPanel:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "AutoPanel"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Panel frame (bottom center)
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(0.5, -75, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    -- Auto Combat toggle button
    autoCombatBtn = Instance.new("TextButton")
    autoCombatBtn.Size = UDim2.new(0.95, 0, 0.8, 0)
    autoCombatBtn.Position = UDim2.new(0.025, 0, 0.1, 0)
    autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoCombatBtn.Text = "Auto [OFF]"
    autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    autoCombatBtn.Font = Enum.Font.GothamBold
    autoCombatBtn.TextScaled = true
    autoCombatBtn.Parent = frame
    Instance.new("UICorner", autoCombatBtn).CornerRadius = UDim.new(0, 6)
    
    -- Toggle Auto Combat
    autoCombatBtn.MouseButton1Click:Connect(function()
        autoCombatEnabled = not autoCombatEnabled
        if autoCombatEnabled then
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            autoCombatBtn.Text = "Auto [ON]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentTarget = nil
            task.spawn(autoCombatLoop)
        else
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            autoCombatBtn.Text = "Auto [OFF]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            autoQuestActive = false
            autoQuestTarget = nil
            currentTarget = nil
            stopMoving()
        end
    end)
    
    print("[AutoPanel] Created!")
end

function AutoPanel:Update(data)
    -- Update quest target based on active quests
    if autoQuestActive and data.activeQuests then
        -- Keep current quest target
    end
end

function AutoPanel:IsAutoCombat()
    return autoCombatEnabled
end

return AutoPanel
