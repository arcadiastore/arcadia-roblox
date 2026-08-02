--[[
    Arcadia Online - Shop System (v2 - Data-Driven)
    
    Semua data dari GameData module
    Tidak ada hardcode!
    
    Place di: ServerScriptService/Systems (as Script)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[Shop] Shop System initializing...")

-- ============================================
-- SHOP MANAGER
-- ============================================

local ShopManager = {}
ShopManager.__index = ShopManager

function ShopManager.new()
    local self = setmetatable({}, ShopManager)
    self.playerInventory = {}
    return self
end

function ShopManager:Init()
    self:SetupPlayerConnections()
    self:SetupShopEvents()
    
    -- Create Events folder if not exists
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "Events"
        eventsFolder.Parent = ReplicatedStorage
    end
    
    print("[Shop] Shop System initialized!")
end

function ShopManager:SetupPlayerConnections()
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
end

function ShopManager:OnPlayerAdded(player)
    self.playerInventory[player.UserId] = {}
    print("[Shop] Player inventory initialized: " .. player.Name)
end

function ShopManager:OnPlayerRemoving(player)
    self.playerInventory[player.UserId] = nil
end

function ShopManager:SetupShopEvents()
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    
    local shopEvent = Instance.new("RemoteEvent")
    shopEvent.Name = "ShopEvent"
    shopEvent.Parent = eventsFolder
    
    shopEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "buy" then
            self:BuyItem(player, data.itemId, data.quantity or 1)
        elseif action == "sell" then
            self:SellItem(player, data.itemId, data.quantity or 1)
        elseif action == "open" then
            self:OpenShop(player, data.shopId)
        end
    end)
end

function ShopManager:OpenShop(player, shopId)
    -- Get shop data from GameData
    local shopData = GameData:GetShop(shopId)
    if not shopData then
        warn("[Shop] Shop not found: " .. shopId)
        return
    end
    
    -- Get shop items from GameData
    local shopItems = GameData:GetShopItems(shopId)
    
    -- Send to client
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local shopEvent = eventsFolder:FindFirstChild("ShopEvent")
    if shopEvent then
        shopEvent:FireClient(player, {
            type = "ShopOpened",
            shop = shopData,
            items = shopItems,
        })
    end
    
    print("[Shop] " .. player.Name .. " opened shop: " .. shopData.name)
end

function ShopManager:BuyItem(player, itemId, quantity)
    -- Get item data from GameData
    local itemData = GameData:GetItem(itemId)
    if not itemData then
        warn("[Shop] Item not found: " .. itemId)
        return
    end
    
    -- Check gold
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if not playerStats then return end
    
    local totalPrice = itemData.price * quantity
    if playerStats.gold < totalPrice then
        warn("[Shop] Not enough gold!")
        return
    end
    
    -- Check level requirement
    if itemData.levelReq and playerStats.level < itemData.levelReq then
        warn("[Shop] Level too low!")
        return
    end
    
    -- Deduct gold
    playerStats.gold = playerStats.gold - totalPrice
    
    -- Add to inventory
    self:AddToInventory(player, itemId, quantity)
    
    -- Send feedback
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local shopEvent = eventsFolder:FindFirstChild("ShopEvent")
    if shopEvent then
        shopEvent:FireClient(player, {
            type = "ItemBought",
            itemId = itemId,
            itemName = itemData.name,
            quantity = quantity,
            totalPrice = totalPrice,
            remainingGold = playerStats.gold,
        })
    end
    
    print("[Shop] " .. player.Name .. " bought " .. quantity .. "x " .. itemData.name .. " for " .. totalPrice .. " gold")
end

function ShopManager:SellItem(player, itemId, quantity)
    local inventory = self.playerInventory[player.UserId]
    if not inventory then return end
    
    -- Find item in inventory
    local itemIndex = nil
    for i, item in ipairs(inventory) do
        if item.id == itemId then
            itemIndex = i
            break
        end
    end
    
    if not itemIndex then
        warn("[Shop] Item not in inventory!")
        return
    end
    
    local invItem = inventory[itemIndex]
    if invItem.quantity < quantity then
        warn("[Shop] Not enough items!")
        return
    end
    
    -- Get item data from GameData
    local itemData = GameData:GetItem(itemId)
    if not itemData then return end
    
    -- Calculate sell price from GameData
    local sellPrice = (itemData.sellPrice or 0) * quantity
    
    -- Update inventory
    invItem.quantity = invItem.quantity - quantity
    if invItem.quantity <= 0 then
        table.remove(inventory, itemIndex)
    end
    
    -- Add gold
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if playerStats then
        playerStats.gold = playerStats.gold + sellPrice
    end
    
    -- Send feedback
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local shopEvent = eventsFolder:FindFirstChild("ShopEvent")
    if shopEvent then
        shopEvent:FireClient(player, {
            type = "ItemSold",
            itemId = itemId,
            itemName = itemData.name,
            quantity = quantity,
            sellPrice = sellPrice,
            remainingGold = playerStats and playerStats.gold or 0,
        })
    end
    
    print("[Shop] " .. player.Name .. " sold " .. quantity .. "x " .. itemData.name .. " for " .. sellPrice .. " gold")
end

function ShopManager:AddToInventory(player, itemId, quantity)
    local inventory = self.playerInventory[player.UserId]
    if not inventory then return end
    
    local itemData = GameData:GetItem(itemId)
    if not itemData then return end
    
    -- Check if already in inventory
    local existingItem = nil
    for _, item in ipairs(inventory) do
        if item.id == itemId then
            existingItem = item
            break
        end
    end
    
    if existingItem then
        existingItem.quantity = existingItem.quantity + quantity
    else
        table.insert(inventory, {
            id = itemId,
            name = itemData.name,
            quantity = quantity,
        })
    end
    
    print("[Shop] Added to inventory: " .. quantity .. "x " .. itemData.name)
end

function ShopManager:GetPlayerInventory(player)
    return self.playerInventory[player.UserId]
end

-- Initialize
local shopManager = ShopManager.new()
shopManager:Init()
_G.ShopManager = shopManager

print("[Shop] Shop System ready!")
