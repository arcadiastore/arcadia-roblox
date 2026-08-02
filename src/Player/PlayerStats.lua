--[[
    Arcadia Online - Player Stats
    
    Handles player statistics:
    - Base stats (STR, AGI, INT, VIT, DEX, LUK)
    - Derived stats (HP, MP, ATK, DEF, etc.)
    - Level up system
    - Job class bonuses
    
    @author arcadiastore
    @version 1.0.0
]]

local PlayerStats = {}
PlayerStats.__index = PlayerStats

-- Base stats for each job class
local JobBaseStats = {
    Warrior = {
        STR = 8, AGI = 5, INT = 2, VIT = 6, DEX = 4, LUK = 3,
        maxHp = 120, maxMp = 30, atk = 15, def = 10, spd = 4,
    },
    Knight = {
        STR = 6, AGI = 3, INT = 2, VIT = 9, DEX = 3, LUK = 2,
        maxHp = 150, maxMp = 20, atk = 10, def = 18, spd = 3,
    },
    Mage = {
        STR = 2, AGI = 4, INT = 9, VIT = 3, DEX = 5, LUK = 4,
        maxHp = 70, maxMp = 120, atk = 5, def = 5, spd = 4,
    },
    Archer = {
        STR = 4, AGI = 7, INT = 3, VIT = 4, DEX = 9, LUK = 5,
        maxHp = 80, maxMp = 50, atk = 12, def = 6, spd = 6,
    },
    Cleric = {
        STR = 3, AGI = 3, INT = 7, VIT = 6, DEX = 4, LUK = 5,
        maxHp = 90, maxMp = 100, atk = 8, def = 8, spd = 3,
    },
    Jester = {
        STR = 5, AGI = 8, INT = 3, VIT = 3, DEX = 6, LUK = 8,
        maxHp = 75, maxMp = 40, atk = 10, def = 5, spd = 8,
    },
    Craftsman = {
        STR = 5, AGI = 4, INT = 5, VIT = 5, DEX = 7, LUK = 6,
        maxHp = 85, maxMp = 60, atk = 11, def = 7, spd = 4,
    },
}

-- Growth rates per level for each job
local JobGrowthRates = {
    Warrior = { hp = 12, mp = 3, atk = 2, def = 1.5, spd = 0.5 },
    Knight = { hp = 15, mp = 2, atk = 1, def = 2.5, spd = 0.3 },
    Mage = { hp = 6, mp = 12, atk = 0.5, def = 0.5, spd = 0.5 },
    Archer = { hp = 8, mp = 5, atk = 1.5, def = 0.8, spd = 1 },
    Cleric = { hp = 9, mp = 10, atk = 0.8, def = 1, spd = 0.3 },
    Jester = { hp = 7, mp = 4, atk = 1.2, def = 0.5, spd = 1.2 },
    Craftsman = { hp = 8, mp = 6, atk = 1.3, def = 1, spd = 0.5 },
}

-- EXP required for each level
local function GetExpForLevel(level)
    return math.floor(100 * level * (1 + level * 0.1))
end

function PlayerStats.new(jobClass)
    local self = setmetatable({}, PlayerStats)
    
    self.job = jobClass or "Warrior"
    self.level = 1
    self.exp = 0
    self.expToLevel = GetExpForLevel(1)
    
    -- Base stats
    self.baseStats = {}
    self.bonusStats = {}
    self.equipmentStats = {}
    
    -- Initialize base stats from job
    self:InitBaseStats()
    
    return self
end

-- Initialize base stats from job class
function PlayerStats:InitBaseStats()
    local jobStats = JobBaseStats[self.job]
    if jobStats then
        for stat, value in pairs(jobStats) do
            self.baseStats[stat] = value
        end
    end
    
    -- Initialize bonus and equipment stats
    self.bonusStats = {
        STR = 0, AGI = 0, INT = 0, VIT = 0, DEX = 0, LUK = 0,
        maxHp = 0, maxMp = 0, atk = 0, def = 0, spd = 0,
    }
    
    self.equipmentStats = {
        STR = 0, AGI = 0, INT = 0, VIT = 0, DEX = 0, LUK = 0,
        maxHp = 0, maxMp = 0, atk = 0, def = 0, spd = 0,
    }
end

-- Get total stat (base + bonus + equipment)
function PlayerStats:GetStat(statName)
    local base = self.baseStats[statName] or 0
    local bonus = self.bonusStats[statName] or 0
    local equip = self.equipmentStats[statName] or 0
    return base + bonus + equip
end

-- Get all stats
function PlayerStats:GetAllStats()
    local stats = {}
    local allStatNames = {"STR", "AGI", "INT", "VIT", "DEX", "LUK", 
                          "maxHp", "maxMp", "atk", "def", "spd"}
    
    for _, statName in ipairs(allStatNames) do
        stats[statName] = self:GetStat(statName)
    end
    
    return stats
end

-- Add EXP and check for level up
function PlayerStats:AddExp(amount)
    self.exp = self.exp + amount
    
    local levelsGained = 0
    while self.exp >= self.expToLevel and self.level < 100 do
        self.exp = self.exp - self.expToLevel
        self.level = self.level + 1
        self.expToLevel = GetExpForLevel(self.level)
        
        -- Apply level up growth
        self:ApplyLevelUpGrowth()
        
        levelsGained = levelsGained + 1
    end
    
    return levelsGained
end

-- Apply growth from level up
function PlayerStats:ApplyLevelUpGrowth()
    local growth = JobGrowthRates[self.job]
    if growth then
        self.baseStats.maxHp = self.baseStats.maxHp + growth.hp
        self.baseStats.maxMp = self.baseStats.maxMp + growth.mp
        self.baseStats.atk = self.baseStats.atk + growth.atk
        self.baseStats.def = self.baseStats.def + growth.def
        self.baseStats.spd = self.baseStats.spd + growth.spd
    end
end

-- Add bonus stats (from buffs, etc.)
function PlayerStats:AddBonusStats(stats)
    for stat, value in pairs(stats) do
        self.bonusStats[stat] = (self.bonusStats[stat] or 0) + value
    end
end

-- Set equipment stats
function PlayerStats:SetEquipmentStats(stats)
    self.equipmentStats = stats
end

-- Calculate damage
function PlayerStats:CalculateDamage()
    local atk = self:GetStat("atk")
    local str = self:GetStat("STR")
    local dex = self:GetStat("DEX")
    
    -- Damage formula: ATK + STR * 1.5 + DEX * 0.5
    return math.floor(atk + str * 1.5 + dex * 0.5)
end

-- Calculate defense
function PlayerStats:CalculateDefense()
    local def = self:GetStat("def")
    local vit = self:GetStat("VIT")
    
    -- Defense formula: DEF + VIT * 1.2
    return math.floor(def + vit * 1.2)
end

-- Calculate critical rate (percentage)
function PlayerStats:CalculateCritRate()
    local luk = self:GetStat("LUK")
    local dex = self:GetStat("DEX")
    
    -- Crit rate: (LUK * 0.5 + DEX * 0.3)%
    return math.min(50, luk * 0.5 + dex * 0.3)
end

-- Calculate critical damage multiplier
function PlayerStats:CalculateCritDamage()
    local luk = self:GetStat("LUK")
    
    -- Crit damage: 150% + LUK * 0.5%
    return 1.5 + luk * 0.005
end

-- Calculate dodge rate (percentage)
function PlayerStats:CalculateDodgeRate()
    local agi = self:GetStat("AGI")
    local luk = self:GetStat("LUK")
    
    -- Dodge rate: (AGI * 0.5 + LUK * 0.2)%
    return math.min(30, agi * 0.5 + luk * 0.2)
end

-- Serialize for saving
function PlayerStats:Serialize()
    return {
        job = self.job,
        level = self.level,
        exp = self.exp,
        baseStats = self.baseStats,
        bonusStats = self.bonusStats,
    }
end

-- Deserialize from saved data
function PlayerStats:Deserialize(data)
    if data then
        self.job = data.job or "Warrior"
        self.level = data.level or 1
        self.exp = data.exp or 0
        self.expToLevel = GetExpForLevel(self.level)
        
        if data.baseStats then
            for stat, value in pairs(data.baseStats) do
                self.baseStats[stat] = value
            end
        end
        
        if data.bonusStats then
            for stat, value in pairs(data.bonusStats) do
                self.bonusStats[stat] = value
            end
        end
    end
end

return PlayerStats
