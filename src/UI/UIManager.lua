--[[
    Arcadia Online - UI Manager
    
    Handles client-side UI:
    - HUD (Health, Mana, EXP bars)
    - Inventory UI
    - Quest UI
    - Shop UI
    - Dialogue UI
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIManager = {}
UIManager.__index = UIManager

function UIManager.new()
    local self = setmetatable({}, UIManager)
    
    self.player = Players.LocalPlayer
    self.playerGui = self.player:WaitForChild("PlayerGui")
    
    self.elements = {}
    
    return self
end

-- Create HUD
function UIManager:CreateHUD()
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameHUD"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = self.playerGui
    
    -- Health Bar
    self:CreateBar(screenGui, "HealthBar", 
        UDim2.new(0.02, 0, 0.02, 0),  -- Position
        UDim2.new(0.25, 0, 0.03, 0),  -- Size
        Color3.fromRGB(220, 50, 50),  -- Color (Red)
        "HP: 100/100"
    )
    
    -- Mana Bar
    self:CreateBar(screenGui, "ManaBar",
        UDim2.new(0.02, 0, 0.06, 0),
        UDim2.new(0.25, 0, 0.03, 0),
        Color3.fromRGB(50, 100, 220),  -- Color (Blue)
        "MP: 50/50"
    )
    
    -- EXP Bar
    self:CreateBar(screenGui, "EXPBar",
        UDim2.new(0.02, 0, 0.10, 0),
        UDim2.new(0.25, 0, 0.02, 0),
        Color3.fromRGB(50, 200, 50),  -- Color (Green)
        "EXP: 0/100"
    )
    
    -- Level Text
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "LevelLabel"
    levelLabel.Size = UDim2.new(0.1, 0, 0.04, 0)
    levelLabel.Position = UDim2.new(0.28, 0, 0.02, 0)
    levelLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    levelLabel.BackgroundTransparency = 0.3
    levelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    levelLabel.TextScaled = true
    levelLabel.Font = Enum.Font.GothamBold
    levelLabel.Text = "Lv.1"
    levelLabel.Parent = screenGui
    
    self.elements.levelLabel = levelLabel
    
    -- Gold Text
    local goldLabel = Instance.new("TextLabel")
    goldLabel.Name = "GoldLabel"
    goldLabel.Size = UDim2.new(0.12, 0, 0.03, 0)
    goldLabel.Position = UDim2.new(0.86, 0, 0.02, 0)
    goldLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    goldLabel.BackgroundTransparency = 0.3
    goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldLabel.TextScaled = true
    goldLabel.Font = Enum.Font.GothamBold
    goldLabel.Text = "💰 100"
    goldLabel.Parent = screenGui
    
    self.elements.goldLabel = goldLabel
    
    print("[UI] HUD created")
end

-- Create a bar element
function UIManager:CreateBar(parent, name, position, size, color, text)
    -- Background
    local background = Instance.new("Frame")
    background.Name = name .. "BG"
    background.Size = size
    background.Position = position
    background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    background.BackgroundTransparency = 0.3
    background.BorderSizePixel = 0
    background.Parent = parent
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = background
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Name = name .. "Fill"
    fill.Size = UDim2.new(1, 0, 1, 0)
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Parent = background
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = fill
    
    -- Text
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.ZIndex = 2
    label.Parent = background
    
    -- Store references
    self.elements[name] = {
        background = background,
        fill = fill,
        label = label,
    }
    
    return background
end

-- Update health bar
function UIManager:UpdateHealth(current, max)
    local bar = self.elements.HealthBar
    if bar then
        local percent = current / max
        bar.fill.Size = UDim2.new(percent, 0, 1, 0)
        bar.label.Text = "HP: " .. math.floor(current) .. "/" .. math.floor(max)
        
        -- Change color based on health
        if percent > 0.5 then
            bar.fill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        elseif percent > 0.25 then
            bar.fill.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
        else
            bar.fill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        end
    end
end

-- Update mana bar
function UIManager:UpdateMana(current, max)
    local bar = self.elements.ManaBar
    if bar then
        local percent = current / max
        bar.fill.Size = UDim2.new(percent, 0, 1, 0)
        bar.label.Text = "MP: " .. math.floor(current) .. "/" .. math.floor(max)
    end
end

-- Update EXP bar
function UIManager:UpdateEXP(current, max)
    local bar = self.elements.EXPBar
    if bar then
        local percent = current / max
        bar.fill.Size = UDim2.new(percent, 0, 1, 0)
        bar.label.Text = "EXP: " .. math.floor(current) .. "/" .. math.floor(max)
    end
end

-- Update level
function UIManager:UpdateLevel(level)
    if self.elements.levelLabel then
        self.elements.levelLabel.Text = "Lv." .. level
    end
end

-- Update gold
function UIManager:UpdateGold(gold)
    if self.elements.goldLabel then
        self.elements.goldLabel.Text = "💰 " .. gold
    end
end

-- Show notification
function UIManager:ShowNotification(message, duration)
    duration = duration or 3
    
    local screenGui = self.playerGui:FindFirstChild("GameHUD")
    if not screenGui then return end
    
    -- Create notification
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0.3, 0, 0.05, 0)
    notification.Position = UDim2.new(0.35, 0, 0.3, 0)
    notification.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    notification.BackgroundTransparency = 0.2
    notification.TextColor3 = Color3.fromRGB(255, 255, 255)
    notification.TextScaled = true
    notification.Font = Enum.Font.GothamBold
    notification.Text = message
    notification.ZIndex = 10
    notification.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification
    
    -- Fade in
    notification.TextTransparency = 1
    notification.BackgroundTransparency = 1
    
    local fadeIn = TweenService:Create(notification, TweenInfo.new(0.3), {
        TextTransparency = 0,
        BackgroundTransparency = 0.2,
    })
    fadeIn:Play()
    
    -- Fade out after duration
    task.delay(duration, function()
        local fadeOut = TweenService:Create(notification, TweenInfo.new(0.5), {
            TextTransparency = 1,
            BackgroundTransparency = 1,
        })
        fadeOut:Play()
        fadeOut.Completed:Wait()
        notification:Destroy()
    end)
end

-- Show damage number
function UIManager:ShowDamageNumber(position, damage, isCritical)
    local screenGui = self.playerGui:FindFirstChild("GameHUD")
    if not screenGui then return end
    
    -- Convert 3D position to 2D
    local camera = workspace.CurrentCamera
    local screenPos = camera:WorldToScreenPoint(position)
    
    -- Create damage label
    local damageLabel = Instance.new("TextLabel")
    damageLabel.Size = UDim2.new(0.08, 0, 0.04, 0)
    damageLabel.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
    damageLabel.BackgroundTransparency = 1
    damageLabel.TextColor3 = isCritical and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
    damageLabel.TextStrokeTransparency = 0
    damageLabel.TextScaled = true
    damageLabel.Font = Enum.Font.GothamBold
    damageLabel.Text = isCritical and ("💥 " .. damage) or tostring(damage)
    damageLabel.ZIndex = 10
    damageLabel.Parent = screenGui
    
    -- Animate floating up
    local tween = TweenService:Create(damageLabel, TweenInfo.new(1, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0, screenPos.X, 0, screenPos.Y - 50),
        TextTransparency = 1,
        TextStrokeTransparency = 1,
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        damageLabel:Destroy()
    end)
end

-- Show dialogue box
function UIManager:ShowDialogue(npcName, text, options)
    local screenGui = self.playerGui:FindFirstChild("GameHUD")
    if not screenGui then return end
    
    -- Remove existing dialogue
    local existing = screenGui:FindFirstChild("DialogueBox")
    if existing then existing:Destroy() end
    
    -- Create dialogue box
    local dialogueBox = Instance.new("Frame")
    dialogueBox.Name = "DialogueBox"
    dialogueBox.Size = UDim2.new(0.5, 0, 0.25, 0)
    dialogueBox.Position = UDim2.new(0.25, 0, 0.7, 0)
    dialogueBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    dialogueBox.BackgroundTransparency = 0.1
    dialogueBox.BorderSizePixel = 0
    dialogueBox.ZIndex = 10
    dialogueBox.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = dialogueBox
    
    -- NPC Name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = npcName
    nameLabel.ZIndex = 11
    nameLabel.Parent = dialogueBox
    
    -- Dialogue text
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    textLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextWrapped = true
    textLabel.Text = text
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.ZIndex = 11
    textLabel.Parent = dialogueBox
    
    -- Options
    if options then
        for i, option in ipairs(options) do
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0.4, 0, 0.15, 0)
            button.Position = UDim2.new(0.05 + (i-1) * 0.45, 0, 0.7, 0)
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextScaled = true
            button.Font = Enum.Font.GothamBold
            button.Text = option.text
            button.ZIndex = 11
            button.Parent = dialogueBox
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = button
            
            button.MouseButton1Click:Connect(function()
                if option.callback then
                    option.callback()
                end
                dialogueBox:Destroy()
            end)
        end
    else
        -- Close button
        local closeButton = Instance.new("TextButton")
        closeButton.Size = UDim2.new(0.2, 0, 0.15, 0)
        closeButton.Position = UDim2.new(0.75, 0, 0.8, 0)
        closeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        closeButton.TextScaled = true
        closeButton.Font = Enum.Font.GothamBold
        closeButton.Text = "Close"
        closeButton.ZIndex = 11
        closeButton.Parent = dialogueBox
        
        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeButton
        
        closeButton.MouseButton1Click:Connect(function()
            dialogueBox:Destroy()
        end)
    end
    
    return dialogueBox
end

return UIManager.new()
