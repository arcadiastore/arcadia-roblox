--[[
    HUD.lua
    Creates and manages the player HUD (stats display)
]]

local HUD = {}

-- UI Elements
local gui, statsFrame, jobLabel, levelLabel, hpLabel, mpLabel, expLabel, goldLabel, atkLabel

-- Create HUD
function HUD:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "GameHUD"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Stats Frame (kiri atas) - taller for more stats
    statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(0, 200, 0, 140)
    statsFrame.Position = UDim2.new(0, 10, 0, 10)
    statsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    statsFrame.BackgroundTransparency = 0.3
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = gui
    
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 8)
    
    jobLabel = Instance.new("TextLabel")
    jobLabel.Size = UDim2.new(1, -10, 0, 18)
    jobLabel.Position = UDim2.new(0, 5, 0, 3)
    jobLabel.BackgroundTransparency = 1
    jobLabel.Text = "[No Job]"
    jobLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    jobLabel.TextStrokeTransparency = 0
    jobLabel.TextXAlignment = Enum.TextXAlignment.Left
    jobLabel.Font = Enum.Font.GothamBold
    jobLabel.TextScaled = true
    jobLabel.Parent = statsFrame
    
    levelLabel = Instance.new("TextLabel")
    levelLabel.Size = UDim2.new(1, -10, 0, 18)
    levelLabel.Position = UDim2.new(0, 5, 0, 22)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Level: 1"
    levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    levelLabel.TextStrokeTransparency = 0
    levelLabel.TextXAlignment = Enum.TextXAlignment.Left
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.TextScaled = true
    levelLabel.Parent = statsFrame
    
    hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, -10, 0, 18)
    hpLabel.Position = UDim2.new(0, 5, 0, 42)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Text = "HP: 100/100"
    hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    hpLabel.TextStrokeTransparency = 0
    hpLabel.TextXAlignment = Enum.TextXAlignment.Left
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextScaled = true
    hpLabel.Parent = statsFrame
    
    mpLabel = Instance.new("TextLabel")
    mpLabel.Size = UDim2.new(1, -10, 0, 18)
    mpLabel.Position = UDim2.new(0, 5, 0, 60)
    mpLabel.BackgroundTransparency = 1
    mpLabel.Text = "MP: 50/50"
    mpLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    mpLabel.TextStrokeTransparency = 0
    mpLabel.TextXAlignment = Enum.TextXAlignment.Left
    mpLabel.Font = Enum.Font.GothamBold
    mpLabel.TextScaled = true
    mpLabel.Parent = statsFrame
    
    expLabel = Instance.new("TextLabel")
    expLabel.Size = UDim2.new(1, -10, 0, 18)
    expLabel.Position = UDim2.new(0, 5, 0, 80)
    expLabel.BackgroundTransparency = 1
    expLabel.Text = "EXP: 0 / 100"
    expLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    expLabel.TextStrokeTransparency = 0
    expLabel.TextXAlignment = Enum.TextXAlignment.Left
    expLabel.Font = Enum.Font.GothamBold
    expLabel.TextScaled = true
    expLabel.Parent = statsFrame
    
    goldLabel = Instance.new("TextLabel")
    goldLabel.Size = UDim2.new(1, -10, 0, 18)
    goldLabel.Position = UDim2.new(0, 5, 0, 100)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Text = "Gold: 100"
    goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldLabel.TextStrokeTransparency = 0
    goldLabel.TextXAlignment = Enum.TextXAlignment.Left
    goldLabel.Font = Enum.Font.GothamBold
    goldLabel.TextScaled = true
    goldLabel.Parent = statsFrame
    
    atkLabel = Instance.new("TextLabel")
    atkLabel.Size = UDim2.new(1, -10, 0, 18)
    atkLabel.Position = UDim2.new(0, 5, 0, 120)
    atkLabel.BackgroundTransparency = 1
    atkLabel.Text = "ATK: 10 | DEF: 5"
    atkLabel.TextColor3 = Color3.fromRGB(255, 180, 100)
    atkLabel.TextStrokeTransparency = 0
    atkLabel.TextXAlignment = Enum.TextXAlignment.Left
    atkLabel.Font = Enum.Font.GothamBold
    atkLabel.TextScaled = true
    atkLabel.Parent = statsFrame
    
    print("[HUD] Created!")
end

-- Update HUD
function HUD:Update(data)
    if not levelLabel then return end
    
    -- Job display
    if data.job then
        local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))
        local jobData = GameData.Jobs and GameData.Jobs[data.job]
        if jobData then
            jobLabel.Text = jobData.icon .. " " .. data.job
            jobLabel.TextColor3 = jobData.color or Color3.fromRGB(200, 200, 200)
        else
            jobLabel.Text = data.job
        end
    else
        jobLabel.Text = "[No Job - Visit Job Master]"
        jobLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
    
    levelLabel.Text = "Lv." .. data.level
    hpLabel.Text = "HP: " .. data.hp .. "/" .. data.maxHp
    mpLabel.Text = "MP: " .. (data.mp or 50) .. "/" .. (data.maxMp or 50)
    
    -- Calculate EXP needed for next level
    local expNeeded = math.floor(100 * (1.5 ^ (data.level - 1)))
    expLabel.Text = "EXP: " .. data.exp .. " / " .. expNeeded
    
    goldLabel.Text = "Gold: " .. data.gold
    atkLabel.Text = "ATK:" .. data.atk .. " DEF:" .. data.def .. " SPD:" .. (data.spd or 10)
end

-- Get GUI (for child elements)
function HUD:GetGUI()
    return gui
end

return HUD
