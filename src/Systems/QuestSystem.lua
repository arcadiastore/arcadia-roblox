--[[
    Arcadia Online - Quest System
    
    Handles quests according to GDD:
    - Accept quests from NPCs
    - Track quest progress
    - Complete quests for rewards
    - Quest chains
    
    Place di: ServerScriptService/Systems (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu game load
task.wait(6)

print("[Quest] Quest System initializing...")

-- ============================================
-- QUEST DEFINITIONS (GDD)
-- ============================================

local QUEST_DATA = {
    -- Quest 1: Kill Slimes (Tutorial)
    {
        id = "quest_kill_slimes",
        name = "Permintaan Tetua",
        description = "Elder Tetua meminta bantuanmu untuk membersihkan desa dari Slime. Bunuh 5 Slime di Training Ground.",
        level = 1,
        giver = "Elder",
        objectives = {
            {
                type = "kill",
                target = "Slime",
                count = 5,
                current = 0,
            },
        },
        rewards = {
            exp = 50,
            gold = 100,
        },
        prerequisite = nil,
        chain = "quest_herb_collector",
    },
    
    -- Quest 2: Collect Herbs
    {
        id = "quest_herb_collector",
        name = "Pengumpul Herbal",
        description = "Kumpulkan 10 Herbal di sekitar desa untuk obat tradisional.",
        level = 3,
        giver = "Elder",
        objectives = {
            {
                type = "collect",
                target = "Herb",
                count = 10,
                current = 0,
            },
        },
        rewards = {
            exp = 100,
            gold = 200,
        },
        prerequisite = "quest_kill_slimes",
        chain = "quest_elder_wisdom",
    },
    
    -- Quest 3: Talk to Elder
    {
        id = "quest_elder_wisdom",
        name = "Kebijaksanaan Tetua",
        description = "Bicara dengan Elder Tetua untuk mempelajari sejarah desa.",
        level = 5,
        giver = "Elder",
        objectives = {
            {
                type = "talk",
                target = "Elder",
                count = 1,
                current = 0,
            },
        },
        rewards = {
            exp = 200,
            gold = 0,
        },
        prerequisite = "quest_herb_collector",
        chain = "quest_boss_wolf",
    },
    
    -- Quest 4: Kill Boss Wolf
    {
        id = "quest_boss_wolf",
        name = "Alpha Wolf",
        description = "Kalahkan Alpha Wolf yang mengancam desa. Hati-hati, dia sangat kuat!",
        level = 8,
        giver = "Guard",
        objectives = {
            {
                type = "kill",
                target = "Wolf",
                count = 1,
                current = 0,
            },
        },
        rewards = {
            exp = 500,
            gold = 1000,
        },
        prerequisite = "quest_elder_wisdom",
        chain = nil,
    },
}

-- ============================================
-- QUEST MANAGER
-- ============================================

local QuestManager = {}
QuestManager.__index = QuestManager

function QuestManager.new()
    local self = setmetatable({}, QuestManager)
    
    -- Player quest data
    self.playerQuests = {}
    
    return self
end

function QuestManager:Init()
    -- Setup connections
    self:SetupPlayerConnections()
    self:SetupQuestEvents()
    
    print("[Quest] Quest System initialized!")
end

function QuestManager:SetupPlayerConnections()
    -- Player join
    Players.PlayerAdded:Connect(function(player)
        self:OnPlayerAdded(player)
    end)
    
    -- Player leave
    Players.PlayerRemoving:Connect(function(player)
        self:OnPlayerRemoving(player)
    end)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:OnPlayerAdded(player)
    end
end

function QuestManager:OnPlayerAdded(player)
    -- Initialize player quest data
    self.playerQuests[player.UserId] = {
        activeQuests = {},
        completedQuests = {},
        questProgress = {},
    }
    
    print("[Quest] Player quest data initialized: " .. player.Name)
end

function QuestManager:OnPlayerRemoving(player)
    -- Cleanup
    self.playerQuests[player.UserId] = nil
end

function QuestManager:SetupQuestEvents()
    -- RemoteEvent untuk quest
    local questEvent = Instance.new("RemoteEvent")
    questEvent.Name = "QuestEvent"
    questEvent.Parent = ReplicatedStorage:FindFirstChild("Events")
    
    -- Handle quest requests
    questEvent.OnServerEvent:Connect(function(player, action, questId)
        if action == "accept" then
            self:AcceptQuest(player, questId)
        elseif action == "complete" then
            self:CompleteQuest(player, questId)
        end
    end)
end

function QuestManager:AcceptQuest(player, questId)
    -- Find quest data
    local questData = nil
    for _, quest in ipairs(QUEST_DATA) do
        if quest.id == questId then
            questData = quest
            break
        end
    end
    
    if not questData then
        warn("[Quest] Quest not found: " .. questId)
        return
    end
    
    -- Check level requirement
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if playerStats and playerStats.level < questData.level then
        warn("[Quest] Player level too low for quest: " .. questId)
        return
    end
    
    -- Check prerequisite
    local playerQuestData = self.playerQuests[player.UserId]
    if questData.prerequisite then
        if not playerQuestData.completedQuests[questData.prerequisite] then
            warn("[Quest] Prerequisite not completed: " .. questData.prerequisite)
            return
        end
    end
    
    -- Check if already active
    if playerQuestData.activeQuests[questId] then
        warn("[Quest] Quest already active: " .. questId)
        return
    end
    
    -- Check if already completed
    if playerQuestData.completedQuests[questId] then
        warn("[Quest] Quest already completed: " .. questId)
        return
    end
    
    -- Accept quest
    local questProgress = {
        id = questData.id,
        name = questData.name,
        description = questData.description,
        objectives = {},
        rewards = questData.rewards,
        acceptedAt = os.time(),
    }
    
    -- Copy objectives
    for _, obj in ipairs(questData.objectives) do
        table.insert(questProgress.objectives, {
            type = obj.type,
            target = obj.target,
            count = obj.count,
            current = 0,
        })
    end
    
    playerQuestData.activeQuests[questId] = questProgress
    
    -- Send feedback
    local questEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("QuestEvent")
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
    if not playerQuestData then
        return
    end
    
    local quest = playerQuestData.activeQuests[questId]
    if not quest then
        return
    end
    
    -- Update objectives
    for _, obj in ipairs(quest.objectives) do
        if obj.type == objectiveType and obj.target == target then
            obj.current = math.min(obj.current + amount, obj.count)
            
            -- Send progress update
            local questEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("QuestEvent")
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
    if not playerQuestData then
        return
    end
    
    local quest = playerQuestData.activeQuests[questId]
    if not quest then
        warn("[Quest] Quest not active: " .. questId)
        return
    end
    
    -- Check if all objectives completed
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
    
    -- Give rewards
    local playerStats = _G.CombatManager and _G.CombatManager:GetPlayerStats(player)
    if playerStats then
        playerStats.exp = playerStats.exp + quest.rewards.exp
        playerStats.gold = playerStats.gold + quest.rewards.gold
        
        -- Check level up
        if _G.CombatManager then
            _G.CombatManager:CheckLevelUp(player, playerStats)
        end
    end
    
    -- Move to completed
    playerQuestData.completedQuests[questId] = true
    playerQuestData.activeQuests[questId] = nil
    
    -- Send feedback
    local questEvent = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("QuestEvent")
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
    local available = {}
    local playerQuestData = self.playerQuests[player.UserId]
    
    if not playerQuestData then
        return available
    end
    
    for _, quest in ipairs(QUEST_DATA) do
        -- Check if already active or completed
        if not playerQuestData.activeQuests[quest.id] and not playerQuestData.completedQuests[quest.id] then
            -- Check prerequisite
            if not quest.prerequisite or playerQuestData.completedQuests[quest.prerequisite] then
                table.insert(available, quest)
            end
        end
    end
    
    return available
end

-- ============================================
-- INITIALIZE
-- ============================================

-- Create Events folder if not exists
local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
if not eventsFolder then
    eventsFolder = Instance.new("Folder")
    eventsFolder.Name = "Events"
    eventsFolder.Parent = ReplicatedStorage
end

-- Initialize quest manager
local questManager = QuestManager.new()
questManager:Init()

-- Make accessible from other scripts
_G.QuestManager = questManager

print("[Quest] Quest System ready!")
