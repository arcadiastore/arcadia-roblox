--[[
    Arcadia Online - Combat Client
    
    Handles player input for combat:
    - Click to attack monsters
    - Send attack to server
    - Receive combat feedback
    - Display damage numbers
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Player reference
local player = Players.LocalPlayer
local mouse = player:GetMouse()

print("[CombatClient] Combat Client initializing...")

-- Wait for Events folder
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not eventsFolder then
    warn("[CombatClient] Events folder not found!")
    return
end

-- Get RemoteEvents
local attackEvent = eventsFolder:WaitForChild("AttackMonster", 10)
local combatFeedback = eventsFolder:WaitForChild("CombatFeedback", 10)

if not attackEvent or not combatFeedback then
    warn("[CombatClient] Combat events not found!")
    return
end

print("[CombatClient] Combat events found!")

-- ============================================
-- COMBAT UI
-- ============================================

-- Create combat UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Damage number container
local damageContainer = Instance.new("Frame")
damageContainer.Name = "DamageContainer"
damageContainer.Size = UDim2.new(1, 0, 1, 0)
damageContainer.BackgroundTransparency = 1
damageContainer.Parent = screenGui

-- ============================================
-- COMBAT FUNCTIONS
-- ============================================

-- Show damage number
local function showDamageNumber(targetName, damage, isCrit)
    -- Create damage label
    local label = Instance.new("TextLabel")
    label.Name = "Damage"
    label.Size = UDim2.new(0, 100, 0, 50)
    label.Position = UDim2.new(0.5, -50, 0.4, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(damage)
    label.TextColor3 = isCrit and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = damageContainer
    
    -- Crit indicator
    if isCrit then
        local critLabel = Instance.new("TextLabel")
        critLabel.Name = "Crit"
        critLabel.Size = UDim2.new(0, 80, 0, 30)
        critLabel.Position = UDim2.new(0.5, -40, 0.35, 0)
        critLabel.BackgroundTransparency = 1
        critLabel.Text = "CRITICAL!"
        critLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        critLabel.TextStrokeTransparency = 0
        critLabel.TextScaled = true
        critLabel.Font = Enum.Font.GothamBold
        critLabel.Parent = damageContainer
        
        -- Fade out
        task.spawn(function()
            for i = 1, 10 do
                critLabel.TextTransparency = i / 10
                critLabel.TextStrokeTransparency = i / 10
                task.wait(0.05)
            end
            critLabel:Destroy()
        end)
    end
    
    -- Float animation
    task.spawn(function()
        for i = 1, 20 do
            label.Position = label.Position + UDim2.new(0, 0, -0.01, 0)
            label.TextTransparency = i / 20
            label.TextStrokeTransparency = i / 20
            task.wait(0.05)
        end
        label:Destroy()
    end)
end

-- Show level up notification
local function showLevelUp(level, maxHp, atk, def)
    -- Create level up frame
    local frame = Instance.new("Frame")
    frame.Name = "LevelUp"
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.BackgroundTransparency = 1
    title.Text = "LEVEL UP!"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextStrokeTransparency = 0
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Level
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "Level"
    levelLabel.Size = UDim2.new(1, 0, 0.25, 0)
    levelLabel.Position = UDim2.new(0, 0, 0.3, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level " .. level
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelLabel.TextStrokeTransparency = 0
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.Parent = frame
    
    -- Stats
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "Stats"
    statsLabel.Size = UDim2.new(1, 0, 0.45, 0)
    statsLabel.Position = UDim2.new(0, 0, 0.55, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "HP: " .. maxHp .. " | ATK: " .. atk .. " | DEF: " .. def
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.TextStrokeTransparency = 0
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.Parent = frame
    
    -- Fade out after 3 seconds
    task.spawn(function()
        task.wait(3)
        for i = 1, 20 do
            frame.BackgroundTransparency = i / 20
            title.TextTransparency = i / 20
            levelLabel.TextTransparency = i / 20
            statsLabel.TextTransparency = i / 20
            task.wait(0.05)
        end
        frame:Destroy()
    end)
end

-- Show monster defeated notification
local function showMonsterDefeated(monsterName, expReward, goldReward)
    -- Create notification frame
    local frame = Instance.new("Frame")
    frame.Name = "MonsterDefeated"
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(0.5, -125, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.4, 0)
    title.BackgroundTransparency = 1
    title.Text = monsterName .. " Defeated!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextStrokeTransparency = 0
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    -- Rewards
    local rewards = Instance.new("TextLabel")
    rewards.Name = "Rewards"
    rewards.Size = UDim2.new(1, 0, 0.6, 0)
    rewards.Position = UDim2.new(0, 0, 0.4, 0)
    rewards.BackgroundTransparency = 1
    rewards.Text = "+" .. expReward .. " EXP | +" .. goldReward .. " Gold"
    rewards.TextColor3 = Color3.fromRGB(255, 215, 0)
    rewards.TextStrokeTransparency = 0
    rewards.TextScaled = true
    rewards.Font = Enum.Font.Gotham
    rewards.Parent = frame
    
    -- Fade out after 2 seconds
    task.spawn(function()
        task.wait(2)
        for i = 1, 20 do
            frame.BackgroundTransparency = i / 20
            title.TextTransparency = i / 20
            rewards.TextTransparency = i / 20
            task.wait(0.05)
        end
        frame:Destroy()
    end)
end

-- ============================================
-- INPUT HANDLING
-- ============================================

-- Mouse click to attack
mouse.Button1Down:Connect(function()
    -- Check if clicked on monster
    local target = mouse.Target
    if target then
        -- Check if monster
        local monsterId = target:GetAttribute("MonsterId")
        if monsterId then
            -- Send attack to server
            attackEvent:FireServer(target)
            print("[CombatClient] Attacking: " .. target:GetAttribute("MonsterName"))
        end
    end
end)

-- ============================================
-- COMBAT FEEDBACK HANDLING
-- ============================================

combatFeedback.OnClientEvent:Connect(function(data)
    if data.type == "DamageDealt" then
        -- Show damage number
        showDamageNumber(data.target, data.damage, data.isCrit)
        
    elseif data.type == "MonsterDefeated" then
        -- Show monster defeated notification
        showMonsterDefeated(data.monsterName, data.expReward, data.goldReward)
        
    elseif data.type == "LevelUp" then
        -- Show level up notification
        showLevelUp(data.level, data.maxHp, data.atk, data.def)
    end
end)

print("[CombatClient] Combat Client ready!")
print("[CombatClient] Click on monsters to attack!")
