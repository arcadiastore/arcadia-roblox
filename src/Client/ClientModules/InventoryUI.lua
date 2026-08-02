--[[
    InventoryUI.lua
    Inventory panel - view items, equip, use consumables
]]

local InventoryUI = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gui, frame, isOpen = nil, nil, false
local itemButtons = {}
local playerData = nil

function InventoryUI:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "InventoryUI"
    gui.ResetOnSpawn = false
    gui.Enabled = false
    gui.Parent = playerGui
    
    -- Main frame
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 400)
    frame.Position = UDim2.new(0.5, 50, 0.5, -200)
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
    title.Text = "Inventory"
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
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
    
    -- Gold display
    local goldLabel = Instance.new("TextLabel")
    goldLabel.Name = "GoldLabel"
    goldLabel.Size = UDim2.new(1, -20, 0, 25)
    goldLabel.Position = UDim2.new(0, 10, 0, 40)
    goldLabel.BackgroundTransparency = 1
    goldLabel.Text = "Gold: 0"
    goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    goldLabel.Font = Enum.Font.GothamBold
    goldLabel.TextScaled = true
    goldLabel.TextXAlignment = Enum.TextXAlignment.Left
    goldLabel.Parent = frame
    
    -- Scroll frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ItemList"
    scrollFrame.Size = UDim2.new(1, -20, 1, -80)
    scrollFrame.Position = UDim2.new(0, 10, 0, 70)
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

function InventoryUI:Update(data)
    playerData = data
    
    -- Update gold
    local goldLabel = frame and frame:FindFirstChild("GoldLabel", true)
    if goldLabel then
        goldLabel.Text = "Gold: " .. (data.gold or 0)
    end
    
    -- Clear old items
    local scrollFrame = frame and frame:FindFirstChild("ItemList", true)
    if not scrollFrame then return end
    
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    itemButtons = {}
    
    -- Build item list
    if not data.inventory then return end
    
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    
    for i, slot in ipairs(data.inventory) do
        local itemData = GameData.Items and GameData.Items[slot.itemId]
        if itemData then
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
            nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
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
            actionBtn.Size = UDim2.new(0.35, -5, 0.7, 0)
            actionBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
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
                actionBtn.Text = itemData.type or "?"
                actionBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
                actionBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end
end

function InventoryUI:Toggle()
    isOpen = not isOpen
    if gui then
        gui.Enabled = isOpen
    end
end

function InventoryUI:IsOpen()
    return isOpen
end

return InventoryUI
