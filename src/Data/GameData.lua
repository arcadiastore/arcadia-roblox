--[[
    Arcadia Online - Game Data Module (MAIN ENTRY POINT)
    
    SINGLE SOURCE OF TRUTH
    
    Cara pakai:
    local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
    local slime = GameData:GetMonster("Slime")
]]

local GameData = {}

-- Load all data modules
GameData.Monsters = require(script:WaitForChild("Monsters"))
GameData.Items = require(script:WaitForChild("Items"))
GameData.Quests = require(script:WaitForChild("Quests"))
GameData.NPCs = require(script:WaitForChild("NPCs"))
GameData.Shops = require(script:WaitForChild("Shops"))
GameData.Dialogues = require(script:WaitForChild("Dialogues"))
GameData.SpawnPositions = require(script:WaitForChild("SpawnPositions"))
GameData.Formulas = require(script:WaitForChild("Formulas"))

-- Helper functions
function GameData:GetMonster(id)
    return self.Monsters[id]
end

function GameData:GetItem(id)
    return self.Items[id]
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

function GameData:CalculateExpForLevel(level)
    return self.Formulas.expForLevel(level)
end

return GameData
