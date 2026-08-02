--[[
    Arcadia Online - Main Server Script
    
    Initializes ALL server-side systems properly.
    
    Place di: ServerScriptService (as Script)
    
    @author arcadiastore
    @version 3.0.0
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("[MainServer] ==========================================")
print("[MainServer] Arcadia Online Server Starting...")
print("[MainServer] ==========================================")

-- Wait for GameData
task.wait(2)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
print("[MainServer] GameData loaded successfully!")

-- ============================================
-- CREATE EVENTS FOLDER
-- ============================================

local EventsFolder = Instance.new("Folder")
EventsFolder.Name = "Events"
EventsFolder.Parent = ReplicatedStorage

local function createRemoteEvent(name)
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = EventsFolder
    return event
end

-- Create all events
createRemoteEvent("AttackMonster")
createRemoteEvent("CombatFeedback")
createRemoteEvent("QuestEvent")
createRemoteEvent("ShopEvent")
createRemoteEvent("NPCEvent")
createRemoteEvent("NotificationEvent")
createRemoteEvent("DialogueEvent")

print("[MainServer] RemoteEvents created!")

-- ============================================
-- INITIALIZE SYSTEMS
-- ============================================

-- Combat System
local CombatManager = {}
CombatManager.__index = CombatManager
CombatManager.playerStats = {}

function CombatManager:Init()
    -- Player join
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
    
    -- Attack event
    local attackEvent = EventsFolder:WaitForChild("AttackMonster")
    attackEvent.OnServerEvent:Connect(function(player, monsterPart)
        self:HandleAttack(player, monsterPart)
    end)
    
    print("[Combat] Combat System initialized!")
end

function CombatManager:OnPlayerAdded(player)
    self.playerStats[player.UserId] = {
        level = 1,
        exp = 0,
        gold = 100,
        atk = 10,
        def = 5,
        hp = 100,
        maxHp = 100,
        expToNextLevel = GameData:CalculateExpForLevel(2),
        jobId = "Warrior",
    }
    print("[Combat] Player stats initialized: " .. player.Name)
end

function CombatManager:OnPlayerRemoving(player)
    self.playerStats[player.UserId] = nil
end

function CombatManager:GetPlayerStats(player)
    return self.playerStats[player.UserId]
end

function CombatManager:HandleAttack(player, monsterPart)
    if not monsterPart or not monsterPart.Parent then return end
    
    local monsterId = monsterPart:GetAttribute("MonsterId")
    if not monsterId then return end
    
    local playerStats = self.playerStats[player.UserId]
    if not playerStats then return end
    
    local monsterData = GameData:GetMonster(monsterId)
    if not monsterData then return end
    
    local monsterHP = monsterPart:GetAttribute("CurrentHP")
    if not monsterHP then
        monsterHP = monsterData.hp
        monsterPart:SetAttribute("CurrentHP", monsterHP)
    end
    
    -- Calculate damage
    local damage = GameData.Formulas.physicalDamage(playerStats.atk, 1.0, monsterData.def)
    
    -- Apply damage
    monsterHP = monsterHP - damage
    monsterPart:SetAttribute("CurrentHP", monsterHP)
    
    -- Send feedback to client
    local combatFeedback = EventsFolder:WaitForChild("CombatFeedback")
    combatFeedback:FireClient(player, {
        type = "DamageDealt",
        damage = damage,
        monsterId = monsterId,
        monsterHP = monsterHP,
        monsterMaxHP = monsterData.hp,
    })
    
    -- Check if monster is dead
    if monsterHP <= 0 then
        self:OnMonsterKilled(player, monsterId, monsterPart)
    end
end

function CombatManager:OnMonsterKilled(player, monsterId, monsterPart)
    local playerStats = self.playerStats[player.UserId]
    local monsterData = GameData:GetMonster(monsterId)
    
    if not playerStats or not monsterData then return end
    
    -- Give rewards
    playerStats.exp = playerStats.exp + monsterData.exp
    playerStats.gold = playerStats.gold + monsterData.gold
    
    print("[Combat] " .. player.Name .. " killed " .. monsterId .. " - EXP: +" .. monsterData.exp .. " Gold: +" .. monsterData.gold)
    
    -- Update quest progress
    if _G.QuestManager then
        _G.QuestManager:UpdateQuestProgress(player, "kill", monsterId, 1)
        print("[Combat] Quest progress updated for " .. monsterId)
    else
        warn("[Combat] QuestManager not found in _G!")
    end
    
    -- Check level up
    self:CheckLevelUp(player, playerStats)
    
    -- Send feedback
    local combatFeedback = EventsFolder:WaitForChild("CombatFeedback")
    combatFeedback:FireClient(player, {
        type = "MonsterKilled",
        monsterId = monsterId,
        exp = monsterData.exp,
        gold = monsterData.gold,
        level = playerStats.level,
    })
    
    -- Start respawn
    task.delay(monsterData.respawnTime or 10, function()
        if monsterPart and monsterPart.Parent then
            monsterPart:SetAttribute("CurrentHP", monsterData.hp)
            monsterPart.Transparency = 0
            monsterPart.CanCollide = true
            print("[Combat] " .. monsterId .. " respawned!")
        end
    end)
    
    -- Hide monster temporarily
    monsterPart.Transparency = 1
    monsterPart.CanCollide = false
end

function CombatManager:CheckLevelUp(player, playerStats)
    while playerStats.exp >= playerStats.expToNextLevel do
        playerStats.exp = playerStats.exp - playerStats.expToNextLevel
        playerStats.level = playerStats.level + 1
        playerStats.expToNextLevel = GameData:CalculateExpForLevel(playerStats.level + 1)
        
        -- Calculate new stats based on job
        local jobData = GameData:GetJob(playerStats.jobId)
        if jobData then
            local newStats = GameData:CalculateStats(playerStats.jobId, playerStats.level)
            if newStats then
                playerStats.maxHp = newStats.hp
                playerStats.hp = newStats.hp
                playerStats.atk = newStats.atk
                playerStats.def = newStats.def
            end
        end
        
        print("[Combat] " .. player.Name .. " leveled up to " .. playerStats.level .. "!")
        
        -- Send notification
        local notificationEvent = EventsFolder:WaitForChild("NotificationEvent")
        notificationEvent:FireClient(player, {
            type = "LevelUp",
            level = playerStats.level,
        })
    end
end

-- Set to global so QuestSystem can access
_G.CombatManager = CombatManager

-- Initialize Combat
CombatManager:Init()

-- ============================================
-- QUEST SYSTEM
-- ============================================

local QuestManager = {}
QuestManager.__index = QuestManager
QuestManager.playerQuests = {}

function QuestManager:Init()
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
    
    local questEvent = EventsFolder:WaitForChild("QuestEvent")
    questEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "accept" then
            self:AcceptQuest(player, data.questId)
        elseif action == "complete" then
            self:CompleteQuest(player, data.questId)
        end
    end)
    
    print("[Quest] Quest System initialized!")
end

function QuestManager:OnPlayerAdded(player)
    self.playerQuests[player.UserId] = {
        activeQuests = {},
        completedQuests = {},
    }
    print("[Quest] Player quest data initialized: " .. player.Name)
end

function QuestManager:OnPlayerRemoving(player)
    self.playerQuests[player.UserId] = nil
end

function QuestManager:AcceptQuest(player, questId)
    local questData = GameData:GetQuest(questId)
    if not questData then
        warn("[Quest] Quest not found: " .. questId)
        return
    end
    
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return end
    
    -- Check prerequisite
    if questData.prerequisite and not playerQuestData.completedQuests[questData.prerequisite] then
        warn("[Quest] Prerequisite not met for quest: " .. questId)
        return
    end
    
    -- Check if already active or completed
    if playerQuestData.activeQuests[questId] then
        warn("[Quest] Quest already active: " .. questId)
        return
    end
    
    if playerQuestData.completedQuests[questId] then
        warn("[Quest] Quest already completed: " .. questId)
        return
    end
    
    -- Add quest
    playerQuestData.activeQuests[questId] = {
        id = questId,
        progress = {},
    }
    
    -- Initialize progress for each objective
    for i, objective in ipairs(questData.objectives) do
        playerQuestData.activeQuests[questId].progress[i] = 0
    end
    
    print("[Quest] " .. player.Name .. " accepted quest: " .. questId)
    
    -- Notify client
    local questEvent = EventsFolder:WaitForChild("QuestEvent")
    questEvent:FireClient(player, {
        type = "QuestAccepted",
        quest = questData,
    })
end

function QuestManager:UpdateQuestProgress(player, actionType, target, amount)
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return end
    
    for questId, questProgress in pairs(playerQuestData.activeQuests) do
        local questData = GameData:GetQuest(questId)
        if questData then
            for i, objective in ipairs(questData.objectives) do
                if objective.type == actionType and objective.target == target then
                    questProgress.progress[i] = questProgress.progress[i] + amount
                    
                    print("[Quest] " .. player.Name .. " - " .. questId .. " objective " .. i .. ": " .. questProgress.progress[i] .. "/" .. objective.count)
                    
                    -- Check if objective complete
                    if questProgress.progress[i] >= objective.count then
                        self:CheckQuestComplete(player, questId)
                    end
                    
                    -- Update client
                    local questEvent = EventsFolder:WaitForChild("QuestEvent")
                    questEvent:FireClient(player, {
                        type = "QuestProgress",
                        questId = questId,
                        progress = questProgress.progress,
                    })
                end
            end
        end
    end
end

function QuestManager:CheckQuestComplete(player, questId)
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return end
    
    local questProgress = playerQuestData.activeQuests[questId]
    if not questProgress then return end
    
    local questData = GameData:GetQuest(questId)
    if not questData then return end
    
    -- Check all objectives
    local allComplete = true
    for i, objective in ipairs(questData.objectives) do
        if questProgress.progress[i] < objective.count then
            allComplete = false
            break
        end
    end
    
    if allComplete then
        -- Mark as complete
        playerQuestData.completedQuests[questId] = true
        playerQuestData.activeQuests[questId] = nil
        
        -- Give rewards
        self:GiveQuestRewards(player, questData)
        
        print("[Quest] " .. player.Name .. " completed quest: " .. questId)
        
        -- Notify client
        local questEvent = EventsFolder:WaitForChild("QuestEvent")
        questEvent:FireClient(player, {
            type = "QuestCompleted",
            questId = questId,
            rewards = questData.rewards,
        })
    end
end

function QuestManager:CompleteQuest(player, questId)
    -- For manual completion (talk to NPC)
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return end
    
    local questData = GameData:GetQuest(questId)
    if not questData then return end
    
    -- Check if all objectives are complete
    local questProgress = playerQuestData.activeQuests[questId]
    if not questProgress then return end
    
    local allComplete = true
    for i, objective in ipairs(questData.objectives) do
        if questProgress.progress[i] < objective.count then
            allComplete = false
            break
        end
    end
    
    if allComplete then
        self:CheckQuestComplete(player, questId)
    else
        warn("[Quest] Quest not ready to complete: " .. questId)
    end
end

function QuestManager:GiveQuestRewards(player, questData)
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if not playerStats then return end
    
    -- Give EXP
    if questData.rewards.exp then
        playerStats.exp = playerStats.exp + questData.rewards.exp
        print("[Quest] " .. player.Name .. " received " .. questData.rewards.exp .. " EXP")
    end
    
    -- Give Gold
    if questData.rewards.gold then
        playerStats.gold = playerStats.gold + questData.rewards.gold
        print("[Quest] " .. player.Name .. " received " .. questData.rewards.gold .. " Gold")
    end
    
    -- Give Items
    if questData.rewards.items then
        for _, itemData in ipairs(questData.rewards.items) do
            -- TODO: Add to inventory system
            print("[Quest] " .. player.Name .. " received item: " .. itemData.itemId .. " x" .. itemData.count)
        end
    end
end

-- Set to global so other systems can access
_G.QuestManager = QuestManager

-- Initialize Quest
QuestManager:Init()

-- ============================================
-- SHOP SYSTEM
-- ============================================

local ShopManager = {}
ShopManager.__index = ShopManager
ShopManager.playerInventory = {}

function ShopManager:Init()
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
    
    local shopEvent = EventsFolder:WaitForChild("ShopEvent")
    shopEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "buy" then
            self:BuyItem(player, data.itemId, data.quantity or 1)
        elseif action == "sell" then
            self:SellItem(player, data.itemId, data.quantity or 1)
        elseif action == "open" then
            self:OpenShop(player, data.shopId)
        end
    end)
    
    print("[Shop] Shop System initialized!")
end

function ShopManager:OnPlayerAdded(player)
    self.playerInventory[player.UserId] = {}
    print("[Shop] Player inventory initialized: " .. player.Name)
end

function ShopManager:OnPlayerRemoving(player)
    self.playerInventory[player.UserId] = nil
end

function ShopManager:OpenShop(player, shopId)
    local shopData = GameData:GetShop(shopId)
    if not shopData then
        warn("[Shop] Shop not found: " .. shopId)
        return
    end
    
    local shopItems = GameData:GetShopItems(shopId)
    
    -- Send to client
    local shopEvent = EventsFolder:WaitForChild("ShopEvent")
    shopEvent:FireClient(player, {
        type = "ShopOpened",
        shop = shopData,
        items = shopItems,
    })
    
    print("[Shop] " .. player.Name .. " opened shop: " .. shopId)
end

function ShopManager:BuyItem(player, itemId, quantity)
    local itemData = GameData:GetItem(itemId)
    if not itemData then
        warn("[Shop] Item not found: " .. itemId)
        return
    end
    
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if not playerStats then return end
    
    local totalPrice = itemData.price * quantity
    
    -- Check gold
    if playerStats.gold < totalPrice then
        warn("[Shop] Not enough gold!")
        local shopEvent = EventsFolder:WaitForChild("ShopEvent")
        shopEvent:FireClient(player, {
            type = "Error",
            message = "Gold tidak cukup!",
        })
        return
    end
    
    -- Deduct gold
    playerStats.gold = playerStats.gold - totalPrice
    
    -- Add to inventory
    local inventory = self.playerInventory[player.UserId]
    if not inventory[itemId] then
        inventory[itemId] = 0
    end
    inventory[itemId] = inventory[itemId] + quantity
    
    print("[Shop] " .. player.Name .. " bought " .. quantity .. "x " .. itemId .. " for " .. totalPrice .. " gold")
    
    -- Send confirmation
    local shopEvent = EventsFolder:WaitForChild("ShopEvent")
    shopEvent:FireClient(player, {
        type = "ItemBought",
        itemId = itemId,
        quantity = quantity,
        gold = playerStats.gold,
    })
end

function ShopManager:SellItem(player, itemId, quantity)
    local itemData = GameData:GetItem(itemId)
    if not itemData then
        warn("[Shop] Item not found: " .. itemId)
        return
    end
    
    local inventory = self.playerInventory[player.UserId]
    if not inventory[itemId] or inventory[itemId] < quantity then
        warn("[Shop] Not enough items to sell!")
        return
    end
    
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if not playerStats then return end
    
    local totalPrice = (itemData.sellPrice or 0) * quantity
    
    -- Remove from inventory
    inventory[itemId] = inventory[itemId] - quantity
    if inventory[itemId] <= 0 then
        inventory[itemId] = nil
    end
    
    -- Add gold
    playerStats.gold = playerStats.gold + totalPrice
    
    print("[Shop] " .. player.Name .. " sold " .. quantity .. "x " .. itemId .. " for " .. totalPrice .. " gold")
    
    -- Send confirmation
    local shopEvent = EventsFolder:WaitForChild("ShopEvent")
    shopEvent:FireClient(player, {
        type = "ItemSold",
        itemId = itemId,
        quantity = quantity,
        gold = playerStats.gold,
    })
end

_G.ShopManager = ShopManager
ShopManager:Init()

-- ============================================
-- DIALOGUE SYSTEM
-- ============================================

local DialogueManager = {}
DialogueManager.__index = DialogueManager

function DialogueManager:Init()
    local dialogueEvent = EventsFolder:WaitForChild("DialogueEvent")
    
    dialogueEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "talk" then
            self:StartDialogue(player, data.npcId)
        elseif action == "respond" then
            self:HandleResponse(player, data.npcId, data.responseText)
        end
    end)
    
    print("[Dialogue] Dialogue System initialized!")
end

function DialogueManager:StartDialogue(player, npcId)
    local dialogueData = GameData:GetDialogue(npcId)
    if not dialogueData then
        warn("[Dialogue] Dialogue not found for NPC: " .. npcId)
        return
    end
    
    local npcData = GameData:GetNPC(npcId)
    
    local dialogueEvent = EventsFolder:WaitForChild("DialogueEvent")
    dialogueEvent:FireClient(player, {
        type = "DialogueStart",
        npcId = npcId,
        npcName = npcData and npcData.name or npcId,
        dialogue = dialogueData.greeting,
    })
    
    print("[Dialogue] " .. player.Name .. " started dialogue with " .. npcId)
end

function DialogueManager:HandleResponse(player, npcId, responseText)
    local dialogueData = GameData:GetDialogue(npcId)
    if not dialogueData then return end
    
    -- Find the response
    local currentDialogue = dialogueData.greeting
    local selectedResponse = nil
    
    for _, response in ipairs(currentDialogue.responses) do
        if response.text == responseText then
            selectedResponse = response
            break
        end
    end
    
    if not selectedResponse then return end
    
    -- Check if response opens shop
    if currentDialogue.openShop then
        if _G.ShopManager then
            _G.ShopManager:OpenShop(player, currentDialogue.openShop)
        end
        return
    end
    
    -- Check if response gives quest
    if currentDialogue.questId then
        if _G.QuestManager then
            _G.QuestManager:AcceptQuest(player, currentDialogue.questId)
        end
        return
    end
    
    -- Go to next dialogue
    if selectedResponse.next then
        local nextDialogue = dialogueData[selectedResponse.next]
        if nextDialogue then
            local dialogueEvent = EventsFolder:WaitForChild("DialogueEvent")
            dialogueEvent:FireClient(player, {
                type = "DialogueContinue",
                npcId = npcId,
                dialogue = nextDialogue,
            })
        end
    else
        -- End dialogue
        local dialogueEvent = EventsFolder:WaitForChild("DialogueEvent")
        dialogueEvent:FireClient(player, {
            type = "DialogueEnd",
            npcId = npcId,
        })
    end
end

DialogueManager:Init()

print("[MainServer] ==========================================")
print("[MainServer] All systems initialized!")
print("[MainServer] ==========================================")
