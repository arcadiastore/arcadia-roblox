--[[
    InventoryUI.lua
    Inventory panel with tabs: Consumable, Material, Equipment
]]

local InventoryUI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui, frame, isOpen = nil, nil, false
local playerData = nil
local currentTab = "consumable"

local tabButtons = {}
local scrollFrame = nil

function InventoryUI:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "InventoryUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = playerGui
    
    -- Main frame
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 420)
    frame.Position = UDim2.new(0.5, 50, 0.5, -210)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "Inventory"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.TextStrokeTransparency = 0
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
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
    
    -- Gold display
    local goldLabel = Instance.new("TextLabel")
    goldLabel.Name = "GoldLabel"
    goldLabel.Size = UDim2.new(1, -20, 0, 20)
    goldLabel.Position = UDim2.new(0, 10, 0, 35)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Text = "Gold: 0"
    goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldLabel.Font = Enum.Font.GothamBold
    goldLabel.TextScaled = true
    goldLabel.TextXAlignment = Enum.TextXAlignment.Left
    goldLabel.Parent = frame
    
    -- Tab buttons
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 28)
    tabFrame.Position = UDim2.new(0, 10, 0, 58)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = frame
    
    local tabs = {
        {id = "consumable", label = "Use", color = Color3.fromRGB(50, 100, 200)},
        {id = "material", label = "Mat", color = Color3.fromRGB(200, 150, 50)},
        {id = "equipment", label = "Equip", color = Color3.fromRGB(50, 180, 50)},
    }
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. tab.id
        btn.Size = UDim2.new(0.33, -3, 1, 0)
        btn.Position = UDim2.new((i - 1) * 0.33 + (i - 1) * 0.005, 0, 0, 0)
        btn.BackgroundColor3 = tab.color
        btn.BackgroundTransparency = 0.3
        btn.Text = tab.label
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.Parent = tabFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        tabButtons[tab.id] = btn
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tab.id
            self:RefreshItems()
        end)
    end
    
    -- Scroll frame for items
    scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ItemList"
    scrollFrame.Size = UDim2.new(1, -20, 1, -95)
    scrollFrame.Position = UDim2.new(0, 10, 0, 90)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.Parent = frame
    Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 6)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = scrollFrame
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    print("[InventoryUI] Created!")
end

function InventoryUI:RefreshItems()
    if not scrollFrame or not playerData then return end
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    
    -- Clear old items
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Update tab highlights
    for tabId, btn in pairs(tabButtons) do
        if tabId == currentTab then
            btn.BackgroundTransparency = 0
        else
            btn.BackgroundTransparency = 0.5
        end
    end
    
    -- Filter items by tab
    local items = {}
    if playerData.inventory then
        for _, slot in ipairs(playerData.inventory) do
            local itemData = GameData.Items and GameData.Items[slot.itemId]
            if itemData then
                local itemType = itemData.type or "other"
                if currentTab == "consumable" and itemType == "consumable" then
                    table.insert(items, {slot = slot, data = itemData})
                elseif currentTab == "material" and itemType == "material" then
                    table.insert(items, {slot = slot, data = itemData})
                elseif currentTab == "equipment" and itemType == "equipment" then
                    table.insert(items, {slot = slot, data = itemData})
                end
            end
        end
    end
    
    -- Show empty message
    if #items == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 40)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "Tidak ada item"
        emptyLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextScaled = true
        emptyLabel.Parent = scrollFrame
        return
    end
    
    -- Create item rows
    for i, entry in ipairs(items) do
        local itemData = entry.data
        local slot = entry.slot
        
        local btn = Instance.new("TextButton")
        btn.Name = "Item_" .. i
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.LayoutOrder = i
        btn.Parent = scrollFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        -- Item name + count
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0.55, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        local countText = slot.count > 1 and (" x" .. slot.count) or ""
        nameLabel.Text = itemData.name .. countText
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextScaled = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = btn
        
        -- Action button
        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(0.4, -5, 0.7, 0)
        actionBtn.Position = UDim2.new(0.6, 0, 0.15, 0)
        actionBtn.BorderSizePixel = 0
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.TextScaled = true
        actionBtn.Parent = btn
        Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 4)
        
        if itemData.type == "equipment" then
            actionBtn.Text = "Equip"
            actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            actionBtn.MouseButton1Click:Connect(function()
                local equipEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EquipEvent")
                if equipEvent then
                    equipEvent:FireServer("equip", {itemId = slot.itemId})
                end
            end)
        elseif itemData.type == "consumable" then
            actionBtn.Text = "Use"
            actionBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            actionBtn.MouseButton1Click:Connect(function()
                local invEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("InventoryEvent")
                if invEvent then
                    invEvent:FireServer("use", {itemId = slot.itemId})
                end
            end)
        else
            actionBtn.Text = "Info"
            actionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            actionBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

function InventoryUI:Update(data)
    playerData = data
    
    -- Update gold
    local goldLabel = frame and frame:FindFirstChild("GoldLabel", true)
    if goldLabel then
        goldLabel.Text = "Gold: " .. (data.gold or 0)
    end
    
    -- Refresh items
    self:RefreshItems()
end

function InventoryUI:Toggle()
    isOpen = not isOpen
    if gui then
        gui.Enabled = isOpen
        if isOpen then
            self:RefreshItems()
        end
    end
end

function InventoryUI:IsOpen()
    return isOpen
end

return InventoryUI
