--[[
    PlayerData.lua
    Manages player data (stats, inventory, quests)
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local PlayerData = {}

-- Player data storage
local playerDataStore = {}

-- Default player data
function PlayerData:GetDefault()
    return {
        job = nil,
        level = 1,
        exp = 0,
        gold = 100,
        hp = 100,
        maxHp = 100,
        mp = 50,
        maxMp = 50,
        atk = 10,
        def = 5,
        matk = 5,
        mdef = 5,
        spd = 10,
        luk = 5,
        skillPoints = 0,
        learnedSkills = {},
        inventory = {
            {itemId = "hp_potion_small", count = 5},
        },
        equipment = {
            hat = nil,
            tshirt = nil,
            pants = nil,
            shoes = nil,
            ringLeft = nil,
            ringRight = nil,
            necklace = nil,
            weapon1h = nil,
            weapon2h = nil,
            wings = nil,
            costume = nil,
        },
        activeQuests = {},
        completedQuests = {},
    }
end

-- Initialize player
function PlayerData:Init(player)
    playerDataStore[player.UserId] = self:GetDefault()
    print("[PlayerData] " .. player.Name .. " initialized")
    return playerDataStore[player.UserId]
end

-- Get player data
function PlayerData:Get(player)
    return playerDataStore[player.UserId]
end

-- Remove player data (on leave)
function PlayerData:Remove(player)
    playerDataStore[player.UserId] = nil
    print("[PlayerData] " .. player.Name .. " removed")
end

-- Send update to client
function PlayerData:SendUpdate(player, events)
    local data = playerDataStore[player.UserId]
    if not data then return end
    
    local expNeeded = GameData:CalculateExpForLevel(data.level + 1)
    
    events.UpdateEvent:FireClient(player, {
        type = "Update",
        job = data.job,
        level = data.level,
        exp = data.exp,
        expNeeded = expNeeded,
        gold = data.gold,
        hp = data.hp,
        maxHp = data.maxHp,
        mp = data.mp or 50,
        maxMp = data.maxMp or 50,
        atk = data.atk,
        def = data.def,
        matk = data.matk or 5,
        mdef = data.mdef or 5,
        spd = data.spd or 10,
        luk = data.luk or 5,
        inventory = data.inventory,
        equipment = data.equipment,
        activeQuests = data.activeQuests,
        completedQuests = data.completedQuests,
    })
end

-- Update max stats based on level, job, and equipment
function PlayerData:UpdateMaxStats(player)
    local data = self:Get(player)
    if not data then return end
    
    -- Base stats (no job)
    local baseHp = 100
    local baseMp = 50
    local baseAtk = 10
    local baseDef = 5
    local baseMatk = 5
    local baseMdef = 5
    local baseSpd = 10
    local baseLuk = 5
    
    -- Add job modifiers
    if data.job then
        local jobData = GameData.Jobs and GameData.Jobs[data.job]
        if jobData then
            baseHp = baseHp + (jobData.stats.hp or 0)
            baseMp = baseMp + (jobData.stats.mp or 0)
            baseAtk = baseAtk + (jobData.stats.atk or 0)
            baseDef = baseDef + (jobData.stats.def or 0)
            baseMatk = baseMatk + (jobData.stats.matk or 0)
            baseMdef = baseMdef + (jobData.stats.mdef or 0)
            baseSpd = baseSpd + (jobData.stats.spd or 0)
            baseLuk = baseLuk + (jobData.stats.luk or 0)
            
            -- Growth per level (level 1 = no growth)
            local levels = data.level - 1
            baseHp = baseHp + (jobData.growth.hp or 0) * levels
            baseMp = baseMp + (jobData.growth.mp or 0) * levels
            baseAtk = baseAtk + (jobData.growth.atk or 0) * levels
            baseDef = baseDef + (jobData.growth.def or 0) * levels
            baseMatk = baseMatk + (jobData.growth.matk or 0) * levels
            baseMdef = baseMdef + (jobData.growth.mdef or 0) * levels
            baseSpd = baseSpd + (jobData.growth.spd or 0) * levels
            baseLuk = baseLuk + (jobData.growth.luk or 0) * levels
        end
    else
        -- No job: basic level scaling
        baseHp = baseHp + (data.level - 1) * 10
        baseMp = baseMp + (data.level - 1) * 3
        baseAtk = baseAtk + (data.level - 1) * 2
        baseDef = baseDef + (data.level - 1) * 1
    end
    
    -- Add equipment bonuses
    if data.equipment then
        for slot, itemId in pairs(data.equipment) do
            if itemId then
                local itemData = GameData.Items and GameData.Items[itemId]
                if itemData and itemData.stats then
                    for stat, value in pairs(itemData.stats) do
                        if stat == "atk" then baseAtk = baseAtk + value
                        elseif stat == "def" then baseDef = baseDef + value
                        elseif stat == "matk" then baseMatk = baseMatk + value
                        elseif stat == "mdef" then baseMdef = baseMdef + value
                        elseif stat == "spd" then baseSpd = baseSpd + value
                        elseif stat == "hp" then baseHp = baseHp + value
                        elseif stat == "mp" then baseMp = baseMp + value
                        end
                    end
                end
            end
        end
    end
    
    data.maxHp = baseHp
    data.maxMp = baseMp
    data.atk = baseAtk
    data.def = baseDef
    data.matk = baseMatk
    data.mdef = baseMdef
    data.spd = baseSpd
    data.luk = baseLuk
    
    -- Clamp current HP/MP
    if data.hp > data.maxHp then data.hp = data.maxHp end
    if data.mp and data.mp > data.maxMp then data.mp = data.maxMp end
end

-- Check level up
function PlayerData:CheckLevelUp(player, events)
    local data = playerDataStore[player.UserId]
    if not data then return false end
    
    local leveled = false
    local expNeeded = GameData:CalculateExpForLevel(data.level + 1)
    
    while data.exp >= expNeeded do
        data.exp = data.exp - expNeeded
        data.level = data.level + 1
        leveled = true
        
        -- Recalculate all stats with job growth
        self:UpdateMaxStats(player)
        data.hp = data.maxHp  -- Full heal on level up
        data.mp = data.maxMp  -- Full MP on level up
        
        expNeeded = GameData:CalculateExpForLevel(data.level + 1)
        print("[PlayerData] " .. player.Name .. " level up! Lv." .. data.level)
    end
    
    if leveled then
        self:SendUpdate(player, events)
    end
    
    return leveled
end

-- Set player job
function PlayerData:SetJob(player, jobId, events)
    local data = self:Get(player)
    if not data then return false, "Player data not found" end
    
    -- Validate job exists
    if not GameData.Jobs or not GameData.Jobs[jobId] then
        return false, "Job tidak ditemukan!"
    end
    
    -- Set job
    data.job = jobId
    
    -- Recalculate stats
    self:UpdateMaxStats(player)
    data.hp = data.maxHp
    data.mp = data.maxMp
    
    -- Check level up (player might have enough EXP)
    self:CheckLevelUp(player, events)
    
    -- Send update
    self:SendUpdate(player, events)
    
    print("[PlayerData] " .. player.Name .. " selected job: " .. jobId)
    return true, "Job berhasil dipilih: " .. jobId
end

-- ============================================
-- INVENTORY MANAGEMENT
-- ============================================

-- Add item to inventory
function PlayerData:AddItem(player, itemId, count, events)
    local data = self:Get(player)
    if not data then return false end
    
    count = count or 1
    local itemData = GameData.Items and GameData.Items[itemId]
    if not itemData then return false end
    
    -- Find existing stack
    local maxStack = itemData.maxStack or 99
    for _, slot in ipairs(data.inventory) do
        if slot.itemId == itemId and slot.count < maxStack then
            local canAdd = math.min(count, maxStack - slot.count)
            slot.count = slot.count + canAdd
            count = count - canAdd
            if count <= 0 then
                self:SendUpdate(player, events)
                return true
            end
        end
    end
    
    -- Create new slot(s)
    while count > 0 do
        local stackSize = math.min(count, maxStack)
        table.insert(data.inventory, {itemId = itemId, count = stackSize})
        count = count - stackSize
    end
    
    self:SendUpdate(player, events)
    return true
end

-- Remove item from inventory
function PlayerData:RemoveItem(player, itemId, count, events)
    local data = self:Get(player)
    if not data then return false end
    
    count = count or 1
    
    -- Check if enough
    local total = self:GetItemCount(player, itemId)
    if total < count then return false end
    
    -- Remove from end
    for i = #data.inventory, 1, -1 do
        local slot = data.inventory[i]
        if slot.itemId == itemId then
            local canRemove = math.min(count, slot.count)
            slot.count = slot.count - canRemove
            count = count - canRemove
            if slot.count <= 0 then
                table.remove(data.inventory, i)
            end
            if count <= 0 then break end
        end
    end
    
    self:SendUpdate(player, events)
    return true
end

-- Get total count of item
function PlayerData:GetItemCount(player, itemId)
    local data = self:Get(player)
    if not data then return 0 end
    
    local total = 0
    for _, slot in ipairs(data.inventory) do
        if slot.itemId == itemId then
            total = total + slot.count
        end
    end
    return total
end

-- Check if player has item
function PlayerData:HasItem(player, itemId, count)
    return self:GetItemCount(player, itemId) >= (count or 1)
end

-- ============================================
-- EQUIPMENT MANAGEMENT
-- ============================================

-- Get equipment slot for item
local function getEquipSlot(itemData)
    if not itemData or itemData.type ~= "equipment" then return nil end
    local slot = itemData.slot
    if slot == "weapon1h" then return "weapon1h"
    elseif slot == "weapon2h" then return "weapon2h"
    elseif slot == "hat" then return "hat"
    elseif slot == "tshirt" then return "tshirt"
    elseif slot == "pants" then return "pants"
    elseif slot == "shoes" then return "shoes"
    elseif slot == "ring" then return "ringLeft"  -- default to left
    elseif slot == "necklace" then return "necklace"
    elseif slot == "wings" then return "wings"
    elseif slot == "costume" then return "costume"
    end
    return nil
end

-- Equip item
function PlayerData:EquipItem(player, itemId, targetSlot, events)
    local data = self:Get(player)
    if not data then return false, "Player data not found" end
    
    local itemData = GameData.Items and GameData.Items[itemId]
    if not itemData then return false, "Item tidak ditemukan!" end
    if itemData.type ~= "equipment" then return false, "Item bukan equipment!" end
    
    -- Check level requirement
    if itemData.levelReq and data.level < itemData.levelReq then
        return false, "Level kurang! Butuh Lv." .. itemData.levelReq
    end
    
    -- Check job requirement
    if itemData.jobReq and data.job then
        local allowed = false
        for _, job in ipairs(itemData.jobReq) do
            if job == data.job then allowed = true break end
        end
        if not allowed then
            return false, "Job " .. data.job .. " tidak bisa pakai item ini!"
        end
    end
    
    -- Determine equipment slot
    local equipSlot = targetSlot or getEquipSlot(itemData)
    if not equipSlot then return false, "Slot equipment tidak valid!" end
    
    -- Handle ring slots
    if itemData.slot == "ring" then
        if targetSlot == "ringRight" then
            equipSlot = "ringRight"
        else
            -- Auto: prefer empty slot, then left
            if not data.equipment.ringLeft then
                equipSlot = "ringLeft"
            elseif not data.equipment.ringRight then
                equipSlot = "ringRight"
            else
                equipSlot = targetSlot or "ringLeft"
            end
        end
    end
    
    -- Handle 1h/2h weapon conflict
    if equipSlot == "weapon2h" then
        -- Unequip weapon1h if exists
        if data.equipment.weapon1h then
            self:AddItem(player, data.equipment.weapon1h, 1, nil)
            data.equipment.weapon1h = nil
        end
    elseif equipSlot == "weapon1h" then
        -- Unequip weapon2h if exists
        if data.equipment.weapon2h then
            self:AddItem(player, data.equipment.weapon2h, 1, nil)
            data.equipment.weapon2h = nil
        end
    end
    
    -- Unequip current item in slot
    local currentItem = data.equipment[equipSlot]
    if currentItem then
        self:AddItem(player, currentItem, 1, nil)
    end
    
    -- Remove new item from inventory and equip
    if not self:RemoveItem(player, itemId, 1, nil) then
        return false, "Item tidak ada di inventory!"
    end
    
    data.equipment[equipSlot] = itemId
    
    -- Recalculate stats
    self:UpdateMaxStats(player)
    self:SendUpdate(player, events)
    
    print("[PlayerData] " .. player.Name .. " equipped " .. itemId .. " to " .. equipSlot)
    return true, "Berhasil equip " .. itemData.name .. "!"
end

-- Unequip item
function PlayerData:UnequipItem(player, slot, events)
    local data = self:Get(player)
    if not data then return false, "Player data not found" end
    
    local itemId = data.equipment[slot]
    if not itemId then return false, "Tidak ada item di slot " .. slot end
    
    -- Add back to inventory
    self:AddItem(player, itemId, 1, nil)
    data.equipment[slot] = nil
    
    -- Recalculate stats
    self:UpdateMaxStats(player)
    self:SendUpdate(player, events)
    
    print("[PlayerData] " .. player.Name .. " unequipped " .. itemId .. " from " .. slot)
    return true, "Berhasil unequip!"
end

return PlayerData
