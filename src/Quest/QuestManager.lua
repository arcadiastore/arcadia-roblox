--[[
    Arcadia Online - Quest Manager
    
    Handles quest system:
    - Quest acceptance
    - Objective tracking
    - Quest completion
    - Rewards
    
    @author arcadiastore
    @version 1.0.0
]]

local QuestManager = {}
QuestManager.__index = QuestManager

-- Quest status
local QuestStatus = {
    AVAILABLE = "Available",
    ACTIVE = "Active",
    COMPLETED = "Completed",
    TURNED_IN = "TurnedIn",
}

-- Quest types
local QuestType = {
    KILL = "Kill",
    COLLECT = "Collect",
    TALK = "Talk",
    ESCORT = "Escort",
    EXPLORE = "Explore",
}

function QuestManager.new()
    local self = setmetatable({}, QuestManager)
    
    self.quests = {}  -- All quest definitions
    self.playerQuests = {}  -- Player quest progress
    
    return self
end

-- Load quest definitions
function QuestManager:LoadQuests()
    -- Quest: Permintaan Tetua (Beginner Quest)
    self:RegisterQuest({
        id = "quest_kill_slimes",
        name = "Permintaan Tetua",
        description = "Elder Tetua meminta bantuanmu untuk menghilangkan slime yang mengganggu desa.",
        type = QuestType.KILL,
        levelReq = 1,
        objectives = {
            {
                type = QuestType.KILL,
                targetId = "Slime",
                targetName = "Slime",
                required = 5,
                description = "Bunuh 5 Slime di Training Ground",
            },
        },
        rewards = {
            exp = 100,
            gold = 50,
            items = {},
        },
        dialogueStart = "quest_slime_start",
        dialogueComplete = "quest_slime_complete",
    })
    
    -- Quest: Ancaman Serigala
    self:RegisterQuest({
        id = "quest_kill_wolves",
        name = "Ancaman Serigala",
        description = "Serigala-serigala di hutan semakin berbahaya. Bunuh 3 Serigala untuk melindungi desa.",
        type = QuestType.KILL,
        levelReq = 3,
        prerequisite = "quest_kill_slimes",
        objectives = {
            {
                type = QuestType.KILL,
                targetId = "Wolf",
                targetName = "Serigala",
                required = 3,
                description = "Bunuh 3 Serigala",
            },
        },
        rewards = {
            exp = 200,
            gold = 100,
            items = {},
        },
    })
    
    -- Quest: Guardian of the Forest (Boss Quest)
    self:RegisterQuest({
        id = "quest_kill_boss",
        name = "Guardian of the Forest",
        description = "Boss kuat menghalangi jalan ke Green Forest. Kalahkan Guardian of the Forest!",
        type = QuestType.KILL,
        levelReq = 8,
        prerequisite = "quest_kill_wolves",
        objectives = {
            {
                type = QuestType.KILL,
                targetId = "Guardian",
                targetName = "Guardian of the Forest",
                required = 1,
                description = "Kalahkan Guardian of the Forest",
            },
        },
        rewards = {
            exp = 500,
            gold = 250,
            items = {"sword_iron"},
        },
    })
    
    -- Quest: Collect Herbs
    self:RegisterQuest({
        id = "quest_collect_herbs",
        name = "Obat Tradisional",
        description = "Tabib desa membutuhkan herba untuk membuat obat. Kumpulkan 5 Herba dari hutan.",
        type = QuestType.COLLECT,
        levelReq = 2,
        objectives = {
            {
                type = QuestType.COLLECT,
                targetId = "herb",
                targetName = "Herba",
                required = 5,
                description = "Kumpulkan 5 Herba",
            },
        },
        rewards = {
            exp = 80,
            gold = 30,
            items = {"potion_hp_small"},
        },
    })
    
    -- Quest: Talk to Blacksmith
    self:RegisterQuest({
        id = "quest_talk_blacksmith",
        name = "Kunjungi Pandai Besi",
        description = "Elder Tetua menyuruhmu mengunjungi Pandai Besi untuk mendapatkan senjata pertamamu.",
        type = QuestType.TALK,
        levelReq = 1,
        objectives = {
            {
                type = QuestType.TALK,
                targetId = "Blacksmith",
                targetName = "Pandai Besi",
                required = 1,
                description = "Bicara dengan Pandai Besi",
            },
        },
        rewards = {
            exp = 50,
            gold = 0,
            items = {"sword_wooden"},
        },
    })
    
    print("[QuestManager] Loaded " .. self:GetQuestCount() .. " quests")
end

-- Register a quest
function QuestManager:RegisterQuest(questData)
    self.quests[questData.id] = questData
end

-- Get quest count
function QuestManager:GetQuestCount()
    local count = 0
    for _ in pairs(self.quests) do
        count = count + 1
    end
    return count
end

-- Get available quests for player
function QuestManager:GetAvailableQuests(playerId)
    local available = {}
    
    for questId, quest in pairs(self.quests) do
        local status = self:GetQuestStatus(playerId, questId)
        
        if status == QuestStatus.AVAILABLE then
            -- Check prerequisite
            if quest.prerequisite then
                local prereqStatus = self:GetQuestStatus(playerId, quest.prerequisite)
                if prereqStatus == QuestStatus.TURNED_IN then
                    table.insert(available, quest)
                end
            else
                table.insert(available, quest)
            end
        end
    end
    
    return available
end

-- Accept quest
function QuestManager:AcceptQuest(playerId, questId)
    local quest = self.quests[questId]
    if not quest then
        return false, "Quest not found"
    end
    
    -- Check if already active
    local status = self:GetQuestStatus(playerId, questId)
    if status == QuestStatus.ACTIVE then
        return false, "Quest already active"
    end
    
    -- Check prerequisite
    if quest.prerequisite then
        local prereqStatus = self:GetQuestStatus(playerId, quest.prerequisite)
        if prereqStatus ~= QuestStatus.TURNED_IN then
            return false, "Prerequisite quest not completed"
        end
    end
    
    -- Initialize player quests if needed
    self.playerQuests[playerId] = self.playerQuests[playerId] or {}
    
    -- Set quest as active
    self.playerQuests[playerId][questId] = {
        status = QuestStatus.ACTIVE,
        objectives = {},
    }
    
    -- Initialize objectives
    for i, objective in ipairs(quest.objectives) do
        self.playerQuests[playerId][questId].objectives[i] = {
            current = 0,
            required = objective.required,
        }
    end
    
    print("[QuestManager] Player " .. playerId .. " accepted quest: " .. quest.name)
    return true, "Quest accepted"
end

-- Update quest objective
function QuestManager:UpdateObjective(playerId, questId, objectiveIndex, amount)
    local playerQuest = self.playerQuests[playerId]
    if not playerQuest or not playerQuest[questId] then
        return false
    end
    
    local questProgress = playerQuest[questId]
    if questProgress.status ~= QuestStatus.ACTIVE then
        return false
    end
    
    local objective = questProgress.objectives[objectiveIndex]
    if not objective then
        return false
    end
    
    -- Update progress
    objective.current = math.min(objective.current + amount, objective.required)
    
    -- Check if quest is complete
    if self:IsQuestComplete(playerId, questId) then
        questProgress.status = QuestStatus.COMPLETED
        print("[QuestManager] Quest completed: " .. questId)
    end
    
    return true
end

-- Check if quest is complete
function QuestManager:IsQuestComplete(playerId, questId)
    local playerQuest = self.playerQuests[playerId]
    if not playerQuest or not playerQuest[questId] then
        return false
    end
    
    local questProgress = playerQuest[questId]
    for _, objective in ipairs(questProgress.objectives) do
        if objective.current < objective.required then
            return false
        end
    end
    
    return true
end

-- Turn in quest and get rewards
function QuestManager:TurnInQuest(playerId, questId)
    local quest = self.quests[questId]
    if not quest then
        return false, "Quest not found"
    end
    
    local playerQuest = self.playerQuests[playerId]
    if not playerQuest or not playerQuest[questId] then
        return false, "Quest not active"
    end
    
    if playerQuest[questId].status ~= QuestStatus.COMPLETED then
        return false, "Quest not completed"
    end
    
    -- Mark as turned in
    playerQuest[questId].status = QuestStatus.TURNED_IN
    
    print("[QuestManager] Player " .. playerId .. " turned in quest: " .. quest.name)
    
    -- Return rewards
    return true, quest.rewards
end

-- Get quest status
function QuestManager:GetQuestStatus(playerId, questId)
    local playerQuest = self.playerQuests[playerId]
    if not playerQuest or not playerQuest[questId] then
        return QuestStatus.AVAILABLE
    end
    
    return playerQuest[questId].status
end

-- Get quest progress
function QuestManager:GetQuestProgress(playerId, questId)
    local playerQuest = self.playerQuests[playerId]
    if not playerQuest or not playerQuest[questId] then
        return nil
    end
    
    return playerQuest[questId]
end

-- Get all active quests for player
function QuestManager:GetActiveQuests(playerId)
    local active = {}
    
    local playerQuest = self.playerQuests[playerId]
    if playerQuest then
        for questId, progress in pairs(playerQuest) do
            if progress.status == QuestStatus.ACTIVE then
                local quest = self.quests[questId]
                if quest then
                    table.insert(active, {
                        quest = quest,
                        progress = progress,
                    })
                end
            end
        end
    end
    
    return active
end

-- Handle monster kill
function QuestManager:OnMonsterKilled(playerId, monsterId)
    local updated = false
    
    local activeQuests = self:GetActiveQuests(playerId)
    for _, questInfo in ipairs(activeQuests) do
        local quest = questInfo.quest
        local progress = questInfo.progress
        
        for i, objective in ipairs(quest.objectives) do
            if objective.type == QuestType.KILL and objective.targetId == monsterId then
                if self:UpdateObjective(playerId, quest.id, i, 1) then
                    updated = true
                end
            end
        end
    end
    
    return updated
end

-- Handle item collection
function QuestManager:OnItemCollected(playerId, itemId)
    local updated = false
    
    local activeQuests = self:GetActiveQuests(playerId)
    for _, questInfo in ipairs(activeQuests) do
        local quest = questInfo.quest
        local progress = questInfo.progress
        
        for i, objective in ipairs(quest.objectives) do
            if objective.type == QuestType.COLLECT and objective.targetId == itemId then
                if self:UpdateObjective(playerId, quest.id, i, 1) then
                    updated = true
                end
            end
        end
    end
    
    return updated
end

-- Serialize for saving
function QuestManager:Serialize(playerId)
    return self.playerQuests[playerId] or {}
end

-- Deserialize from saved data
function QuestManager:Deserialize(playerId, data)
    if data then
        self.playerQuests[playerId] = data
    end
end

return QuestManager.new()
