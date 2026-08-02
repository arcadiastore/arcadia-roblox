--[[
    HUD.lua
    Creates and manages the player HUD (stats display)
]]

local HUD = {}

-- UI Elements
local gui, statsFrame, levelLabel, hpLabel, expLabel, goldLabel

-- Create HUD
function HUD:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "GameHUD"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Stats Frame (kiri atas)
    statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(0, 200, 0, 100)
    statsFrame.Position = UDim2.new(0, 10, 0, 10)
    statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statsFrame.BackgroundTransparency = 0.3
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = gui
    
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 8)
    
    levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, -10, 0, 20)
    levelLabel.Position = UDim2.new(0, 5, 0, 5)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level: 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    levelLabel.TextStrokeTransparency = 0
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextScaled = true
    levelLabel.Parent = statsFrame
    
    hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, -10, 0, 20)
    hpLabel.Position = UDim2.new(0, 5, 0, 30)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: 100/100"
    hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    hpLabel.TextStrokeTransparency = 0
    hpLabel.TextXAlignment = Enum.TextXAlignment.Left
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextScaled = true
    hpLabel.Parent = statsFrame
    
    expLabel = Instance.new("TextLabel")
    expLabel.Size = UDim2.new(1, -10, 0, 20)
    expLabel.Position = UDim2.new(0, 5, 0, 55)
    expLabel.BackgroundTransparency = 1
    expLabel.Text = "EXP: 0"
    expLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    expLabel.TextStrokeTransparency = 0
    expLabel.TextXAlignment = Enum.TextXAlignment.Left
    expLabel.Font = Enum.Font.GothamBold
    expLabel.TextScaled = true
    expLabel.Parent = statsFrame
    
    goldLabel = Instance.new("TextLabel")
    goldLabel.Size = UDim2.new(1, -10, 0, 20)
    goldLabel.Position = UDim2.new(0, 5, 0, 75)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Text = "Gold: 100"
    goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldLabel.TextStrokeTransparency = 0
    goldLabel.TextXAlignment = Enum.TextXAlignment.Left
    goldLabel.Font = Enum.Font.GothamBold
    goldLabel.TextScaled = true
    goldLabel.Parent = statsFrame
    
    print("[HUD] Created!")
end

-- Update HUD
function HUD:Update(data)
    if not levelLabel then return end
    
    levelLabel.Text = "Level: " .. data.level
    hpLabel.Text = "HP: " .. data.hp .. "/" .. data.maxHp
    expLabel.Text = "EXP: " .. data.exp
    goldLabel.Text = "Gold: " .. data.gold
end

-- Get GUI (for child elements)
function HUD:GetGUI()
    return gui
end

return HUD
