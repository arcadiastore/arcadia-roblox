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

-- Load all data modules
GameData.Monsters = require(script:WaitForChild("Monsters"))
GameData.Items = require(script:WaitForChild("Items"))
GameData.Skills = require(script:WaitForChild("Skills"))
GameData.Quests = require(script:WaitForChild("Quests"))
GameData.NPCs = require(script:WaitForChild("NPCs"))
GameData.Shops = require(script:WaitForChild("Shops"))
GameData.Dialogues = require(script:WaitForChild("Dialogues"))
GameData.SpawnPositions = require(script:WaitForChild("SpawnPositions"))
GameData.Formulas = require(script:WaitForChild("Formulas"))

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
