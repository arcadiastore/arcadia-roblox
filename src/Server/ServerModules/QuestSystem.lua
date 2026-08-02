--[[
    QuestSystem.lua
    Handles quest accept, progress tracking, completion
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local QuestSystem = {}

-- Check if player has quest ready to turn in for NPC
function QuestSystem:GetReadyQuest(data, npcId)
    for questId, quest in pairs(data.activeQuests) do
        if quest.readyToComplete then
            local questData = GameData:GetQuest(questId)
            if questData and questData.giver == npcId then
                return questId, questData
            end
        end
    end
    return nil, nil
end

-- Build quest preview text (INFORMATIF!)
function QuestSystem:BuildQuestPreview(questData)
    local preview = ""
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━\n"
    preview = preview .. "Quest: " .. questData.name .. "\n"
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━\n"
    preview = preview .. "Objektif:\n"
    for _, obj in ipairs(questData.objectives) do
        preview = preview .. "  - " .. obj.description .. "\n"
    end
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━\n"
    preview = preview .. "Reward:\n"
    if questData.rewards.exp then
        preview = preview .. "  - +" .. questData.rewards.exp .. " EXP\n"
    end
    if questData.rewards.gold then
        preview = preview .. "  - +" .. questData.rewards.gold .. " Gold\n"
    end
    if questData.rewards.items then
        for _, item in ipairs(questData.rewards.items) do
            preview = preview .. "  - " .. item.itemId .. " x" .. item.count .. "\n"
        end
    end
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━"
    return preview
end

-- Accept quest
function QuestSystem:AcceptQuest(player, data, questId, events)
    local questData = GameData:GetQuest(questId)
    if not questData then return false end
    
    -- Check if already active or completed
    if data.activeQuests[questId] or data.completedQuests[questId] then
        return false
    end
    
    -- Check level
    if questData.level and data.level < questData.level then
        return false, "level"
    end
    
    -- Check prerequisite
    if questData.prerequisite and not data.completedQuests[questData.prerequisite] then
        return false, "prerequisite"
    end
    
    -- Accept quest
    data.activeQuests[questId] = {
        id = questId,
        progress = {},
        readyToComplete = false,
    }
    for i, obj in ipairs(questData.objectives) do
        data.activeQuests[questId].progress[i] = 0
    end
    
    print("[Quest] " .. player.Name .. " accepted quest: " .. questId)
    
    -- Notify client
    events.UpdateEvent:FireClient(player, {
        type = "QuestAccepted",
        questId = questId,
        questName = questData.name,
    })
    
    return true
end

-- Complete quest and give rewards
function QuestSystem:CompleteQuest(player, data, questId, events)
    local questData = GameData:GetQuest(questId)
    if not questData then return false end
    
    -- Mark as completed
    data.completedQuests[questId] = true
    data.activeQuests[questId] = nil
    
    -- Give rewards
    local rewards = questData.rewards
    local rewardText = ""
    
    if rewards.exp then
        data.exp = data.exp + rewards.exp
        rewardText = rewardText .. "+" .. rewards.exp .. " EXP"
    end
    
    if rewards.gold then
        data.gold = data.gold + rewards.gold
        if rewardText ~= "" then rewardText = rewardText .. ", " end
        rewardText = rewardText .. "+" .. rewards.gold .. " Gold"
    end
    
    if rewards.items then
        for _, item in ipairs(rewards.items) do
            data.inventory[item.itemId] = (data.inventory[item.itemId] or 0) + item.count
            if rewardText ~= "" then rewardText = rewardText .. ", " end
            rewardText = rewardText .. item.itemId .. " x" .. item.count
        end
    end
    
    print("[Quest] " .. player.Name .. " completed quest: " .. questId .. " - Rewards: " .. rewardText)
    
    -- Send reward notification
    events.UpdateEvent:FireClient(player, {
        type = "QuestCompleted",
        questId = questId,
        questName = questData.name,
        rewards = rewardText,
    })
    
    -- Check level up
    local PlayerData = require(script.Parent.PlayerData)
    PlayerData:CheckLevelUp(player, events)
    PlayerData:SendUpdate(player, events)
    
    return true
end

-- Get quest status message (INFORMATIF!)
function QuestSystem:GetQuestStatusMessage(data, questId, questData)
    if data.activeQuests[questId] then
        -- Quest in progress
        local quest = data.activeQuests[questId]
        local statusText = "Kamu masih dalam quest: " .. questData.name .. "\n\n"
        for i, obj in ipairs(questData.objectives) do
            local prog = quest.progress[i] or 0
            local done = prog >= obj.count
            local status = done and "✓" or ">"
            statusText = statusText .. status .. " " .. obj.description .. ": " .. prog .. "/" .. obj.count .. "\n"
        end
        return statusText
    elseif data.completedQuests[questId] then
        -- Quest completed
        return "Kau sudah menyelesaikan quest \"" .. questData.name .. "\". Terima kasih!"
    end
    return nil
end

-- Get rejection message (INFORMATIF!)
function QuestSystem:GetRejectionMessage(data, questData)
    -- Level too low
    if questData.level and data.level < questData.level then
        return "Maaf, kamu belum cukup kuat untuk quest ini.\n\nKamu butuh Level " .. questData.level .. " untuk \"" .. questData.name .. "\".\n(Level kamu sekarang: " .. data.level .. ")"
    end
    
    -- Prerequisite not met
    if questData.prerequisite and not data.completedQuests[questData.prerequisite] then
        local prereqData = GameData:GetQuest(questData.prerequisite)
        local prereqName = prereqData and prereqData.name or questData.prerequisite
        local prereqGiver = prereqData and prereqData.giver or "NPC lain"
        local prereqNpcData = GameData:GetNPC(prereqGiver)
        local prereqNpcName = prereqNpcData and prereqNpcData.name or prereqGiver
        
        return "Maaf, kamu belum bisa mengambil quest ini.\n\nKamu harus menyelesaikan quest \"" .. prereqName .. "\" dari " .. prereqNpcName .. " terlebih dahulu."
    end
    
    return "Quest tidak tersedia."
end

return QuestSystem
