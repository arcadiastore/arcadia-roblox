--[[
    EquipmentUI.lua
    Equipment panel - equip/unequip items
]]

local EquipmentUI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui, frame, isOpen = nil, nil, false
local equipSlots = {}
local playerData = nil

-- Equipment slot layout
local slotLayout = {
    {slot = "hat", label = "Hat", row = 1, col = 2},
    {slot = "wings", label = "Wings", row = 1, col = 4},
    {slot = "tshirt", label = "Baju", row = 2, col = 2},
    {slot = "costume", label = "Costume", row = 2, col = 4},
    {slot = "weapon1h", label = "Senjata 1H", row = 2, col = 1},
    {slot = "weapon2h", label = "Senjata 2H", row = 3, col = 1},
    {slot = "pants", label = "Celana", row = 3, col = 2},
    {slot = "shoes", label = "Sepatu", row = 4, col = 2},
    {slot = "ringLeft", label = "Cincin L", row = 3, col = 3},
    {slot = "ringRight", label = "Cincin R", row = 3, col = 4},
    {slot = "necklace", label = "Kalung", row = 2, col = 3},
}

function EquipmentUI:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "EquipmentUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = playerGui
    
    -- Main frame
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 400)
    frame.Position = UDim2.new(0.5, -175, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 35)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Equipment"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextStrokeTransparency = 0
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    closeBtn.Parent = frame
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Stats display
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -20, 0, 60)
    statsFrame.Position = UDim2.new(0, 10, 0, 40)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = frame
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 6)
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -10, 1, -10)
    statsLabel.Position = UDim2.new(0, 5, 0, 5)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "ATK: 0 | DEF: 0 | MATK: 0 | SPD: 0"
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextScaled = true
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = statsFrame
    
    -- Equipment slots grid
    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(1, -20, 0, 250)
    gridFrame.Position = UDim2.new(0, 10, 0, 110)
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = frame
    
    for _, layout in ipairs(slotLayout) do
        local slotBtn = Instance.new("TextButton")
        slotBtn.Name = "Slot_" .. layout.slot
        slotBtn.Size = UDim2.new(0, 70, 0, 55)
        slotBtn.Position = UDim2.new(0, (layout.col - 1) * 80, 0, (layout.row - 1) * 65)
        slotBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        slotBtn.BorderSizePixel = 0
        slotBtn.Text = ""
        slotBtn.Parent = gridFrame
        Instance.new("UICorner", slotBtn).CornerRadius = UDim.new(0, 6)
        
        -- Slot label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "ItemName"
        nameLabel.Size = UDim2.new(1, -4, 0, 20)
        nameLabel.Position = UDim2.new(0, 2, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = layout.label
        nameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Parent = slotBtn
        
        -- Item display
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Name = "ItemDisplay"
        itemLabel.Size = UDim2.new(1, -4, 0, 25)
        itemLabel.Position = UDim2.new(0, 2, 0, 25)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Text = "[Empty]"
        itemLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        itemLabel.Font = Enum.Font.Gotham
        itemLabel.TextScaled = true
        itemLabel.Parent = slotBtn
        
        equipSlots[layout.slot] = {button = slotBtn, nameLabel = nameLabel, itemLabel = itemLabel}
        
        -- Click to unequip
        slotBtn.MouseButton1Click:Connect(function()
            if playerData and playerData.equipment and playerData.equipment[layout.slot] then
                local equipEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EquipEvent")
                if equipEvent then
                    equipEvent:FireServer("unequip", {slot = layout.slot})
                end
            end
        end)
    end
    
    print("[EquipmentUI] Created!")
end

function EquipmentUI:Update(data)
    playerData = data
    
    -- Update stats
    local statsLabel = frame and frame:FindFirstChild("StatsLabel", true)
    if statsLabel then
        statsLabel.Text = string.format("ATK:%d DEF:%d MATK:%d MDEF:%d SPD:%d LUK:%d",
            data.atk or 0, data.def or 0, data.matk or 0, data.mdef or 0, data.spd or 0, data.luk or 0)
    end
    
    -- Update equipment slots
    if data.equipment then
        for slot, itemId in pairs(data.equipment) do
            local slotUI = equipSlots[slot]
            if slotUI then
                if itemId then
                    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
                    local itemData = GameData.Items and GameData.Items[itemId]
                    slotUI.itemLabel.Text = itemData and itemData.name or itemId
                    slotUI.itemLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
                    slotUI.button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                else
                    slotUI.itemLabel.Text = "[Empty]"
                    slotUI.itemLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
                    slotUI.button.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                end
            end
        end
    end
end

function EquipmentUI:Toggle()
    isOpen = not isOpen
    if gui then
        gui.Enabled = isOpen
    end
end

function EquipmentUI:IsOpen()
    return isOpen
end

return EquipmentUI
