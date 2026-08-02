--[[
    Arcadia Online - Game Data Module (MAIN ENTRY POINT)
    
    SINGLE SOURCE OF TRUTH - Tapi data dipisah per modul!
    
    Struktur:
    📁 ReplicatedStorage
       └── 📦 GameData (ModuleScript)
           ├── 📦 Monsters
           ├── 📦 Items
           ├── 📦 Quests
           ├── 📦 NPCs
           ├── 📦 Shops
           ├── 📦 Jobs
           ├── 📦 Skills
           ├── 📦 Dialogues
           ├── 📦 SpawnPositions
           └── 📦 Formulas
    
    CARA PAKAI:
    local GameData = require(ReplicatedStorage.GameData)
    
    -- Access monster data
    local slime = GameData.Monsters["Slime"]
    
    -- Access job data
    local warrior = GameData.Jobs["Warrior"]
    
    -- Use formulas
    local damage = GameData.Formulas.physicalDamage(15, 1.5, 3)
    
    @author arcadiastore
    @version 4.0.0 - Modular Architecture
]]

local GameData = {}

-- ============================================
-- LOAD ALL DATA MODULES
-- ============================================

-- Di Roblox, ini akan jadi path ke ModuleScript
-- Contoh: require(script.Parent:WaitForChild("Monsters"))
-- Tapi untuk development, kita load dari file yang sama

-- Monster Data (GDD: 11_Monsters.md)
GameData.Monsters = require(script:WaitForChild("Monsters"))

-- Item Data (GDD: 09_Items.md)
GameData.Items = require(script:WaitForChild("Items"))

-- Quest Data (GDD: 14_Quest.md)
GameData.Quests = require(script:WaitForChild("Quests"))

-- NPC Data (GDD: 13_NPC.md)
GameData.NPCs = require(script:WaitForChild("NPCs"))

-- Shop Data
GameData.Shops = require(script:WaitForChild("Shops"))

-- Job Data (GDD: 06_Jobs.md)
GameData.Jobs = require(script:WaitForChild("Jobs"))

-- Skill Data (GDD: 07_Skills.md)
GameData.Skills = require(script:WaitForChild("Skills"))

-- Dialogue Data (GDD: 15_Dialogue.md)
GameData.Dialogues = require(script:WaitForChild("Dialogues"))

-- Spawn Positions
GameData.SpawnPositions = require(script:WaitForChild("SpawnPositions"))

-- Game Formulas (GDD: 08_Stats.md)
GameData.Formulas = require(script:WaitForChild("Formulas"))

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Get monster by ID
function GameData:GetMonster(id)
    return self.Monsters[id]
end

-- Get item by ID
function GameData:GetItem(id)
    return self.Items[id]
end

-- Get quest by ID
function GameData:GetQuest(id)
    return self.Quests[id]
end

-- Get NPC by ID
function GameData:GetNPC(id)
    return self.NPCs[id]
end

-- Get shop by ID
function GameData:GetShop(id)
    return self.Shops[id]
end

-- Get dialogue by NPC ID
function GameData:GetDialogue(npcId)
    return self.Dialogues[npcId]
end

-- Get job by ID
function GameData:GetJob(id)
    return self.Jobs[id]
end

-- Get skill by ID
function GameData:GetSkill(id)
    return self.Skills[id]
end

-- Get all starter jobs (Tier 1)
function GameData:GetStarterJobs()
    local starter = {}
    for id, job in pairs(self.Jobs) do
        if job.tier == 1 then
            table.insert(starter, job)
        end
    end
    return starter
end

-- Get job advancements for parent job
function GameData:GetJobAdvancements(parentJobId)
    local advancements = {}
    for id, job in pairs(self.Jobs) do
        if job.parentJob == parentJobId then
            table.insert(advancements, job)
        end
    end
    return advancements
end

-- Get skills for job
function GameData:GetJobSkills(jobId)
    local skills = {}
    for id, skill in pairs(self.Skills) do
        if skill.job == jobId then
            table.insert(skills, skill)
        end
    end
    table.sort(skills, function(a, b) return a.tier < b.tier end)
    return skills
end

-- Get player available skills based on job and level
function GameData:GetPlayerSkills(jobId, level)
    local skills = {}
    for id, skill in pairs(self.Skills) do
        if skill.job == jobId and skill.levelReq <= level then
            table.insert(skills, skill)
        end
    end
    table.sort(skills, function(a, b) return a.tier < b.tier end)
    return skills
end

-- Get monsters by spawn area
function GameData:GetMonstersByArea(area)
    local monsters = {}
    for id, monster in pairs(self.Monsters) do
        if monster.spawnArea == area then
            table.insert(monsters, monster)
        end
    end
    return monsters
end

-- Get shop items with full data
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

-- Get available quests for player
function GameData:GetAvailableQuests(playerLevel, completedQuests)
    local available = {}
    for id, quest in pairs(self.Quests) do
        if quest.level <= playerLevel then
            if not completedQuests[id] then
                if not quest.prerequisite or completedQuests[quest.prerequisite] then
                    table.insert(available, quest)
                end
            end
        end
    end
    return available
end

-- Calculate EXP for level
function GameData:CalculateExpForLevel(level)
    return self.Formulas.expPerLevel(level)
end

-- Calculate stats for job at level
function GameData:CalculateStats(jobId, level)
    local job = self.Jobs[jobId]
    if not job then return nil end
    return self.Formulas.calculateStats(job, level)
end

return GameData
