--[[
    InventoryUI.lua
    Inventory panel with tabs + item detail popup (INFORMATIF!)
]]

local InventoryUI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui, frame, isOpen = nil, nil, false
local playerData = nil
local currentTab = "consumable"

local tabButtons = {}
local scrollFrame = nil
local detailFrame = nil

-- Build detail text for an item
local function buildDetailText(itemData, slot)
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    local text = ""
    
    -- Name + count
    local countText = (slot and slot.count and slot.count > 1) and (" x" .. slot.count) or ""
    text = text .. itemData.name .. countText .. "\n"
    
    -- Type
    local typeNames = {
        consumable = "Konsumsi",
        material = "Material",
        equipment = "Equipment",
    }
    text = text .. "Tipe: " .. (typeNames[itemData.type] or itemData.type or "Unknown") .. "\n"
    
    -- Slot (for equipment)
    if itemData.slot then
        local slotNames = {
            hat = "Kepala",
            tshirt = "Baju",
            pants = "Celana",
            shoes = "Sepatu",
            ringLeft = "Cincin Kiri",
            ringRight = "Cincin Kanan",
            necklace = "Kalung",
            weapon1h = "Senjata 1T",
            weapon2h = "Senjata 2T",
            wings = "Sayap",
            costume = "Kostum",
        }
        text = text .. "Slot: " .. (slotNames[itemData.slot] or itemData.slot) .. "\n"
    end
    
    text = text .. "\n"
    
    -- Description
    text = text .. itemData.description .. "\n"
    
    -- Stats (for equipment)
    if itemData.stats then
        text = text .. "\nStats:\n"
        local statNames = {
            atk = "ATK",
            def = "DEF",
            matk = "MATK",
            spd = "SPD",
            luk = "LUK",
            hp = "HP",
            mp = "MP",
        }
        for stat, value in pairs(itemData.stats) do
            local prefix = value > 0 and "+" or ""
            text = text .. "  " .. (statNames[stat] or stat) .. " " .. prefix .. value .. "\n"
        end
    end
    
    -- Range (for weapons)
    if itemData.range then
        local rangeType = itemData.range > 15 and "Ranged" or "Melee"
        text = text .. "\nJarak: " .. itemData.range .. " (" .. rangeType .. ")\n"
    end
    
    -- Level requirement
    if itemData.levelReq and itemData.levelReq > 1 then
        text = text .. "\nLevel: " .. itemData.levelReq .. "+\n"
    end
    
    -- Job requirement
    if itemData.jobReq then
        text = text .. "Job: "
        for i, job in ipairs(itemData.jobReq) do
            if i > 1 then text = text .. ", " end
            text = text .. job
        end
        text = text .. "\n"
    end
    
    -- Price
    if itemData.price then
        text = text .. "\nHarga Beli: " .. itemData.price .. " Gold\n"
    end
    if itemData.sellPrice then
        text = text .. "Harga Jual: " .. itemData.sellPrice .. " Gold\n"
    end
    
    -- Consumable effect
    if itemData.healHP then
        text = text .. "\nEfek: Pulihkan " .. itemData.healHP .. " HP\n"
    end
    if itemData.healMP then
        text = text .. "Efek: Pulihkan " .. itemData.healMP .. " MP\n"
    end
    
    return text
end

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
    
    -- Detail popup (hidden by default)
    detailFrame = Instance.new("Frame")
    detailFrame.Name = "DetailPopup"
    detailFrame.Size = UDim2.new(0, 280, 0, 350)
    detailFrame.Position = UDim2.new(0.5, -140, 0.5, -175)
    detailFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    detailFrame.BackgroundTransparency = 0.05
    detailFrame.BorderSizePixel = 0
    detailFrame.Visible = false
    detailFrame.Parent = gui
    Instance.new("UICorner", detailFrame).CornerRadius = UDim.new(0, 10)
    
    -- Detail title
    local detailTitle = Instance.new("TextLabel")
    detailTitle.Name = "DetailTitle"
    detailTitle.Size = UDim2.new(1, -20, 0, 25)
    detailTitle.Position = UDim2.new(0, 10, 0, 5)
    detailTitle.BackgroundTransparency = 1
    detailTitle.Text = "Detail Item"
    detailTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    detailTitle.Font = Enum.Font.GothamBold
    detailTitle.TextScaled = true
    detailTitle.TextXAlignment = Enum.TextXAlignment.Left
    detailTitle.Parent = detailFrame
    
    -- Detail content (scrollable)
    local detailScroll = Instance.new("ScrollingFrame")
    detailScroll.Name = "DetailContent"
    detailScroll.Size = UDim2.new(1, -20, 1, -75)
    detailScroll.Position = UDim2.new(0, 10, 0, 32)
    detailScroll.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    detailScroll.BorderSizePixel = 0
    detailScroll.ScrollBarThickness = 4
    detailScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    detailScroll.Parent = detailFrame
    Instance.new("UICorner", detailScroll).CornerRadius = UDim.new(0, 6)
    
    local detailText = Instance.new("TextLabel")
    detailText.Name = "DetailText"
    detailText.Size = UDim2.new(1, -10, 0, 0)
    detailText.Position = UDim2.new(0, 5, 0, 0)
    detailText.BackgroundTransparency = 1
    detailText.Text = ""
    detailText.TextColor3 = Color3.fromRGB(220, 220, 220)
    detailText.Font = Enum.Font.Gotham
    detailText.TextScaled = false
    detailText.TextSize = 14
    detailText.TextWrapped = true
    detailText.TextXAlignment = Enum.TextXAlignment.Left
    detailText.TextYAlignment = Enum.TextYAlignment.Top
    detailText.AutomaticSize = Enum.AutomaticSize.Y
    detailText.Parent = detailScroll
    
    detailText:GetPropertyChangedSignal("TextBounds"):Connect(function()
        detailScroll.CanvasSize = UDim2.new(0, 0, 0, detailText.TextBounds.Y + 10)
    end)
    
    -- Detail action button
    local detailActionBtn = Instance.new("TextButton")
    detailActionBtn.Name = "ActionBtn"
    detailActionBtn.Size = UDim2.new(0.45, -5, 0, 30)
    detailActionBtn.Position = UDim2.new(0.05, 0, 1, -38)
    detailActionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    detailActionBtn.Text = "Equip"
    detailActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    detailActionBtn.Font = Enum.Font.GothamBold
    detailActionBtn.TextScaled = true
    detailActionBtn.Parent = detailFrame
    Instance.new("UICorner", detailActionBtn).CornerRadius = UDim.new(0, 6)
    
    -- Detail close button
    local detailCloseBtn = Instance.new("TextButton")
    detailCloseBtn.Name = "CloseBtn"
    detailCloseBtn.Size = UDim2.new(0.45, -5, 0, 30)
    detailCloseBtn.Position = UDim2.new(0.5, 0, 1, -38)
    detailCloseBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    detailCloseBtn.Text = "Tutup"
    detailCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    detailCloseBtn.Font = Enum.Font.GothamBold
    detailCloseBtn.TextScaled = true
    detailCloseBtn.Parent = detailFrame
    Instance.new("UICorner", detailCloseBtn).CornerRadius = UDim.new(0, 6)
    
    detailCloseBtn.MouseButton1Click:Connect(function()
        detailFrame.Visible = false
    end)
    
    -- Store references for detail popup
    self._detailFrame = detailFrame
    self._detailActionBtn = detailActionBtn
    
    print("[InventoryUI] Created!")
end

-- Show item detail popup
function InventoryUI:ShowDetail(itemData, slot)
    if not detailFrame then return end
    
    local detailText = detailFrame:FindFirstChild("DetailContent", true) and detailFrame.DetailContent:FindFirstChild("DetailText")
    if detailText then
        detailText.Text = buildDetailText(itemData, slot)
    end
    
    -- Update action button
    local actionBtn = self._detailActionBtn
    if actionBtn then
        actionBtn.MouseButton1Click:Connect(function() end)  -- Disconnect old
        
        if itemData.type == "equipment" then
            -- Check job requirement
            local canEquip = true
            local reason = ""
            
            if itemData.jobReq and playerData then
                canEquip = false
                for _, job in ipairs(itemData.jobReq) do
                    if job == playerData.job then
                        canEquip = true
                        break
                    end
                end
                if not canEquip then
                    reason = "Job " .. (playerData.job or "None") .. " tidak bisa pakai!"
                end
            end
            
            -- Check level requirement
            if canEquip and itemData.levelReq and playerData then
                if (playerData.level or 1) < itemData.levelReq then
                    canEquip = false
                    reason = "Level kurang! Butuh Lv." .. itemData.levelReq
                end
            end
            
            if canEquip then
                actionBtn.Text = "Equip"
                actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
                actionBtn.MouseButton1Click:Connect(function()
                    local equipEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EquipEvent")
                    if equipEvent then
                        equipEvent:FireServer("equip", {itemId = itemData.id})
                    end
                    detailFrame.Visible = false
                end)
            else
                actionBtn.Text = reason
                actionBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
                actionBtn.MouseButton1Click:Connect(function() end)
            end
        elseif itemData.type == "consumable" then
            actionBtn.Text = "Use"
            actionBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
            actionBtn.MouseButton1Click:Connect(function()
                local invEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("InventoryEvent")
                if invEvent then
                    invEvent:FireServer("use", {itemId = itemData.id})
                end
                detailFrame.Visible = false
            end)
        else
            actionBtn.Text = "OK"
            actionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end
    
    detailFrame.Visible = true
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
    
    -- Sort: newest first
    for i = 1, math.floor(#items / 2) do
        local j = #items - i + 1
        items[i], items[j] = items[j], items[i]
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
        
        -- Click entire row to show detail
        btn.MouseButton1Click:Connect(function()
            self:ShowDetail(itemData, slot)
        end)
    end
end

function InventoryUI:Update(data)
    playerData = data
    
    local goldLabel = frame and frame:FindFirstChild("GoldLabel", true)
    if goldLabel then
        goldLabel.Text = "Gold: " .. (data.gold or 0)
    end
    
    -- Always refresh if inventory is open
    if isOpen then
        self:RefreshItems()
    end
end

function InventoryUI:Toggle()
    isOpen = not isOpen
    if gui then
        gui.Enabled = isOpen
        if isOpen then
            -- Small delay to let GUI render, then refresh
            task.wait(0.1)
            self:RefreshItems()
        else
            if detailFrame then
                detailFrame.Visible = false
            end
        end
    end
end

function InventoryUI:IsOpen()
    return isOpen
end

return InventoryUI
