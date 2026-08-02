--[[
    DialogueSystem.lua
    Handles NPC dialogue, quest acceptance, shop opening
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local DialogueSystem = {}

-- Track current dialogue node per player
local playerDialogueState = {}

-- Dynamic responses that end dialogue
local exitResponses = {
    ["✗ Nanti saja, saya belum siap."] = true,
    ["Nanti saja, saya belum siap."] = true,
    ["Nanti saja."] = true,
    ["Sama-sama!"] = true,
    ["Baik, saya akan menyelesaikannya!"] = true,
    ["Saya akan kembali nanti."] = true,
    ["Terima kasih!"] = true,
    ["Saya akan pergi!"] = true,
    ["Baik, saya akan pergi!"] = true,
    ["Baik, saya akan latihan dulu!"] = true,
    ["Baik, saya akan menyelesaikannya dulu!"] = true,
    ["Saya akan membantu!"] = true,
    ["Terima kasih atas bantuanmu!"] = true,
}

-- Start dialogue with NPC
function DialogueSystem:Talk(player, data, npcId, events)
    local dialogueData = GameData:GetDialogue(npcId)
    if not dialogueData then return false end
    
    local npcData = GameData:GetNPC(npcId)
    
    -- Check if quest ready to turn in
    local QuestSystem = require(script.Parent.QuestSystem)
    local readyQuestId, readyQuestData = QuestSystem:GetReadyQuest(data, npcId)
    
    if readyQuestId and readyQuestData then
        -- Show quest turn-in
        playerDialogueState[player.UserId] = {
            npcId = npcId,
            currentNode = "quest_complete",
            questId = readyQuestId,
        }
        
        events.DialogueEvent:FireClient(player, {
            type = "Start",
            npcId = npcId,
            npcName = npcData and npcData.name or npcId,
            dialogue = {
                text = "Bagus sekali! Kau telah menyelesaikan tugasmu! Terimalah hadiah ini!",
                responses = {
                    {text = "Terima kasih! (Ambil Reward)", next = "complete"},
                    {text = "Nanti saja.", next = nil},
                },
            },
        })
        
        print("[Dialogue] " .. player.Name .. " - quest turn in for " .. readyQuestId)
    else
        -- Normal greeting
        playerDialogueState[player.UserId] = {
            npcId = npcId,
            currentNode = "greeting",
        }
        
        events.DialogueEvent:FireClient(player, {
            type = "Start",
            npcId = npcId,
            npcName = npcData and npcData.name or npcId,
            dialogue = dialogueData.greeting,
        })
        
        print("[Dialogue] " .. player.Name .. " talked to " .. npcId)
    end
    
    return true
end

-- Handle response
function DialogueSystem:Respond(player, data, npcId, responseText, events)
    local state = playerDialogueState[player.UserId]
    if not state or state.npcId ~= npcId then
        warn("[Dialogue] No dialogue state for " .. player.Name)
        return false
    end
    
    -- Handle quest completion
    if state.currentNode == "quest_complete" and state.questId then
        if responseText == "Terima kasih! (Ambil Reward)" or responseText == "Ambil Reward" then
            local QuestSystem = require(script.Parent.QuestSystem)
            QuestSystem:CompleteQuest(player, data, state.questId, events)
        end
        playerDialogueState[player.UserId] = nil
        events.DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
        return true
    end
    
    -- Handle exit responses
    if exitResponses[responseText] then
        playerDialogueState[player.UserId] = nil
        events.DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
        return true
    end
    
    -- Normal dialogue flow
    local dialogueData = GameData:GetDialogue(npcId)
    if not dialogueData then return false end
    
    local currentNode = dialogueData[state.currentNode]
    if not currentNode then
        warn("[Dialogue] Current node not found: " .. state.currentNode)
        return false
    end
    
    -- Handle quest accept
    if responseText == "✓ Saya terima quest ini!" or responseText == "Saya terima quest ini!" then
        if currentNode.questId then
            local QuestSystem = require(script.Parent.QuestSystem)
            QuestSystem:AcceptQuest(player, data, currentNode.questId, events)
        end
        playerDialogueState[player.UserId] = nil
        events.DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
        return true
    end
    
    -- Find selected response
    local selected = nil
    for _, resp in ipairs(currentNode.responses) do
        if resp.text == responseText then
            selected = resp
            break
        end
    end
    
    if not selected then
        warn("[Dialogue] Response not found: " .. responseText)
        return false
    end
    
    print("[Dialogue] " .. player.Name .. " selected: " .. responseText)
    
    -- Go to next node
    if selected.next then
        local nextNode = dialogueData[selected.next]
        if nextNode then
            -- Update state
            playerDialogueState[player.UserId] = {
                npcId = npcId,
                currentNode = selected.next,
            }
            
            -- Check if opens shop
            if nextNode.openShop then
                local ShopSystem = require(script.Parent.ShopSystem)
                ShopSystem:OpenShop(player, data, nextNode.openShop, events)
                playerDialogueState[player.UserId] = nil
                events.DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
                return true
            end
            
            -- Check if gives quest
            if nextNode.questId then
                local QuestSystem = require(script.Parent.QuestSystem)
                local questData = GameData:GetQuest(nextNode.questId)
                
                if questData then
                    -- Check if can accept
                    if data.activeQuests[nextNode.questId] then
                        -- Already active - show status
                        local statusText = QuestSystem:GetQuestStatusMessage(data, nextNode.questId, questData)
                        events.DialogueEvent:FireClient(player, {
                            type = "Continue",
                            npcId = npcId,
                            npcName = GameData:GetNPC(npcId) and GameData:GetNPC(npcId).name or npcId,
                            dialogue = {
                                text = statusText,
                                responses = {{text = "Baik, saya akan menyelesaikannya!", next = nil}},
                            },
                        })
                    elseif data.completedQuests[nextNode.questId] then
                        -- Already completed
                        events.DialogueEvent:FireClient(player, {
                            type = "Continue",
                            npcId = npcId,
                            npcName = GameData:GetNPC(npcId) and GameData:GetNPC(npcId).name or npcId,
                            dialogue = {
                                text = "Kau sudah menyelesaikan quest \"" .. questData.name .. "\". Terima kasih!",
                                responses = {{text = "Sama-sama!", next = nil}},
                            },
                        })
                    else
                        -- Check if can accept
                        local canAccept = true
                        if questData.level and data.level < questData.level then canAccept = false end
                        if questData.prerequisite and not data.completedQuests[questData.prerequisite] then canAccept = false end
                        
                        if canAccept then
                            -- Show quest preview
                            local questPreview = QuestSystem:BuildQuestPreview(questData)
                            events.DialogueEvent:FireClient(player, {
                                type = "Continue",
                                npcId = npcId,
                                npcName = GameData:GetNPC(npcId) and GameData:GetNPC(npcId).name or npcId,
                                dialogue = {
                                    text = nextNode.text .. "\n\n" .. questPreview,
                                    questId = nextNode.questId,
                                    responses = {
                                        {text = "✓ Saya terima quest ini!", next = "accept_quest"},
                                        {text = "✗ Nanti saja, saya belum siap.", next = nil},
                                    },
                                },
                            })
                        else
                            -- Show rejection reason
                            local rejectMsg = QuestSystem:GetRejectionMessage(data, questData)
                            events.DialogueEvent:FireClient(player, {
                                type = "Continue",
                                npcId = npcId,
                                npcName = GameData:GetNPC(npcId) and GameData:GetNPC(npcId).name or npcId,
                                dialogue = {
                                    text = rejectMsg,
                                    responses = {{text = "Baik, saya akan latihan dulu!", next = nil}},
                                },
                            })
                        end
                    end
                end
                return true
            end
            
            -- Normal dialogue
            events.DialogueEvent:FireClient(player, {
                type = "Continue",
                npcId = npcId,
                npcName = GameData:GetNPC(npcId) and GameData:GetNPC(npcId).name or npcId,
                dialogue = nextNode,
            })
            return true
        end
    end
    
    -- End dialogue (no next)
    playerDialogueState[player.UserId] = nil
    events.DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
    return true
end

return DialogueSystem
