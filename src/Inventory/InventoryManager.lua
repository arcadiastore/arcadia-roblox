--[[
    Arcadia Online - Inventory Manager
    
    Handles inventory system:
    - Item storage
    - Equipment management
    - Item usage
    - Trading
    
    @author arcadiastore
    @version 1.0.0
]]

local InventoryManager = {}
InventoryManager.__index = InventoryManager

-- Item types
local ItemType = {
    CONSUMABLE = "Consumable",
    EQUIPMENT = "Equipment",
    MATERIAL = "Material",
    QUEST = "Quest",
}

-- Equipment slots
local EquipSlot = {
    HEAD = "Head",
    BODY = "Body",
    HANDS = "Hands",
    FEET = "Feet",
    MAIN_HAND = "MainHand",
    OFF_HAND = "OffHand",
    NECKLACE = "Necklace",
    RING_1 = "Ring1",
    RING_2 = "Ring2",
    EARRING_1 = "Earring1",
    EARRING_2 = "Earring2",
}

-- Item definitions
local ItemDatabase = {
    -- Weapons
    sword_wooden = {
        id = "sword_wooden",
        name = "Pedang Kayu",
        description = "Pedang sederhana untuk pemula.",
        type = ItemType.EQUIPMENT,
        slot = EquipSlot.MAIN_HAND,
        rarity = "Common",
        stats = { atk = 5 },
        stackable = false,
        maxStack = 1,
    },
    sword_iron = {
        id = "sword_iron",
        name = "Pedang Besi",
        description = "Pedang besi yang kuat.",
        type = ItemType.EQUIPMENT,
        slot = EquipSlot.MAIN_HAND,
        rarity = "Uncommon",
        stats = { atk = 15 },
        stackable = false,
        maxStack = 1,
    },
    
    -- Armor
    armor_leather = {
        id = "armor_leather",
        name = "Armor Kulit",
        description = "Armor ringan dari kulit.",
        type = ItemType.EQUIPMENT,
        slot = EquipSlot.BODY,
        rarity = "Common",
        stats = { def = 5, maxHp = 20 },
        stackable = false,
        maxStack = 1,
    },
    armor_iron = {
        id = "armor_iron",
        name = "Armor Besi",
        description = "Armor berat dari besi.",
        type = ItemType.EQUIPMENT,
        slot = EquipSlot.BODY,
        rarity = "Uncommon",
        stats = { def = 15, maxHp = 50 },
        stackable = false,
        maxStack = 1,
    },
    
    -- Accessories
    ring_power = {
        id = "ring_power",
        name = "Cincin Kekuatan",
        description = "Cincin yang meningkatkan kekuatan.",
        type = ItemType.EQUIPMENT,
        slot = EquipSlot.RING_1,
        rarity = "Uncommon",
        stats = { atk = 5, STR = 2 },
        stackable = false,
        maxStack = 1,
    },
    
    -- Consumables
    potion_hp_small = {
        id = "potion_hp_small",
        name = "Ramuan HP Kecil",
        description = "Memulihkan 50 HP.",
        type = ItemType.CONSUMABLE,
        rarity = "Common",
        stackable = true,
        maxStack = 99,
        effect = { hp = 50 },
    },
    potion_hp_large = {
        id = "potion_hp_large",
        name = "Ramuan HP Besar",
        description = "Memulihkan 150 HP.",
        type = ItemType.CONSUMABLE,
        rarity = "Uncommon",
        stackable = true,
        maxStack = 99,
        effect = { hp = 150 },
    },
    potion_mp_small = {
        id = "potion_mp_small",
        name = "Ramuan MP Kecil",
        description = "Memulihkan 30 MP.",
        type = ItemType.CONSUMABLE,
        rarity = "Common",
        stackable = true,
        maxStack = 99,
        effect = { mp = 30 },
    },
    
    -- Materials
    herb = {
        id = "herb",
        name = "Herba",
        description = "Herba untuk membuat obat.",
        type = ItemType.MATERIAL,
        rarity = "Common",
        stackable = true,
        maxStack = 99,
    },
    slime_gel = {
        id = "slime_gel",
        name = "Gel Slime",
        description = "Gel lengket dari slime.",
        type = ItemType.MATERIAL,
        rarity = "Common",
        stackable = true,
        maxStack = 99,
    },
    wolf_fang = {
        id = "wolf_fang",
        name = "Taring Serigala",
        description = "Taring tajam dari serigala.",
        type = ItemType.MATERIAL,
        rarity = "Common",
        stackable = true,
        maxStack = 99,
    },
}

function InventoryManager.new()
    local self = setmetatable({}, InventoryManager)
    
    self.inventories = {}  -- Player inventories
    self.maxSlots = 30
    
    return self
end

-- Get item definition
function InventoryManager:GetItemDef(itemId)
    return ItemDatabase[itemId]
end

-- Initialize inventory for player
function InventoryManager:InitInventory(playerId)
    self.inventories[playerId] = {
        items = {},  -- {itemId, amount}
        equipment = {},  -- {slot = itemId}
        gold = 0,
    }
end

-- Add item to inventory
function InventoryManager:AddItem(playerId, itemId, amount)
    amount = amount or 1
    
    local inventory = self.inventories[playerId]
    if not inventory then
        self:InitInventory(playerId)
        inventory = self.inventories[playerId]
    end
    
    local itemDef = self:GetItemDef(itemId)
    if not itemDef then
        return false, "Item not found"
    end
    
    -- Check if item is stackable
    if itemDef.stackable then
        -- Find existing stack
        for _, item in ipairs(inventory.items) do
            if item.itemId == itemId then
                local space = itemDef.maxStack - item.amount
                local toAdd = math.min(amount, space)
                item.amount = item.amount + toAdd
                
                if amount > toAdd then
                    -- Need new stack
                    return self:AddItem(playerId, itemId, amount - toAdd)
                end
                
                return true, "Added " .. toAdd .. "x " .. itemDef.name
            end
        end
    end
    
    -- Check if inventory is full
    if #inventory.items >= self.maxSlots then
        return false, "Inventory full"
    end
    
    -- Add new item
    table.insert(inventory.items, {
        itemId = itemId,
        amount = math.min(amount, itemDef.maxStack),
    })
    
    return true, "Added " .. amount .. "x " .. itemDef.name
end

-- Remove item from inventory
function InventoryManager:RemoveItem(playerId, itemId, amount)
    amount = amount or 1
    
    local inventory = self.inventories[playerId]
    if not inventory then
        return false, "No inventory"
    end
    
    -- Find item
    for i, item in ipairs(inventory.items) do
        if item.itemId == itemId then
            if item.amount >= amount then
                item.amount = item.amount - amount
                
                -- Remove if empty
                if item.amount <= 0 then
                    table.remove(inventory.items, i)
                end
                
                return true, "Removed " .. amount .. "x " .. itemId
            else
                return false, "Not enough items"
            end
        end
    end
    
    return false, "Item not found"
end

-- Check if player has item
function InventoryManager:HasItem(playerId, itemId, amount)
    amount = amount or 1
    
    local inventory = self.inventories[playerId]
    if not inventory then
        return false
    end
    
    local total = 0
    for _, item in ipairs(inventory.items) do
        if item.itemId == itemId then
            total = total + item.amount
        end
    end
    
    return total >= amount
end

-- Get item count
function InventoryManager:GetItemCount(playerId, itemId)
    local inventory = self.inventories[playerId]
    if not inventory then
        return 0
    end
    
    local total = 0
    for _, item in ipairs(inventory.items) do
        if item.itemId == itemId then
            total = total + item.amount
        end
    end
    
    return total
end

-- Use consumable item
function InventoryManager:UseItem(playerId, itemId)
    local inventory = self.inventories[playerId]
    if not inventory then
        return false, "No inventory"
    end
    
    local itemDef = self:GetItemDef(itemId)
    if not itemDef then
        return false, "Item not found"
    end
    
    if itemDef.type ~= ItemType.CONSUMABLE then
        return false, "Cannot use this item"
    end
    
    -- Check if has item
    if not self:HasItem(playerId, itemId, 1) then
        return false, "Don't have this item"
    end
    
    -- Remove item
    self:RemoveItem(playerId, itemId, 1)
    
    -- Return effect
    return true, itemDef.effect
end

-- Equip item
function InventoryManager:EquipItem(playerId, itemId)
    local inventory = self.inventories[playerId]
    if not inventory then
        return false, "No inventory"
    end
    
    local itemDef = self:GetItemDef(itemId)
    if not itemDef then
        return false, "Item not found"
    end
    
    if itemDef.type ~= ItemType.EQUIPMENT then
        return false, "Not equipment"
    end
    
    -- Check if has item
    if not self:HasItem(playerId, itemId, 1) then
        return false, "Don't have this item"
    end
    
    local slot = itemDef.slot
    
    -- Unequip current item in slot
    if inventory.equipment[slot] then
        self:UnequipItem(playerId, slot)
    end
    
    -- Remove from inventory
    self:RemoveItem(playerId, itemId, 1)
    
    -- Equip
    inventory.equipment[slot] = itemId
    
    return true, "Equipped " .. itemDef.name
end

-- Unequip item
function InventoryManager:UnequipItem(playerId, slot)
    local inventory = self.inventories[playerId]
    if not inventory then
        return false, "No inventory"
    end
    
    local itemId = inventory.equipment[slot]
    if not itemId then
        return false, "Nothing equipped in slot"
    end
    
    -- Add to inventory
    local success = self:AddItem(playerId, itemId, 1)
    if not success then
        return false, "Inventory full"
    end
    
    -- Remove from equipment
    inventory.equipment[slot] = nil
    
    return true, "Unequipped " .. itemId
end

-- Get equipped item stats
function InventoryManager:GetEquipmentStats(playerId)
    local inventory = self.inventories[playerId]
    if not inventory then
        return {}
    end
    
    local totalStats = {}
    
    for slot, itemId in pairs(inventory.equipment) do
        local itemDef = self:GetItemDef(itemId)
        if itemDef and itemDef.stats then
            for stat, value in pairs(itemDef.stats) do
                totalStats[stat] = (totalStats[stat] or 0) + value
            end
        end
    end
    
    return totalStats
end

-- Add gold
function InventoryManager:AddGold(playerId, amount)
    local inventory = self.inventories[playerId]
    if inventory then
        inventory.gold = inventory.gold + amount
        return true
    end
    return false
end

-- Remove gold
function InventoryManager:RemoveGold(playerId, amount)
    local inventory = self.inventories[playerId]
    if inventory and inventory.gold >= amount then
        inventory.gold = inventory.gold - amount
        return true
    end
    return false
end

-- Get gold
function InventoryManager:GetGold(playerId)
    local inventory = self.inventories[playerId]
    return inventory and inventory.gold or 0
end

-- Get inventory contents
function InventoryManager:GetInventory(playerId)
    return self.inventories[playerId]
end

-- Serialize for saving
function InventoryManager:Serialize(playerId)
    return self.inventories[playerId] or {}
end

-- Deserialize from saved data
function InventoryManager:Deserialize(playerId, data)
    if data then
        self.inventories[playerId] = data
    end
end

return InventoryManager.new()
