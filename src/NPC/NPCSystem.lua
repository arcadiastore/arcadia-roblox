--[[
    Arcadia Online - NPC System
    
    Handles NPC behavior:
    - Dialogue
    - Quest giving
    - Shop
    - Wandering
    
    @author arcadiastore
    @version 1.0.0
]]

local NPCSystem = {}
NPCSystem.__index = NPCSystem

-- NPC types
local NPCType = {
    QUEST_GIVER = "QuestGiver",
    SHOP = "Shop",
    DIALOGUE = "Dialogue",
    GUIDE = "Guide",
}

-- NPC definitions
local NPCDatabase = {
    Elder = {
        id = "Elder",
        name = "Elder Tetua",
        title = "Kepala Desa",
        type = NPCType.QUEST_GIVER,
        dialogue = {
            greeting = "Selamat datang di desa kita, petualang muda!",
            questAvailable = "Aku punya tugas untukmu. Maukah kau membantu desa?",
            questActive = "Bagaimana tugasmu? Sudahkah kau mengalahkan slime itu?",
            questComplete = "Luar biasa! Kau telah membantu desa kita. Terimalah hadiah ini!",
            noQuest = "Terima kasih sudah membantu desa kita.",
        },
        quests = {"quest_kill_slimes", "quest_kill_wolves", "quest_kill_boss"},
        position = Vector3.new(0, 0, -15),
    },
    
    Blacksmith = {
        id = "Blacksmith",
        name = "Pandai Besi",
        title = "Ahli Senjata",
        type = NPCType.SHOP,
        dialogue = {
            greeting = "Butuh senjata atau armor? Aku punya yang terbaik!",
            shop = "Lihat daganganku!",
        },
        shopItems = {
            { itemId = "sword_wooden", price = 50 },
            { itemId = "sword_iron", price = 200 },
            { itemId = "armor_leather", price = 100 },
            { itemId = "armor_iron", price = 300 },
        },
        position = Vector3.new(20, 0, 0),
    },
    
    Merchant = {
        id = "Merchant",
        name = "Pedagang",
        title = "Penjaja Keliling",
        type = NPCType.SHOP,
        dialogue = {
            greeting = "Hei! Mau beli sesuatu? Aku punya barang bagus!",
            shop = "Ini daganganku hari ini!",
        },
        shopItems = {
            { itemId = "potion_hp_small", price = 20 },
            { itemId = "potion_hp_large", price = 50 },
            { itemId = "potion_mp_small", price = 30 },
        },
        position = Vector3.new(-20, 0, 0),
    },
    
    Guard = {
        id = "Guard",
        name = "Penjaga Desa",
        title = "Kapten Penjaga",
        type = NPCType.DIALOGUE,
        dialogue = {
            greeting = "Hati-hati di luar desa. Monster semakin berbahaya akhir-akhir ini.",
            warning = "Jangan pergi ke hutan terlalu dalam. Ada monster kuat di sana.",
            tip = "Gunakan serangan dasar untuk slime, tapi untuk serigala kau perlu skill.",
        },
        position = Vector3.new(0, 0, 20),
    },
    
    TrainingMaster = {
        id = "TrainingMaster",
        name = "Master Pelatihan",
        title = "Instruktur Tempur",
        type = NPCType.GUIDE,
        dialogue = {
            greeting = "Selamat datang di Training Ground! Di sini kau bisa berlatih melawan dummy.",
            tutorial_attack = "Klik kiri untuk menyerang. Coba serang dummy itu!",
            tutorial_skill = "Tekan 1-4 untuk menggunakan skill. Skill punya cooldown.",
            tutorial_dodge = "Hindari serangan monster dengan bergerak. Jangan diam saja!",
            tutorial_quest = "Bicara dengan Elder Tetua untuk mendapatkan quest pertamamu.",
        },
        position = Vector3.new(0, 0, 10),
    },
}

function NPCSystem.new()
    local self = setmetatable({}, NPCSystem)
    
    self.npcs = {}
    
    return self
end

-- Register NPC
function NPCSystem:RegisterNPC(npcData)
    self.npcs[npcData.id] = npcData
end

-- Get NPC
function NPCSystem:GetNPC(npcId)
    return self.npcs[npcId]
end

-- Interact with NPC
function NPCSystem:Interact(player, npcId)
    local npc = self:GetNPC(npcId)
    if not npc then
        return false, "NPC not found"
    end
    
    -- Handle based on NPC type
    if npc.type == NPCType.QUEST_GIVER then
        return self:HandleQuestGiver(player, npc)
    elseif npc.type == NPCType.SHOP then
        return self:HandleShop(player, npc)
    elseif npc.type == NPCType.DIALOGUE then
        return self:HandleDialogue(player, npc)
    elseif npc.type == NPCType.GUIDE then
        return self:HandleGuide(player, npc)
    end
    
    return false, "Unknown NPC type"
end

-- Handle quest giver
function NPCSystem:HandleQuestGiver(player, npc)
    local playerId = player.UserId
    local QuestManager = require(game.ServerScriptService.QuestManager)
    
    -- Check for available quests
    local availableQuests = QuestManager:GetAvailableQuests(playerId)
    
    for _, quest in ipairs(availableQuests) do
        -- Check if this NPC gives this quest
        for _, questId in ipairs(npc.quests) do
            if quest.id == questId then
                -- Accept quest
                local success = QuestManager:AcceptQuest(playerId, quest.id)
                if success then
                    return true, {
                        dialogue = npc.dialogue.questAvailable,
                        quest = quest,
                    }
                end
            end
        end
    end
    
    -- Check for completed quests to turn in
    for _, questId in ipairs(npc.quests) do
        local status = QuestManager:GetQuestStatus(playerId, questId)
        if status == "Completed" then
            local success, rewards = QuestManager:TurnInQuest(playerId, questId)
            if success then
                return true, {
                    dialogue = npc.dialogue.questComplete,
                    rewards = rewards,
                }
            end
        end
    end
    
    -- Check for active quests
    local activeQuests = QuestManager:GetActiveQuests(playerId)
    if #activeQuests > 0 then
        return true, {
            dialogue = npc.dialogue.questActive,
            quests = activeQuests,
        }
    end
    
    return true, {
        dialogue = npc.dialogue.noQuest,
    }
end

-- Handle shop
function NPCSystem:HandleShop(player, npc)
    return true, {
        dialogue = npc.dialogue.shop,
        shopItems = npc.shopItems,
    }
end

-- Handle dialogue
function NPCSystem:HandleDialogue(player, npc)
    -- Get random dialogue
    local dialogues = {}
    for _, dialogue in pairs(npc.dialogue) do
        table.insert(dialogues, dialogue)
    end
    
    local randomDialogue = dialogues[math.random(#dialogues)]
    
    return true, {
        dialogue = randomDialogue,
    }
end

-- Handle guide
function NPCSystem:HandleGuide(player, npc)
    -- Return tutorial dialogue
    return true, {
        dialogue = npc.dialogue.greeting,
        tutorials = {
            npc.dialogue.tutorial_attack,
            npc.dialogue.tutorial_skill,
            npc.dialogue.tutorial_dodge,
            npc.dialogue.tutorial_quest,
        },
    }
end

-- Buy item from shop
function NPCSystem:BuyItem(player, npcId, itemId)
    local npc = self:GetNPC(npcId)
    if not npc or npc.type ~= NPCType.SHOP then
        return false, "Cannot buy from this NPC"
    end
    
    -- Find item in shop
    local itemData = nil
    for _, item in ipairs(npc.shopItems) do
        if item.itemId == itemId then
            itemData = item
            break
        end
    end
    
    if not itemData then
        return false, "Item not in shop"
    end
    
    -- Check if player has enough gold
    local InventoryManager = require(game.ServerScriptService.InventoryManager)
    local playerId = player.UserId
    
    local gold = InventoryManager:GetGold(playerId)
    if gold < itemData.price then
        return false, "Not enough gold"
    end
    
    -- Add item to inventory
    local success = InventoryManager:AddItem(playerId, itemId, 1)
    if not success then
        return false, "Inventory full"
    end
    
    -- Remove gold
    InventoryManager:RemoveGold(playerId, itemData.price)
    
    return true, "Purchased " .. itemId
end

-- Sell item to shop
function NPCSystem:SellItem(player, npcId, itemId)
    local npc = self:GetNPC(npcId)
    if not npc or npc.type ~= NPCType.SHOP then
        return false, "Cannot sell to this NPC"
    end
    
    local InventoryManager = require(game.ServerScriptService.InventoryManager)
    local playerId = player.UserId
    
    -- Check if player has item
    if not InventoryManager:HasItem(playerId, itemId, 1) then
        return false, "Don't have this item"
    end
    
    -- Get item value (half of buy price)
    local itemValue = 0
    for _, item in ipairs(npc.shopItems) do
        if item.itemId == itemId then
            itemValue = math.floor(item.price / 2)
            break
        end
    end
    
    -- Remove item
    InventoryManager:RemoveItem(playerId, itemId, 1)
    
    -- Add gold
    InventoryManager:AddGold(playerId, itemValue)
    
    return true, "Sold for " .. itemValue .. " gold"
end

return NPCSystem.new()
