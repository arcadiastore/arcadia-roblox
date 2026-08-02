--[[
    Arcadia Online - Quest System (v2 - Data-Driven)
    
    Semua data dari GameData module
    Tidak ada hardcode!
    
    Place di: ServerScriptService/Systems (as Script)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[Quest] Quest System initializing...")

-- ============================================
-- QUEST MANAGER
-- ============================================

local QuestManager = {}
QuestManager.__index = QuestManager

function QuestManager.new()
    local self = setmetatable({}, QuestManager)
    self.playerQuests = {}
    return self
end

function QuestManager:Init()
    self:SetupPlayerConnections()
    self:SetupQuestEvents()
    
    -- Create Events folder if not exists
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "Events"
        eventsFolder.Parent = ReplicatedStorage
    end
    
    print("[Quest] Quest System initialized!")
end

function QuestManager:SetupPlayerConnections()
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
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

function QuestManager:SetupQuestEvents()
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    
    local questEvent = Instance.new("RemoteEvent")
    questEvent.Name = "QuestEvent"
    questEvent.Parent = eventsFolder
    
    questEvent.OnServerEvent:Connect(function(player, action, data)
        if action == "accept" then
            self:AcceptQuest(player, data.questId)
        elseif action == "complete" then
            self:CompleteQuest(player, data.questId)
        end
    end)
end

function QuestManager:AcceptQuest(player, questId)
    -- Get quest data from GameData
    local questData = GameData:GetQuest(questId)
    if not questData then
        warn("[Quest] Quest not found: " .. questId)
        return
    end
    
    -- Check level
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if playerStats and playerStats.level < questData.level then
        warn("[Quest] Player level too low for quest: " .. questId)
        return
    end
    
    local playerQuestData = self.playerQuests[player.UserId]
    
    -- Check prerequisite from GameData
    if questData.prerequisite then
        if not playerQuestData.completedQuests[questData.prerequisite] then
            warn("[Quest] Prerequisite not completed: " .. questData.prerequisite)
            return
        end
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
    
    -- Create quest progress from GameData
    local questProgress = {
        id = questData.id,
        name = questData.name,
        description = questData.description,
        objectives = {},
        rewards = questData.rewards,
        acceptedAt = os.time(),
    }
    
    -- Copy objectives from GameData
    for _, obj in ipairs(questData.objectives) do
        table.insert(questProgress.objectives, {
            type = obj.type,
            target = obj.target,
            count = obj.count,
            current = 0,
        })
    end
    
    playerQuestData.activeQuests[questId] = questProgress
    
    -- Send to client
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local questEvent = eventsFolder:FindFirstChild("QuestEvent")
    if questEvent then
        questEvent:FireClient(player, {
            type = "QuestAccepted",
            quest = questProgress,
        })
    end
    
    print("[Quest] " .. player.Name .. " accepted quest: " .. questData.name)
end

function QuestManager:UpdateQuestProgress(player, questId, objectiveType, target, amount)
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return end
    
    local quest = playerQuestData.activeQuests[questId]
    if not quest then return end
    
    for _, obj in ipairs(quest.objectives) do
        if obj.type == objectiveType and obj.target == target then
            obj.current = math.min(obj.current + amount, obj.count)
            
            local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
            local questEvent = eventsFolder:FindFirstChild("QuestEvent")
            if questEvent then
                questEvent:FireClient(player, {
                    type = "QuestProgress",
                    questId = questId,
                    objective = obj,
                })
            end
            
            print("[Quest] " .. player.Name .. " progress: " .. obj.target .. " " .. obj.current .. "/" .. obj.count)
        end
    end
end

function QuestManager:CompleteQuest(player, questId)
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return end
    
    local quest = playerQuestData.activeQuests[questId]
    if not quest then
        warn("[Quest] Quest not active: " .. questId)
        return
    end
    
    -- Check all objectives
    local allCompleted = true
    for _, obj in ipairs(quest.objectives) do
        if obj.current < obj.count then
            allCompleted = false
            break
        end
    end
    
    if not allCompleted then
        warn("[Quest] Quest objectives not completed: " .. questId)
        return
    end
    
    -- Give rewards from GameData
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if playerStats then
        playerStats.exp = playerStats.exp + quest.rewards.exp
        playerStats.gold = playerStats.gold + quest.rewards.gold
        
        -- Give item rewards
        if quest.rewards.items then
            for _, item in ipairs(quest.rewards.items) do
                if _G.ShopManager then
                    _G.ShopManager:AddToInventory(player, item.itemId, item.count)
                end
            end
        end
        
        if _G.CombatManager then
            _G.CombatManager:CheckLevelUp(player, playerStats)
        end
    end
    
    -- Move to completed
    playerQuestData.completedQuests[questId] = true
    playerQuestData.activeQuests[questId] = nil
    
    -- Send to client
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local questEvent = eventsFolder:FindFirstChild("QuestEvent")
    if questEvent then
        questEvent:FireClient(player, {
            type = "QuestCompleted",
            questId = questId,
            rewards = quest.rewards,
        })
    end
    
    print("[Quest] " .. player.Name .. " completed quest: " .. quest.name)
    print("[Quest] Rewards: +" .. quest.rewards.exp .. " EXP, +" .. quest.rewards.gold .. " Gold")
end

function QuestManager:GetPlayerQuests(player)
    return self.playerQuests[player.UserId]
end

function QuestManager:GetAvailableQuests(player)
    local playerQuestData = self.playerQuests[player.UserId]
    if not playerQuestData then return {} end
    
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    local level = playerStats and playerStats.level or 1
    
    return GameData:GetAvailableQuests(level, playerQuestData.completedQuests)
end

-- Initialize
local questManager = QuestManager.new()
questManager:Init()
_G.QuestManager = questManager

print("[Quest] Quest System ready!")
