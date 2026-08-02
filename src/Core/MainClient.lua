--[[
    Arcadia Online - Main Client Script
    
    Handles client-side initialization and input.
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Wait for events folder
local EventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not EventsFolder then
    warn("[Client] Events folder not found!")
    return
end

-- Get RemoteEvents
local function getEvent(name)
    return EventsFolder:WaitForChild(name, 5)
end

local CombatEvent = getEvent("CombatEvent")
local QuestEvent = getEvent("QuestEvent")
local ShopEvent = getEvent("ShopEvent")
local NPCEvent = getEvent("NPCEvent")
local NotificationEvent = getEvent("NotificationEvent")

-- Create Simple HUD
local function createHUD()
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Remove existing HUD
    local existingHUD = playerGui:FindFirstChild("GameHUD")
    if existingHUD then
        existingHUD:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Health Bar Background
    local hpBg = Instance.new("Frame")
    hpBg.Name = "HealthBarBG"
    hpBg.Size = UDim2.new(0.2, 0, 0.025, 0)
    hpBg.Position = UDim2.new(0.01, 0, 0.02, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBg.BackgroundTransparency = 0.3
    hpBg.BorderSizePixel = 0
    hpBg.Parent = screenGui
    
    local hpCorner = Instance.new("UICorner")
    hpCorner.CornerRadius = UDim.new(0, 6)
    hpCorner.Parent = hpBg
    
    -- Health Bar Fill
    local hpFill = Instance.new("Frame")
    hpFill.Name = "HealthFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    
    local hpFillCorner = Instance.new("UICorner")
    hpFillCorner.CornerRadius = UDim.new(0, 6)
    hpFillCorner.Parent = hpFill
    
    -- Health Text
    local hpText = Instance.new("TextLabel")
    hpText.Name = "HealthText"
    hpText.Size = UDim2.new(1, 0, 1, 0)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpText.TextScaled = true
    hpText.Font = Enum.Font.GothamBold
    hpText.Text = "HP: 100/100"
    hpText.ZIndex = 2
    hpText.Parent = hpBg
    
    -- Level Text
    local levelText = Instance.new("TextLabel")
    levelText.Name = "LevelText"
    levelText.Size = UDim2.new(0.08, 0, 0.025, 0)
    levelText.Position = UDim2.new(0.22, 0, 0.02, 0)
    levelText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    levelText.BackgroundTransparency = 0.3
    levelText.TextColor3 = Color3.fromRGB(255, 215, 0)
    levelText.TextScaled = true
    levelText.Font = Enum.Font.GothamBold
    levelText.Text = "Lv.1"
    levelText.Parent = screenGui
    
    local levelCorner = Instance.new("UICorner")
    levelCorner.CornerRadius = UDim.new(0, 6)
    levelCorner.Parent = levelText
    
    -- Gold Text
    local goldText = Instance.new("TextLabel")
    goldText.Name = "GoldText"
    goldText.Size = UDim2.new(0.1, 0, 0.025, 0)
    goldText.Position = UDim2.new(0.89, 0, 0.02, 0)
    goldText.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    goldText.BackgroundTransparency = 0.3
    goldText.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldText.TextScaled = true
    goldText.Font = Enum.Font.GothamBold
    goldText.Text = "💰 100"
    goldText.Parent = screenGui
    
    local goldCorner = Instance.new("UICorner")
    goldCorner.CornerRadius = UDim.new(0, 6)
    goldCorner.Parent = goldText
    
    -- Store references
    screenGui:SetAttribute("HPFill", hpFill)
    screenGui:SetAttribute("HPText", hpText)
    
    return screenGui
end

-- Update HUD
local function updateHUD()
    local playerGui = player:WaitForChild("PlayerGui")
    local hud = playerGui:FindFirstChild("GameHUD")
    
    if hud and character and humanoid then
        local hpFill = hud:FindFirstChild("HealthBarBG") and hud.HealthBarBG:FindFirstChild("HealthFill")
        local hpText = hud:FindFirstChild("HealthBarBG") and hud.HealthBarBG:FindFirstChild("HealthText")
        
        if hpFill and hpText then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            hpFill.Size = UDim2.new(healthPercent, 0, 1, 0)
            hpText.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            
            -- Color based on health
            if healthPercent > 0.5 then
                hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            elseif healthPercent > 0.25 then
                hpFill.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
            else
                hpFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            end
        end
    end
end

-- Create HUD
createHUD()

-- Update loop
RunService.Heartbeat:Connect(function()
    updateHUD()
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    createHUD()
end)

-- Handle keyboard input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F key - Interact with NPC
    if input.KeyCode == Enum.KeyCode.F then
        if NPCEvent then
            -- Find nearest NPC (simplified)
            NPCEvent:FireServer("talk", { npcId = "NearbyNPC" })
        end
    end
    
    -- I key - Inventory
    if input.KeyCode == Enum.KeyCode.I then
        print("[Input] Open Inventory")
    end
    
    -- J key - Quest Log
    if input.KeyCode == Enum.KeyCode.J then
        print("[Input] Open Quest Log")
    end
    
    -- M key - Map
    if input.KeyCode == Enum.KeyCode.M then
        print("[Input] Open Map")
    end
    
    -- 1-4 keys - Skills
    if input.KeyCode == Enum.KeyCode.One then
        if CombatEvent then
            CombatEvent:FireServer("skill", { skillId = "skill_1" })
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Two then
        if CombatEvent then
            CombatEvent:FireServer("skill", { skillId = "skill_2" })
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Three then
        if CombatEvent then
            CombatEvent:FireServer("skill", { skillId = "skill_3" })
        end
    end
    
    if input.KeyCode == Enum.KeyCode.Four then
        if CombatEvent then
            CombatEvent:FireServer("skill", { skillId = "skill_4" })
        end
    end
end)

-- Handle notifications from server
if NotificationEvent then
    NotificationEvent.OnClientEvent:Connect(function(message)
        -- Show notification on screen
        local playerGui = player:WaitForChild("PlayerGui")
        local hud = playerGui:FindFirstChild("GameHUD")
        
        if hud then
            local notification = Instance.new("TextLabel")
            notification.Size = UDim2.new(0.3, 0, 0.04, 0)
            notification.Position = UDim2.new(0.35, 0, 0.3, 0)
            notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            notification.BackgroundTransparency = 0.2
            notification.TextColor3 = Color3.fromRGB(255, 255, 255)
            notification.TextScaled = true
            notification.Font = Enum.Font.GothamBold
            notification.Text = message
            notification.ZIndex = 10
            notification.Parent = hud
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = notification
            
            -- Auto remove after 3 seconds
            task.delay(3, function()
                notification:Destroy()
            end)
        end
    end)
end

print("[Client] Arcadia Online client initialized!")
