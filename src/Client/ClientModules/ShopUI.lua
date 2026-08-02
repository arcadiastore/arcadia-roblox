--[[
    ShopUI.lua
    Shop interface
]]

local ShopUI = {}

-- UI Elements
local shopFrame, shopItems, shopGold

-- Create Shop UI
function ShopUI:Create(gui)
    shopFrame = Instance.new("Frame")
    shopFrame.Size = UDim2.new(0, 400, 0, 350)
    shopFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
    shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    shopFrame.BorderSizePixel = 0
    shopFrame.Visible = false
    shopFrame.Parent = gui
    
    Instance.new("UICorner", shopFrame).CornerRadius = UDim.new(0, 10)
    
    local shopTitle = Instance.new("TextLabel")
    shopTitle.Size = UDim2.new(1, -40, 0, 35)
    shopTitle.Position = UDim2.new(0, 10, 0, 5)
    shopTitle.BackgroundTransparency = 1
    shopTitle.Text = "Shop"
    shopTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    shopTitle.TextStrokeTransparency = 0
    shopTitle.Font = Enum.Font.GothamBold
    shopTitle.TextScaled = true
    shopTitle.Parent = shopFrame
    
    local closeShop = Instance.new("TextButton")
    closeShop.Size = UDim2.new(0, 25, 0, 25)
    closeShop.Position = UDim2.new(1, -30, 0, 5)
    closeShop.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeShop.BorderSizePixel = 0
    closeShop.Text = "X"
    closeShop.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeShop.TextScaled = true
    closeShop.Font = Enum.Font.GothamBold
    closeShop.Parent = shopFrame
    
    closeShop.MouseButton1Click:Connect(function()
        shopFrame.Visible = false
    end)
    
    shopItems = Instance.new("ScrollingFrame")
    shopItems.Size = UDim2.new(1, -20, 1, -80)
    shopItems.Position = UDim2.new(0, 10, 0, 45)
    shopItems.BackgroundTransparency = 1
    shopItems.ScrollBarThickness = 6
    shopItems.Parent = shopFrame
    
    Instance.new("UIListLayout", shopItems).Padding = UDim.new(0, 5)
    
    shopGold = Instance.new("TextLabel")
    shopGold.Size = UDim2.new(1, -20, 0, 25)
    shopGold.Position = UDim2.new(0, 10, 1, -30)
    shopGold.BackgroundTransparency = 1
    shopGold.Text = "Gold: 100"
    shopGold.TextColor3 = Color3.fromRGB(255, 215, 0)
    shopGold.TextStrokeTransparency = 0
    shopGold.Font = Enum.Font.GothamBold
    shopGold.TextScaled = true
    shopGold.Parent = shopFrame
    
    print("[ShopUI] Created!")
end

-- Open shop
function ShopUI:Open(data, ShopEvent)
    if not shopFrame then return end
    
    -- Clear old items
    for _, child in ipairs(shopItems:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    -- Add items
    for _, item in ipairs(data.items) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        row.BorderSizePixel = 0
        row.Parent = shopItems
        
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        
        local name = Instance.new("TextLabel")
        name.Size = UDim2.new(0.6, 0, 1, 0)
        name.BackgroundTransparency = 1
        name.Text = item.name
        name.TextColor3 = Color3.fromRGB(255, 255, 255)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Font = Enum.Font.Gotham
        name.TextScaled = true
        name.Parent = row
        
        local price = Instance.new("TextLabel")
        price.Size = UDim2.new(0.2, 0, 1, 0)
        price.Position = UDim2.new(0.6, 0, 0, 0)
        price.BackgroundTransparency = 1
        price.Text = item.price .. "G"
        price.TextColor3 = Color3.fromRGB(255, 215, 0)
        price.Font = Enum.Font.Gotham
        price.TextScaled = true
        price.Parent = row
        
        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
        buyBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
        buyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        buyBtn.BorderSizePixel = 0
        buyBtn.Text = "Beli"
        buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        buyBtn.Font = Enum.Font.GothamBold
        buyBtn.TextScaled = true
        buyBtn.Parent = row
        
        buyBtn.MouseButton1Click:Connect(function()
            ShopEvent:FireServer("buy", {itemId = item.id})
        end)
    end
    
    shopGold.Text = "Gold: " .. data.gold
    shopFrame.Visible = true
end

-- Update gold display
function ShopUI:UpdateGold(gold)
    if shopGold then
        shopGold.Text = "Gold: " .. gold
    end
end

return ShopUI
