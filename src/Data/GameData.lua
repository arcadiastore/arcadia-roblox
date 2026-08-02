--[[
    Arcadia Online - Game Data Module (MAIN ENTRY POINT)
    
    SINGLE SOURCE OF TRUTH
    
    Struktur Data:
    - Monsters.lua   → Data monster (HP, ATK, DEF, EXP, Gold)
    - Items.lua      → Data item (potion, equipment, dll)
    - Skills.lua     → Data skill (damage, cooldown, effect)
    - Quests.lua     → Data quest (objective, reward)
    - NPCs.lua       → Data NPC (posisi, fungsi)
    - Shops.lua      → Data shop (item yang dijual)
    - Dialogues.lua  → Data dialog NPC
    - SpawnPositions → Posisi spawn monster/NPC
    - Formulas.lua   → Rumus perhitungan game
    
    Cara pakai:
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    local slime = GameData:GetMonster("Slime")
]]

local GameData = {}

-- Helper function to safely require modules
local function safeRequire(parent, name)
    local success, result = pcall(function()
        return require(parent:WaitForChild(name, 5))
    end)
    if success then
        return result
    else
        warn("[GameData] Module not found: " .. name .. " - using empty table")
        return {}
    end
end

-- Load all data modules (with fallback)
GameData.Monsters = safeRequire(script, "Monsters")
GameData.Items = safeRequire(script, "Items")
GameData.Skills = safeRequire(script, "Skills")
GameData.Quests = safeRequire(script, "Quests")
GameData.NPCs = safeRequire(script, "NPCs")
GameData.Shops = safeRequire(script, "Shops")
GameData.Dialogues = safeRequire(script, "Dialogues")
GameData.SpawnPositions = safeRequire(script, "SpawnPositions")
GameData.Formulas = safeRequire(script, "Formulas")
GameData.Jobs = safeRequire(script, "Jobs")

-- ============================================
-- GETTER FUNCTIONS
-- ============================================

function GameData:GetMonster(id)
    return self.Monsters[id]
end

function GameData:GetItem(id)
    return self.Items[id]
end

function GameData:GetSkill(id)
    return self.Skills[id]
end

function GameData:GetQuest(id)
    return self.Quests[id]
end

function GameData:GetNPC(id)
    return self.NPCs[id]
end

function GameData:GetShop(id)
    return self.Shops[id]
end

function GameData:GetDialogue(npcId)
    return self.Dialogues[npcId]
end

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function GameData:GetShopItems(shopId)
    local shop = self.Shops[shopId]
    if not shop then return {} end
    
    local items = {}
    for _, itemId in ipairs(shop.items) do
        local item = self.Items[itemId]
        if item then
            table.insert(items, item)
        end
    end
    return items
end

function GameData:GetMonstersByArea(area)
    local monsters = {}
    for id, monster in pairs(self.Monsters) do
        if monster.spawnArea == area then
            table.insert(monsters, monster)
        end
    end
    return monsters
end

function GameData:GetSkillsByJob(job)
    local skills = {}
    for id, skill in pairs(self.Skills) do
        if skill.job == job or skill.job == nil then
            table.insert(skills, skill)
        end
    end
    return skills
end

function GameData:CalculateExpForLevel(level)
    return self.Formulas.expForLevel(level)
end

function GameData:CalculateDamage(atk, skillMultiplier, def)
    return self.Formulas.physicalDamage(atk, skillMultiplier, def)
end

function GameData:CalculateMagicDamage(matk, skillMultiplier, mdef)
    return self.Formulas.magicDamage(matk, skillMultiplier, mdef)
end

return GameData
