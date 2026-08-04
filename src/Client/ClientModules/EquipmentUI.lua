--[[
    EquipmentUI.lua
    Equipment panel - equip/unequip items with job validation
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
    frame.Size = UDim2.new(0, 380, 0, 460)
    frame.Position = UDim2.new(0.5, -190, 0.5, -230)
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
    statsFrame.Size = UDim2.new(1, -20, 0, 80)
    statsFrame.Position = UDim2.new(0, 10, 0, 40)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = frame
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 6)
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "StatsLabel"
    statsLabel.Size = UDim2.new(1, -10, 1, -5)
    statsLabel.Position = UDim2.new(0, 5, 0, 2)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "Stats loading..."
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.TextScaled = true
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Parent = statsFrame
    
    -- Equipment grid
    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(1, -20, 0, 280)
    gridFrame.Position = UDim2.new(0, 10, 0, 130)
    gridFrame.BackgroundTransparency = 1
    gridFrame.Parent = frame
    
    -- Create slot buttons
    for _, layout in ipairs(slotLayout) do
        local btn = Instance.new("TextButton")
        btn.Name = "Slot_" .. layout.slot
        btn.Size = UDim2.new(0.23, 0, 0, 60)
        btn.Position = UDim2.new((layout.col - 1) * 0.25, 0, (layout.row - 1) * 0.25, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.Parent = gridFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        -- Slot name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "SlotName"
        nameLabel.Size = UDim2.new(1, 0, 0, 15)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = layout.label
        nameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextScaled = true
        nameLabel.Parent = btn
        
        -- Item name
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Name = "ItemName"
        itemLabel.Size = UDim2.new(1, 0, 0, 20)
        itemLabel.Position = UDim2.new(0, 0, 0, 15)
        itemLabel.BackgroundTransparency = 1
        itemLabel.Text = ""
        itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        itemLabel.Font = Enum.Font.GothamBold
        itemLabel.TextScaled = true
        itemLabel.Parent = btn
        
        -- Item stats
        local statsLbl = Instance.new("TextLabel")
        statsLbl.Name = "ItemStats"
        statsLbl.Size = UDim2.new(1, 0, 0, 15)
        statsLbl.Position = UDim2.new(0, 0, 0, 35)
        statsLbl.BackgroundTransparency = 1
        statsLbl.Text = ""
        statsLbl.TextColor3 = Color3.fromRGB(180, 180, 100)
        statsLbl.Font = Enum.Font.Gotham
        statsLbl.TextScaled = true
        statsLbl.Parent = btn
        
        -- Unequip button (X)
        local unequipBtn = Instance.new("TextButton")
        unequipBtn.Name = "UnequipBtn"
        unequipBtn.Size = UDim2.new(0, 18, 0, 18)
        unequipBtn.Position = UDim2.new(1, -20, 0, 2)
        unequipBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        unequipBtn.Text = "X"
        unequipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        unequipBtn.Font = Enum.Font.GothamBold
        unequipBtn.TextScaled = true
        unequipBtn.Visible = false
        unequipBtn.Parent = btn
        Instance.new("UICorner", unequipBtn).CornerRadius = UDim.new(1, 0)
        
        -- Unequip click
        unequipBtn.MouseButton1Click:Connect(function()
            local EquipEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EquipEvent")
            if EquipEvent then
                EquipEvent:FireServer("unequip", {slot = layout.slot})
            end
            task.wait(0.3)
            self:Update()
        end)
        
        equipSlots[layout.slot] = btn
    end
    
    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Size = UDim2.new(1, -20, 0, 30)
    infoLabel.Position = UDim2.new(0, 10, 1, -40)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Klik slot = Unequip | Klik item di Inventory = Equip"
    infoLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextScaled = true
    infoLabel.Parent = frame
end

function EquipmentUI:Update(data)
    if data then
        playerData = data
    end
    if not playerData then return end
    if not frame then return end
    if not isOpen then return end
    
    local GameData = ReplicatedStorage:FindFirstChild("GameData")
    if not GameData then return end
    GameData = require(GameData)
    
    local data = playerData
    if not data then return end
    
    -- Update stats
    local statsLabel = frame:FindFirstChild("StatsLabel", true)
    if statsLabel then
        statsLabel.Text = string.format(
            "Job: %s | Lv.%d\nHP: %d/%d | MP: %d/%d\nATK: %d | DEF: %d | SPD: %d",
            data.job or "None",
            data.level or 1,
            data.hp or 0, data.maxHp or 100,
            data.mp or 0, data.maxMp or 50,
            data.atk or 10, data.def or 5, data.spd or 5
        )
    end
    
    -- Update each slot
    for slotName, btn in pairs(equipSlots) do
        local itemId = data.equipment and data.equipment[slotName]
        local itemLabel = btn:FindFirstChild("ItemName")
        local statsLbl = btn:FindFirstChild("ItemStats")
        local unequipBtn = btn:FindFirstChild("UnequipBtn")
        
        if itemId and GameData.Items and GameData.Items[itemId] then
            local itemData = GameData.Items[itemId]
            if itemLabel then
                itemLabel.Text = itemData.name or itemId
                itemLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            end
            if statsLbl then
                local stats = {}
                if itemData.stats then
                    for stat, val in pairs(itemData.stats) do
                        table.insert(stats, "+" .. val .. " " .. string.upper(stat))
                    end
                end
                statsLbl.Text = table.concat(stats, " ")
            end
            if unequipBtn then
                unequipBtn.Visible = true
            end
            -- Show item color indicator
            local colorDot = btn:FindFirstChild("ColorDot")
            if not colorDot then
                colorDot = Instance.new("Frame")
                colorDot.Name = "ColorDot"
                colorDot.Size = UDim2.new(0, 16, 0, 16)
                colorDot.Position = UDim2.new(0, 4, 0, 4)
                colorDot.BorderSizePixel = 0
                colorDot.Parent = btn
                Instance.new("UICorner", colorDot).CornerRadius = UDim.new(0, 8)
            end
            if itemData.visual and itemData.visual.color then
                colorDot.BackgroundColor3 = itemData.visual.color
                colorDot.Visible = true
            else
                colorDot.Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
        else
            if itemLabel then
                itemLabel.Text = "[Kosong]"
                itemLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
            end
            if statsLbl then
                statsLbl.Text = ""
            end
            if unequipBtn then
                unequipBtn.Visible = false
            end
            -- Hide color dot when empty
            local colorDot = btn:FindFirstChild("ColorDot")
            if colorDot then
                colorDot.Visible = false
            end
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        end
    end
end

function EquipmentUI:SetData(data)
    playerData = data
    if isOpen then
        self:Update()
    end
end

function EquipmentUI:Toggle()
    isOpen = not isOpen
    if gui then
        gui.Enabled = isOpen
        if isOpen then
            print("[EquipmentUI] Opening - playerData: " .. tostring(playerData ~= nil))
            if playerData then
                print("[EquipmentUI] equipment: " .. tostring(playerData.equipment ~= nil))
            end
            self:Update()
        end
    end
end

function EquipmentUI:IsOpen()
    return isOpen
end

return EquipmentUI
