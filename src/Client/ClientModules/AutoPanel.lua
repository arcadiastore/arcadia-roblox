--[[
    AutoPanel.lua
    Auto Combat and Auto Quest toggles
]]

local AutoPanel = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local gui, frame = nil, nil
local autoCombatBtn, autoQuestBtn = nil, nil
local autoCombatEnabled = false
local autoQuestEnabled = false

-- Auto combat state
local ATTACK_RANGE = 30
local ATTACK_INTERVAL = 0.8  -- seconds between attacks

-- Get nearest monster
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

-- Move character toward target
local function moveToward(targetPos)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    humanoid:MoveTo(targetPos)
end

-- Auto combat loop
local function autoCombatLoop()
    while autoCombatEnabled do
        local monster, dist = getNearestMonster()
        if monster then
            if dist <= 15 then
                -- In attack range: attack
                local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                if AttackEvent then
                    AttackEvent:FireServer(monster)
                end
            else
                -- Move closer
                moveToward(monster.Position)
            end
        end
        task.wait(ATTACK_INTERVAL)
    end
end

-- Auto quest loop
local function autoQuestLoop()
    while autoQuestEnabled do
        local character = player.Character
        if not character then break end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then break end
        
        -- Find quest target (nearest monster for kill quests)
        local monsterFolder = workspace:FindFirstChild("Monsters")
        if monsterFolder then
            local nearest, dist = getNearestMonster()
            if nearest and dist <= ATTACK_RANGE then
                moveToward(nearest.Position)
            end
        end
        
        task.wait(1)
    end
end

function AutoPanel:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "AutoPanel"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Panel frame (bottom center)
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(0.5, -100, 1, -60)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    -- Auto Combat button
    autoCombatBtn = Instance.new("TextButton")
    autoCombatBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
    autoCombatBtn.Position = UDim2.new(0.02, 0, 0.1, 0)
    autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoCombatBtn.Text = "Auto Combat [OFF]"
    autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    autoCombatBtn.Font = Enum.Font.GothamBold
    autoCombatBtn.TextScaled = true
    autoCombatBtn.Parent = frame
    Instance.new("UICorner", autoCombatBtn).CornerRadius = UDim.new(0, 6)
    
    -- Auto Quest button
    autoQuestBtn = Instance.new("TextButton")
    autoQuestBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
    autoQuestBtn.Position = UDim2.new(0.5, 0, 0.1, 0)
    autoQuestBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoQuestBtn.Text = "Auto Quest [OFF]"
    autoQuestBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    autoQuestBtn.Font = Enum.Font.GothamBold
    autoQuestBtn.TextScaled = true
    autoQuestBtn.Parent = frame
    Instance.new("UICorner", autoQuestBtn).CornerRadius = UDim.new(0, 6)
    
    -- Toggle Auto Combat
    autoCombatBtn.MouseButton1Click:Connect(function()
        autoCombatEnabled = not autoCombatEnabled
        if autoCombatEnabled then
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            autoCombatBtn.Text = "Auto Combat [ON]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.spawn(autoCombatLoop)
        else
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            autoCombatBtn.Text = "Auto Combat [OFF]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    -- Toggle Auto Quest
    autoQuestBtn.MouseButton1Click:Connect(function()
        autoQuestEnabled = not autoQuestEnabled
        if autoQuestEnabled then
            -- Auto quest implies auto combat
            autoCombatEnabled = true
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            autoCombatBtn.Text = "Auto Combat [ON]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.spawn(autoCombatLoop)
            
            autoQuestBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            autoQuestBtn.Text = "Auto Quest [ON]"
            autoQuestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            task.spawn(autoQuestLoop)
        else
            autoQuestBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            autoQuestBtn.Text = "Auto Quest [OFF]"
            autoQuestBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
    
    print("[AutoPanel] Created!")
end

function AutoPanel:Update(data)
    -- Could update button states based on quest data
end

return AutoPanel
