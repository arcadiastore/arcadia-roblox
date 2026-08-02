--[[
    Arcadia Online - Shop System
    
    Handles shops according to GDD:
    - Buy items from shops
    - Sell items
    - Gold management
    - Item data
    
    Place di: ServerScriptService/Systems (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu game load
task.wait(7)

print("[Shop] Shop System initializing...")

-- ============================================
-- ITEM DEFINITIONS (GDD)
-- ============================================

local ITEM_DATA = {
    -- Potions
    {
        id = "hp_potion_small",
        name = "HP Potion (Small)",
        description = "Memulihkan 50 HP",
        type = "consumable",
        subtype = "potion",
        price = 50,
        effect = {
            stat = "hp",
            value = 50,
        },
    },
    {
        id = "hp_potion_medium",
        name = "HP Potion (Medium)",
        description = "Memulihkan 100 HP",
        type = "consumable",
        subtype = "potion",
        price = 100,
        effect = {
            stat = "hp",
            value = 100,
        },
    },
    {
        id = "mp_potion_small",
        name = "MP Potion (Small)",
        description = "Memulihkan 30 MP",
        type = "consumable",
        subtype = "potion",
        price = 40,
        effect = {
            stat = "mp",
            value = 30,
        },
    },
    {
        id = "mp_potion_medium",
        name = "MP Potion (Medium)",
        description = "Memulihkan 60 MP",
        type = "consumable",
        subtype = "potion",
        price = 80,
        effect = {
            stat = "mp",
            value = 60,
        },
    },
    
    -- Weapons
    {
        id = "wooden_sword",
        name = "Wooden Sword",
        description = "Senjata kayu sederhana",
        type = "weapon",
        subtype = "sword",
        price = 100,
        stats = {
            atk = 5,
        },
        levelReq = 1,
    },
    {
        id = "iron_sword",
        name = "Iron Sword",
        description = "Senjata besi yang kuat",
        type = "weapon",
        subtype = "sword",
        price = 300,
        stats = {
            atk = 12,
        },
        levelReq = 5,
    },
    {
        id = "steel_sword",
        name = "Steel Sword",
        description = "Senjata baja terbaik",
        type = "weapon",
        subtype = "sword",
        price = 600,
        stats = {
            atk = 20,
        },
        levelReq = 10,
    },
    
    -- Armor
    {
        id = "leather_armor",
        name = "Leather Armor",
        description = "Armor kulit ringan",
        type = "armor",
        subtype = "body",
        price = 150,
        stats = {
            def = 5,
        },
        levelReq = 1,
    },
    {
        id = "iron_armor",
        name = "Iron Armor",
        description = "Armor besi yang kuat",
        type = "armor",
        subtype = "body",
        price = 400,
        stats = {
            def = 12,
        },
        levelReq = 5,
    },
    {
        id = "steel_armor",
        name = "Steel Armor",
        description = "Armor baja terbaik",
        type = "armor",
        subtype = "body",
        price = 800,
        stats = {
            def = 20,
        },
        levelReq = 10,
    },
    
    -- Accessories
    {
        id = "hp_ring",
        name = "HP Ring",
        description = "Cincin yang meningkatkan HP",
        type = "accessory",
        subtype = "ring",
        price = 200,
        stats = {
            hp = 20,
        },
        levelReq = 3,
    },
    {
        id = "atk_necklace",
        name = "ATK Necklace",
        description = "Kalung yang meningkatkan ATK",
        type = "accessory",
        subtype = "necklace",
        price = 250,
        stats = {
            atk = 5,
        },
        levelReq = 3,
    },
}

-- ============================================
-- SHOP DEFINITIONS (GDD)
-- ============================================

local SHOP_DATA = {
    {
        id = "general_shop",
        name = "Toko Umum",
        npcId = "Merchant",
        items = {
            "hp_potion_small",
            "hp_potion_medium",
            "mp_potion_small",
            "mp_potion_medium",
        },
    },
    {
        id = "weapon_shop",
        name = "Toko Senjata",
        npcId = "Blacksmith",
        items = {
            "wooden_sword",
            "iron_sword",
            "steel_sword",
        },
    },
    {
        id = "armor_shop",
        name = "Toko Armor",
        npcId = "Blacksmith",
        items = {
            "leather_armor",
            "iron_armor",
            "steel_armor",
        },
    },
    {
        id = "accessory_shop",
        name = "Toko Aksesoris",
        npcId = "Merchant",
        items = {
            "hp_ring",
            "atk_necklace",
        },
    },
}

-- ============================================
-- SHOP MANAGER
-- ============================================

local ShopManager = {}
ShopManager.__index = ShopManager

function ShopManager.new()
    local self = setmetatable({}, ShopManager)
    
    -- Player inventory data
    self.playerInventory = {}
    
    return self
end

function ShopManager:Init()
    -- Setup connections
    self:SetupPlayerConnections()
    self:SetupShopEvents()
    
    print("[Shop] Shop System initialized!")
end

function ShopManager:SetupPlayerConnections()
    -- Player join
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    -- Player leave
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
end

function ShopManager:OnPlayerAdded(player)
    -- Initialize player inventory
    self.playerInventory[player.UserId] = {}
    
    print("[Shop] Player inventory initialized: " .. player.Name)
end

function ShopManager:OnPlayerRemoving(player)
    -- Cleanup
    self.playerInventory[player.UserId] = nil
end

function ShopManager:SetupShopEvents()
    -- RemoteEvent untuk shop
    local shopEvent = Instance.new("RemoteEvent")
    shopEvent.Name = "ShopEvent"
    shopEvent.Parent = ReplicatedStorage:FindFirstChild("Events")
    
    -- Handle shop requests
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
    -- Find shop data
    local shopData = nil
    for _, shop in ipairs(SHOP_DATA) do
        if shop.id == shopId then
            shopData = shop
            break
        end
    end
    
    if not shopData then
        warn("[Shop] Shop not found: " .. shopId)
        return
    end
    
    -- Get shop items
    local shopItems = {}
    for _, itemId in ipairs(shopData.items) do
        for _, item in ipairs(ITEM_DATA) do
            if item.id == itemId then
                table.insert(shopItems, item)
                break
            end
        end
    end
    
    -- Send shop data to client
    local shopEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ShopEvent")
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
    -- Find item data
    local itemData = nil
    for _, item in ipairs(ITEM_DATA) do
        if item.id == itemId then
            itemData = item
            break
        end
    end
    
    if not itemData then
        warn("[Shop] Item not found: " .. itemId)
        return
    end
    
    -- Check gold
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if not playerStats then
        return
    end
    
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
    
    -- Add item to inventory
    local inventory = self.playerInventory[player.UserId]
    if inventory then
        -- Check if item already exists
        local existingItem = nil
        for _, invItem in ipairs(inventory) do
            if invItem.id == itemId then
                existingItem = invItem
                break
            end
        end
        
        if existingItem then
            existingItem.quantity = existingItem.quantity + quantity
        else
            table.insert(inventory, {
                id = itemData.id,
                name = itemData.name,
                quantity = quantity,
            })
        end
    end
    
    -- Send feedback
    local shopEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ShopEvent")
    if shopEvent then
        shopEvent:FireClient(player, {
            type = "ItemBought",
            itemId = itemId,
            quantity = quantity,
            totalPrice = totalPrice,
            remainingGold = playerStats.gold,
        })
    end
    
    print("[Shop] " .. player.Name .. " bought " .. quantity .. "x " .. itemData.name .. " for " .. totalPrice .. " gold")
end

function ShopManager:SellItem(player, itemId, quantity)
    -- Find item in inventory
    local inventory = self.playerInventory[player.UserId]
    if not inventory then
        return
    end
    
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
    
    -- Find item data for price
    local itemData = nil
    for _, item in ipairs(ITEM_DATA) do
        if item.id == itemId then
            itemData = item
            break
        end
    end
    
    if not itemData then
        return
    end
    
    -- Calculate sell price (50% of buy price)
    local sellPrice = math.floor(itemData.price * 0.5) * quantity
    
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
    local shopEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("ShopEvent")
    if shopEvent then
        shopEvent:FireClient(player, {
            type = "ItemSold",
            itemId = itemId,
            quantity = quantity,
            sellPrice = sellPrice,
            remainingGold = playerStats and playerStats.gold or 0,
        })
    end
    
    print("[Shop] " .. player.Name .. " sold " .. quantity .. "x " .. itemData.name .. " for " .. sellPrice .. " gold")
end

function ShopManager:GetPlayerInventory(player)
    return self.playerInventory[player.UserId]
end

-- ============================================
-- INITIALIZE
-- ============================================

-- Create Events folder if not exists
local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not eventsFolder then
    eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"
    eventsFolder.Parent = ReplicatedStorage
end

-- Initialize shop manager
local shopManager = ShopManager.new()
shopManager:Init()

-- Make accessible from other scripts
_G.ShopManager = shopManager

print("[Shop] Shop System ready!")
