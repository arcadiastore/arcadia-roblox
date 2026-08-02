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
        
        local greeting = dialogueData.greeting
        local greetingText = type(greeting) == "string" and greeting or (greeting.text or "")
        local greetingResponses = {}
        
        -- If greeting has responses, use them
        if type(greeting) == "table" and greeting.responses then
            greetingResponses = greeting.responses
        else
            -- Add context-aware responses based on NPC type
            if npcData and npcData.hasQuest then
                -- Check if player has quest ready
                local hasReadyQuest = false
                for questId, quest in pairs(data.activeQuests or {}) do
                    local qData = GameData:GetQuest(questId)
                    if qData and qData.giver == npcId then
                        local allDone = true
                        for i, obj in ipairs(qData.objectives) do
                            if (quest.progress[i] or 0) < obj.count then
                                allDone = false
                                break
                            end
                        end
                        if allDone or quest.readyToComplete then
                            hasReadyQuest = true
                            break
                        end
                    end
                end
                
                if hasReadyQuest then
                    table.insert(greetingResponses, {text = "Saya sudah menyelesaikan tugasnya!", next = "quest_complete"})
                end
                
                -- Check if NPC has quest to offer
                local hasQuestToOffer = false
                for questId, qData in pairs(GameData.Quests or {}) do
                    if qData.giver == npcId and not data.activeQuests[questId] and not data.completedQuests[questId] then
                        hasQuestToOffer = true
                        break
                    end
                end
                
                if hasQuestToOffer then
                    table.insert(greetingResponses, {text = "Ada tugas untuk saya?", next = "quest_offer"})
                end
            end
            
            if npcData and npcData.hasShop then
                table.insert(greetingResponses, {text = "Saya mau lihat daganganmu.", next = "shop"})
            end
            
            -- Always add exit
            table.insert(greetingResponses, {text = "Sampai jumpa!", next = nil})
        end
        
        events.DialogueEvent:FireClient(player, {
            type = "Start",
            npcId = npcId,
            npcName = npcData and npcData.name or npcId,
            dialogue = {
                text = greetingText,
                responses = greetingResponses,
            },
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
    
    -- Handle quest_complete triggered from greeting
    if responseText == "Saya sudah menyelesaikan tugasnya!" then
        local QuestSystem = require(script.Parent.QuestSystem)
        local readyQuestId = QuestSystem:GetReadyQuest(data, npcId)
        if readyQuestId then
            state.currentNode = "quest_complete"
            state.questId = readyQuestId
            local npcData = GameData:GetNPC(npcId)
            events.DialogueEvent:FireClient(player, {
                type = "Continue",
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
        end
        return true
    end
    
    -- Handle "Ada tugas untuk saya?" from greeting
    if responseText == "Ada tugas untuk saya?" then
        local npcData = GameData:GetNPC(npcId)
        local questToOffer = nil
        for questId, qData in pairs(GameData.Quests or {}) do
            if qData.giver == npcId and not data.activeQuests[questId] and not data.completedQuests[questId] then
                questToOffer = {id = questId, data = qData}
                break
            end
        end
        
        if questToOffer then
            local q = questToOffer.data
            local rewardText = ""
            if q.rewards then
                local parts = {}
                if q.rewards.exp and q.rewards.exp > 0 then table.insert(parts, q.rewards.exp .. " EXP") end
                if q.rewards.gold and q.rewards.gold > 0 then table.insert(parts, q.rewards.gold .. " Gold") end
                rewardText = table.concat(parts, ", ")
            end
            
            local objText = ""
            if q.objectives then
                for _, obj in ipairs(q.objectives) do
                    objText = objText .. "\n  - " .. obj.description .. ": 0/" .. obj.count
                end
            end
            
            local preview = q.name .. "\n\n" .. q.description
            if objText ~= "" then preview = preview .. "\n\nObjektif:" .. objText end
            if rewardText ~= "" then preview = preview .. "\n\nReward: " .. rewardText end
            
            playerDialogueState[player.UserId] = {
                npcId = npcId,
                currentNode = "quest_offer",
                questId = questToOffer.id,
            }
            
            events.DialogueEvent:FireClient(player, {
                type = "Continue",
                npcId = npcId,
                npcName = npcData and npcData.name or npcId,
                dialogue = {
                    text = preview,
                    responses = {
                        {text = "✓ Saya terima quest ini!", next = "accept"},
                        {text = "✗ Nanti saja, saya belum siap.", next = nil},
                    },
                },
            })
        end
        return true
    end
    
    -- Handle "Saya mau lihat daganganmu." from greeting
    if responseText == "Saya mau lihat daganganmu." then
        local ShopSystem = require(script.Parent.ShopSystem)
        ShopSystem:OpenShop(player, data, npcId, events)
        playerDialogueState[player.UserId] = nil
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
    
    -- Handle quest accept (ONLY when current node has questId)
    if currentNode.questId then
        local acceptResponses = {
            ["✓ Saya terima quest ini!"] = true,
            ["Saya terima quest ini!"] = true,
            ["Saya terima!"] = true,
        }
        
        if acceptResponses[responseText] or string.find(responseText:lower(), "terima") then
            local QuestSystem = require(script.Parent.QuestSystem)
            QuestSystem:AcceptQuest(player, data, currentNode.questId, events)
            playerDialogueState[player.UserId] = nil
            events.DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
            return true
        end
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
    
    -- Check if response has action (e.g., select_job)
    if selected.action then
        if selected.action == "select_job" and selected.jobId then
            local PlayerData = require(script.Parent.PlayerData)
            local success, msg = PlayerData:SetJob(player, selected.jobId, events)
            
            local npcData = GameData:GetNPC(npcId)
            local jobData = GameData.Jobs and GameData.Jobs[selected.jobId]
            local responseMsg = success 
                and (msg .. "\n\nStats kamu telah diperbarui sesuai job " .. selected.jobId .. "!")
                or msg
            
            events.DialogueEvent:FireClient(player, {
                type = "Continue",
                npcId = npcId,
                npcName = npcData and npcData.name or npcId,
                dialogue = {
                    text = responseMsg,
                    responses = {{text = "Terima kasih!", next = nil}},
                },
            })
            
            playerDialogueState[player.UserId] = nil
            return true
        end
    end
    
    -- Go to next node
    if selected.next then
        local nextNode = dialogueData[selected.next]
        print("[Dialogue] Next node: " .. selected.next .. " exists: " .. tostring(nextNode ~= nil))
        
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
                print("[Dialogue] Node has questId: " .. nextNode.questId)
                local QuestSystem = require(script.Parent.QuestSystem)
                local questData = GameData:GetQuest(nextNode.questId)
                print("[Dialogue] QuestData found: " .. tostring(questData ~= nil))
                
                if questData then
                    if data.activeQuests[nextNode.questId] then
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
                        local canAccept = true
                        if questData.level and data.level < questData.level then canAccept = false end
                        if questData.prerequisite and not data.completedQuests[questData.prerequisite] then canAccept = false end
                        
                        if canAccept then
                            local questPreview = QuestSystem:BuildQuestPreview(questData)
                            print("[Dialogue] Sending quest preview to client")
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
