--[[
    Arcadia Online - Shop Manager
    
    Handles shop system:
    - Buy items
    - Sell items
    - Shop inventory
    
    @author arcadiastore
    @version 1.0.0
]]

local ShopManager = {}
ShopManager.__index = ShopManager

-- Shop definitions
local ShopDatabase = {
    -- General Shop
    GeneralShop = {
        name = "Toko Umum",
        npcId = "Merchant",
        items = {
            { itemId = "potion_hp_small", price = 20, stock = -1 },  -- -1 = unlimited
            { itemId = "potion_hp_large", price = 50, stock = -1 },
            { itemId = "potion_mp_small", price = 30, stock = -1 },
            { itemId = "potion_mp_large", price = 80, stock = -1 },
            { itemId = "herb", price = 10, stock = -1 },
        },
    },
    
    -- Weapon Shop
    WeaponShop = {
        name = "Toko Senjata",
        npcId = "Blacksmith",
        items = {
            { itemId = "sword_wooden", price = 50, stock = 5 },
            { itemId = "sword_iron", price = 200, stock = 3 },
            { itemId = "bow_wooden", price = 80, stock = 5 },
            { itemId = "staff_apprentice", price = 100, stock = 3 },
        },
    },
    
    -- Armor Shop
    ArmorShop = {
        name = "Toko Armor",
        npcId = "Blacksmith",
        items = {
            { itemId = "armor_leather", price = 100, stock = 5 },
            { itemId = "armor_iron", price = 300, stock = 3 },
            { itemId = "shield_wooden", price = 60, stock = 5 },
        },
    },
    
    -- Accessory Shop
    AccessoryShop = {
        name = "Toko Aksesoris",
        npcId = "Merchant",
        items = {
            { itemId = "ring_power", price = 150, stock = 2 },
            { itemId = "necklace_hp", price = 120, stock = 3 },
            { itemId = "earring_agi", price = 130, stock = 3 },
        },
    },
}

function ShopManager.new()
    local self = setmetatable({}, ShopManager)
    
    self.shops = {}
    self.playerGold = {}
    
    return self
end

-- Get shop by ID
function ShopManager:GetShop(shopId)
    return ShopDatabase[shopId]
end

-- Get shop for NPC
function ShopManager:GetShopForNPC(npcId)
    for shopId, shop in pairs(ShopDatabase) do
        if shop.npcId == npcId then
            return shopId, shop
        end
    end
    return nil, nil
end

-- Open shop for player
function ShopManager:OpenShop(player, shopId)
    local shop = self:GetShop(shopId)
    if not shop then
        return false, "Shop not found"
    end
    
    -- Send shop data to client
    local shopData = {
        shopId = shopId,
        name = shop.name,
        items = self:GetShopItems(shopId),
        playerGold = self:GetPlayerGold(player),
    }
    
    -- Fire client event
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local openShopEvent = ReplicatedStorage:FindFirstChild("OpenShopEvent")
    if openShopEvent then
        openShopEvent:FireClient(player, shopData)
    end
    
    return true, shopData
end

-- Get shop items with current stock
function ShopManager:GetShopItems(shopId)
    local shop = self:GetShop(shopId)
    if not shop then return {} end
    
    local items = {}
    for _, item in ipairs(shop.items) do
        table.insert(items, {
            itemId = item.itemId,
            price = item.price,
            stock = item.stock,
        })
    end
    
    return items
end

-- Buy item from shop
function ShopManager:BuyItem(player, shopId, itemId, amount)
    amount = amount or 1
    
    local shop = self:GetShop(shopId)
    if not shop then
        return false, "Shop not found"
    end
    
    -- Find item in shop
    local shopItem = nil
    for _, item in ipairs(shop.items) do
        if item.itemId == itemId then
            shopItem = item
            break
        end
    end
    
    if not shopItem then
        return false, "Item not in shop"
    end
    
    -- Check stock
    if shopItem.stock ~= -1 and shopItem.stock < amount then
        return false, "Not enough stock"
    end
    
    -- Calculate total price
    local totalPrice = shopItem.price * amount
    
    -- Check player gold
    local playerGold = self:GetPlayerGold(player)
    if playerGold < totalPrice then
        return false, "Not enough gold"
    end
    
    -- Deduct gold
    self:RemovePlayerGold(player, totalPrice)
    
    -- Add item to inventory
    local InventoryManager = require(game.ServerScriptService.Systems.InventoryManager)
    local success = InventoryManager:AddItem(player.UserId, itemId, amount)
    
    if not success then
        -- Refund gold
        self:AddPlayerGold(player, totalPrice)
        return false, "Inventory full"
    end
    
    -- Update stock
    if shopItem.stock ~= -1 then
        shopItem.stock = shopItem.stock - amount
    end
    
    print("[Shop] " .. player.Name .. " bought " .. amount .. "x " .. itemId .. " for " .. totalPrice .. " gold")
    
    return true, "Purchase successful"
end

-- Sell item to shop
function ShopManager:SellItem(player, itemId, amount)
    amount = amount or 1
    
    local InventoryManager = require(game.ServerScriptService.Systems.InventoryManager)
    
    -- Check if player has item
    if not InventoryManager:HasItem(player.UserId, itemId, amount) then
        return false, "Don't have enough items"
    end
    
    -- Calculate sell price (50% of buy price)
    local buyPrice = self:GetItemBuyPrice(itemId)
    local sellPrice = math.floor(buyPrice * 0.5) * amount
    
    -- Remove item
    InventoryManager:RemoveItem(player.UserId, itemId, amount)
    
    -- Add gold
    self:AddPlayerGold(player, sellPrice)
    
    print("[Shop] " .. player.Name .. " sold " .. amount .. "x " .. itemId .. " for " .. sellPrice .. " gold")
    
    return true, "Sold for " .. sellPrice .. " gold"
end

-- Get item buy price
function ShopManager:GetItemBuyPrice(itemId)
    for _, shop in pairs(ShopDatabase) do
        for _, item in ipairs(shop.items) do
            if item.itemId == itemId then
                return item.price
            end
        end
    end
    return 0
end

-- Get player gold
function ShopManager:GetPlayerGold(player)
    local userId = player.UserId
    
    if not self.playerGold[userId] then
        self.playerGold[userId] = 100  -- Starting gold
    end
    
    return self.playerGold[userId]
end

-- Add player gold
function ShopManager:AddPlayerGold(player, amount)
    local userId = player.UserId
    self.playerGold[userId] = (self.playerGold[userId] or 0) + amount
end

-- Remove player gold
function ShopManager:RemovePlayerGold(player, amount)
    local userId = player.UserId
    if self.playerGold[userId] and self.playerGold[userId] >= amount then
        self.playerGold[userId] = self.playerGold[userId] - amount
        return true
    end
    return false
end

-- Serialize for saving
function ShopManager:Serialize(player)
    return {
        gold = self:GetPlayerGold(player),
    }
end

-- Deserialize from saved data
function ShopManager:Deserialize(player, data)
    if data and data.gold then
        self.playerGold[player.UserId] = data.gold
    end
end

return ShopManager.new()
