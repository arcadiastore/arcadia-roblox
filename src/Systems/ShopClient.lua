--[[
    Arcadia Online - Shop Client
    
    Handles shop UI and interaction:
    - Open shops from NPCs
    - Buy/sell items
    - Display shop items
    
    Place di: StarterPlayerScripts/Client (as LocalScript)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Player reference
local player = Players.LocalPlayer

print("[ShopClient] Shop Client initializing...")

-- Wait for Events folder
local eventsFolder = ReplicatedStorage:WaitForChild("Events", 10)
if not eventsFolder then
    warn("[ShopClient] Events folder not found!")
    return
end

-- Get RemoteEvents
local shopEvent = eventsFolder:WaitForChild("ShopEvent", 10)

if not shopEvent then
    warn("[ShopClient] Shop event not found!")
    return
end

print("[ShopClient] Shop event found!")

-- ============================================
-- SHOP UI
-- ============================================

-- Create shop UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Shop frame (hidden by default)
local shopFrame = Instance.new("Frame")
shopFrame.Name = "Shop"
shopFrame.Size = UDim2.new(0, 500, 0, 400)
shopFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopFrame.BorderSizePixel = 0
shopFrame.Visible = false
shopFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = shopFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleBar.BorderSizePixel = 0
titleBar.Parent = shopFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -40, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Shop"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.TextStrokeTransparency = 0
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextScaled = true
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeButton

-- Gold display
local goldLabel = Instance.new("TextLabel")
goldLabel.Name = "Gold"
goldLabel.Size = UDim2.new(0, 150, 0, 30)
goldLabel.Position = UDim2.new(1, -160, 0, 45)
goldLabel.BackgroundTransparency = 1
goldLabel.Text = "Gold: 0"
goldLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
goldLabel.TextStrokeTransparency = 0
goldLabel.TextScaled = true
goldLabel.Font = Enum.Font.Gotham
goldLabel.Parent = shopFrame

-- Item list
local itemList = Instance.new("ScrollingFrame")
itemList.Name = "ItemList"
itemList.Size = UDim2.new(1, -20, 1, -90)
itemList.Position = UDim2.new(0, 10, 0, 80)
itemList.BackgroundTransparency = 1
itemList.ScrollBarThickness = 8
itemList.Parent = shopFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.Parent = itemList

-- ============================================
-- SHOP FUNCTIONS
-- ============================================

-- Update gold display
local function updateGoldDisplay(gold)
    goldLabel.Text = "Gold: " .. tostring(gold)
end

-- Create item button
local function createItemButton(item)
    local button = Instance.new("Frame")
    button.Name = item.id
    button.Size = UDim2.new(1, 0, 0, 60)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Parent = itemList
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = button
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = item.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button
    
    -- Item price
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "Price"
    priceLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
    priceLabel.Position = UDim2.new(0.6, 0, 0, 0)
    priceLabel.BackgroundTransparency = 1
    priceLabel.Text = item.price .. " G"
    priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    priceLabel.TextStrokeTransparency = 0
    priceLabel.TextScaled = true
    priceLabel.Font = Enum.Font.Gotham
    priceLabel.Parent = button
    
    -- Item description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(0.9, 0, 0.5, 0)
    descLabel.Position = UDim2.new(0, 10, 0.5, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = item.description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.TextStrokeTransparency = 0
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = button
    
    -- Buy button
    local buyButton = Instance.new("TextButton")
    buyButton.Name = "Buy"
    buyButton.Size = UDim2.new(0, 60, 0, 30)
    buyButton.Position = UDim2.new(1, -70, 0.5, -15)
    buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    buyButton.BorderSizePixel = 0
    buyButton.Text = "Buy"
    buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    buyButton.TextScaled = true
    buyButton.Font = Enum.Font.GothamBold
    buyButton.Parent = button
    
    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 5)
    buyCorner.Parent = buyButton
    
    -- Buy button click
    buyButton.MouseButton1Click:Connect(function()
        shopEvent:FireServer("buy", {
            itemId = item.id,
            quantity = 1,
        })
    end)
    
    return button
end

-- Update shop display
local function updateShopDisplay(items)
    -- Clear existing items
    for _, child in ipairs(itemList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Create new items
    for _, item in ipairs(items) do
        createItemButton(item)
    end
end

-- Open shop
local function openShop(shopData, items)
    titleLabel.Text = shopData.name
    updateShopDisplay(items)
    shopFrame.Visible = true
end

-- Close shop
local function closeShop()
    shopFrame.Visible = false
end

-- ============================================
-- INPUT HANDLING
-- ============================================

-- ESC to close shop
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    
    if input.KeyCode == Enum.KeyCode.Escape then
        if shopFrame.Visible then
            closeShop()
        end
    end
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    closeShop()
end)

-- ============================================
-- SHOP EVENT HANDLING
-- ============================================

shopEvent.OnClientEvent:Connect(function(data)
    if data.type == "ShopOpened" then
        -- Open shop
        openShop(data.shop, data.items)
        updateGoldDisplay(data.gold or 0)
        
    elseif data.type == "ItemBought" then
        -- Show notification
        print("[ShopClient] Bought " .. data.quantity .. "x item for " .. data.totalPrice .. " gold")
        updateGoldDisplay(data.remainingGold)
        
    elseif data.type == "ItemSold" then
        -- Show notification
        print("[ShopClient] Sold item for " .. data.sellPrice .. " gold")
        updateGoldDisplay(data.remainingGold)
    end
end)

-- ============================================
-- SHOP INTERACTION
-- ============================================

-- Check for shop NPCs
local function checkShopNPC(target)
    if not target then
        return false
    end
    
    local hasShop = target:GetAttribute("HasShop")
    if hasShop then
        local npcId = target:GetAttribute("NPCId")
        local npcName = target:GetAttribute("NPCName")
        local greeting = target:GetAttribute("Greeting")
        
        print("[ShopClient] Found shop NPC: " .. npcName)
        print("[ShopClient] " .. greeting)
        
        -- Determine shop type
        local shopId = "general_shop"  -- Default
        if npcId == "Blacksmith" then
            shopId = "weapon_shop"
        end
        
        -- Send shop request to server
        shopEvent:FireServer("open", {
            shopId = shopId,
        })
        
        return true
    end
    
    return false
end

-- Mouse click to interact with NPCs
local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
    local target = mouse.Target
    if target then
        checkShopNPC(target)
    end
end)

print("[ShopClient] Shop Client ready!")
