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
        level = 1,
        exp = 0,
        gold = 100,
        hp = 100,
        maxHp = 100,
        atk = 10,
        def = 5,
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
        level = data.level,
        exp = data.exp,
        gold = data.gold,
        hp = data.hp,
        maxHp = data.maxHp,
        atk = data.atk,
        def = data.def,
        activeQuests = data.activeQuests,
        completedQuests = data.completedQuests,
    })
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
        data.maxHp = data.maxHp + 10
        data.hp = data.maxHp
        data.atk = data.atk + 2
        data.def = data.def + 1
        expNeeded = GameData:CalculateExpForLevel(data.level + 1)
        leveled = true
        print("[PlayerData] " .. player.Name .. " level up! Lv." .. data.level)
    end
    
    if leveled then
        self:SendUpdate(player, events)
    end
    
    return leveled
end

return PlayerData
