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
        job = nil,  -- Not selected yet
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
            hp_potion_small = 5,
        },
        equipment = {
            weapon = nil,
            armor = nil,
            accessory = nil,
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
    
    events.UpdateEvent:FireClient(player, {
        type = "Update",
        job = data.job,
        level = data.level,
        exp = data.exp,
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

return PlayerData
