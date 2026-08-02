--[[
    Arcadia Online - Main Server Script
    
    SEMUA server logic ada di sini!
    Place di: ServerScriptService (as Script)
    
    @author arcadiastore
    @version 4.0.0
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Server] ==========================================")
print("[Server] Arcadia Online Server Starting...")
print("[Server] ==========================================")

-- Wait for GameData
task.wait(2)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
print("[Server] GameData loaded!")

-- ============================================
-- CREATE EVENTS
-- ============================================

local Events = Instance.new("Folder")
Events.Name = "Events"
Events.Parent = ReplicatedStorage

local function makeEvent(name)
    local e = Instance.new("RemoteEvent")
    e.Name = name
    e.Parent = Events
    return e
end

local AttackEvent = makeEvent("AttackEvent")
local ShopEvent = makeEvent("ShopEvent")
local QuestEvent = makeEvent("QuestEvent")
local DialogueEvent = makeEvent("DialogueEvent")
local UpdateEvent = makeEvent("UpdateEvent")

print("[Server] Events created!")

-- ============================================
-- PLAYER DATA
-- ============================================

local playerData = {}

local function initPlayer(player)
    playerData[player.UserId] = {
        level = 1,
        exp = 0,
        gold = 100,
        hp = 100,
        maxHp = 100,
        atk = 10,
        def = 5,
        activeQuests = {},
        completedQuests = {},
        inventory = {},
    }
    print("[Server] Player data init: " .. player.Name)
end

local function removePlayer(player)
    playerData[player.UserId] = nil
    print("[Server] Player data removed: " .. player.Name)
end

Players.PlayerAdded:Connect(initPlayer)
Players.PlayerRemoving:Connect(removePlayer)

for _, p in ipairs(Players:GetPlayers()) do
    initPlayer(p)
end

-- ============================================
-- COMBAT SYSTEM
-- ============================================

AttackEvent.OnServerEvent:Connect(function(player, monsterPart)
    if not monsterPart or not monsterPart.Parent then return end
    
    local monsterId = monsterPart:GetAttribute("MonsterId")
    if not monsterId then return end
    
    local data = playerData[player.UserId]
    if not data then return end
    
    local monsterData = GameData:GetMonster(monsterId)
    if not monsterData then return end
    
    -- Get monster HP
    local monsterHP = monsterPart:GetAttribute("CurrentHP")
    if not monsterHP then
        monsterHP = monsterData.hp
        monsterPart:SetAttribute("CurrentHP", monsterHP)
    end
    
    -- Calculate damage
    local damage = GameData.Formulas.physicalDamage(data.atk, 1.0, monsterData.def)
    
    -- Apply damage
    monsterHP = monsterHP - damage
    monsterPart:SetAttribute("CurrentHP", monsterHP)
    
    print("[Combat] " .. player.Name .. " hit " .. monsterId .. " DMG:" .. damage .. " HP:" .. monsterHP .. "/" .. monsterData.hp)
    
    -- Send feedback to client
    UpdateEvent:FireClient(player, {
        type = "Damage",
        damage = damage,
        target = monsterId,
    })
    
    -- Check if monster died
    if monsterHP <= 0 then
        -- Give rewards
        data.exp = data.exp + monsterData.exp
        data.gold = data.gold + monsterData.gold
        
        print("[Server] " .. player.Name .. " killed " .. monsterId .. " +" .. monsterData.exp .. "EXP +" .. monsterData.gold .. "G")
        
        -- Update quest progress (ONLY ON DEATH!)
        for questId, quest in pairs(data.activeQuests) do
            local questData = GameData:GetQuest(questId)
            if questData then
                for i, obj in ipairs(questData.objectives) do
                    if obj.type == "kill" and obj.target == monsterId then
                        quest.progress[i] = (quest.progress[i] or 0) + 1
                        print("[Server] Quest progress: " .. questId .. " " .. quest.progress[i] .. "/" .. obj.count)
                    end
                end
            end
        end
        
        -- Check quest completion
        for questId, quest in pairs(data.activeQuests) do
            local questData = GameData:GetQuest(questId)
            if questData then
                local complete = true
                for i, obj in ipairs(questData.objectives) do
                    if (quest.progress[i] or 0) < obj.count then
                        complete = false
                        break
                    end
                end
                if complete then
                    quest.readyToComplete = true
                    print("[Server] Quest ready to turn in: " .. questId)
                    
                    -- Notify player to return to NPC
                    UpdateEvent:FireClient(player, {
                        type = "QuestReady",
                        questId = questId,
                        questName = questData.name,
                        npcName = questData.giver,  -- NPC yang harus dikunjungi
                    })
                end
            end
        end
        
        -- Check level up
        local expNeeded = GameData:CalculateExpForLevel(data.level + 1)
        while data.exp >= expNeeded do
            data.exp = data.exp - expNeeded
            data.level = data.level + 1
            data.maxHp = data.maxHp + 10
            data.hp = data.maxHp
            data.atk = data.atk + 2
            data.def = data.def + 1
            expNeeded = GameData:CalculateExpForLevel(data.level + 1)
            print("[Server] " .. player.Name .. " level up! Lv." .. data.level)
        end
        
        -- Send update to client
        UpdateEvent:FireClient(player, {
            type = "Update",
            level = data.level,
            exp = data.exp,
            gold = data.gold,
            hp = data.hp,
            maxHp = data.maxHp,
            atk = data.atk,
            def = data.def,
            activeQuests = data.activeQuests,
            completedQuests = data.completedQuests,
        })
        
        -- Hide monster AND disable click
        monsterPart.Transparency = 1
        monsterPart.CanCollide = false
        
        -- Disable ClickDetector
        local clickDetector = monsterPart:FindFirstChild("ClickDetector")
        if clickDetector then
            clickDetector.MaxActivationDistance = 0
        end
        
        -- Also hide name tag if exists
        local billboard = monsterPart:FindFirstChild("BillboardGui")
        if billboard then
            billboard.Enabled = false
        end
        
        -- Respawn monster
        task.delay(monsterData.respawnTime, function()
            if monsterPart and monsterPart.Parent then
                monsterPart:SetAttribute("CurrentHP", monsterData.hp)
                monsterPart.Transparency = 0
                monsterPart.CanCollide = true
                
                -- Re-enable ClickDetector
                if clickDetector then
                    clickDetector.MaxActivationDistance = 20
                end
                
                -- Re-enable name tag
                if billboard then
                    billboard.Enabled = true
                end
                
                print("[Server] Monster respawned: " .. monsterId)
            end
        end)
    end
end)

print("[Server] Combat system ready!")

-- ============================================
-- QUEST SYSTEM
-- ============================================

QuestEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = playerData[player.UserId]
    if not pData then return end
    
    if action == "accept" then
        local questId = data.questId
        local questData = GameData:GetQuest(questId)
        if not questData then return end
        
        -- Check if already active or completed
        if pData.activeQuests[questId] or pData.completedQuests[questId] then
            return
        end
        
        -- Check prerequisite
        if questData.prerequisite and not pData.completedQuests[questData.prerequisite] then
            return
        end
        
        -- Add quest
        pData.activeQuests[questId] = {
            id = questId,
            progress = {},
        }
        for i, obj in ipairs(questData.objectives) do
            pData.activeQuests[questId].progress[i] = 0
        end
        
        print("[Server] " .. player.Name .. " accepted quest: " .. questId)
        
        -- Update client
        UpdateEvent:FireClient(player, {
            type = "Update",
            level = pData.level,
            exp = pData.exp,
            gold = pData.gold,
            hp = pData.hp,
            maxHp = pData.maxHp,
            atk = pData.atk,
            def = pData.def,
            activeQuests = pData.activeQuests,
            completedQuests = pData.completedQuests,
        })
    end
end)

print("[Server] Quest system ready!")

-- ============================================
-- SHOP SYSTEM
-- ============================================

ShopEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = playerData[player.UserId]
    if not pData then return end
    
    if action == "open" then
        local shopId = data.shopId
        local shopData = GameData:GetShop(shopId)
        if not shopData then return end
        
        local shopItems = GameData:GetShopItems(shopId)
        
        ShopEvent:FireClient(player, {
            type = "Open",
            shop = shopData,
            items = shopItems,
            gold = pData.gold,
        })
        
        print("[Server] " .. player.Name .. " opened shop: " .. shopId)
        
    elseif action == "buy" then
        local itemId = data.itemId
        local itemData = GameData:GetItem(itemId)
        if not itemData then return end
        
        if pData.gold < itemData.price then
            ShopEvent:FireClient(player, {type = "Error", message = "Gold tidak cukup!"})
            return
        end
        
        pData.gold = pData.gold - itemData.price
        pData.inventory[itemId] = (pData.inventory[itemId] or 0) + 1
        
        print("[Server] " .. player.Name .. " bought " .. itemId)
        
        ShopEvent:FireClient(player, {
            type = "Bought",
            itemId = itemId,
            gold = pData.gold,
        })
        
        UpdateEvent:FireClient(player, {
            type = "Update",
            level = pData.level,
            exp = pData.exp,
            gold = pData.gold,
            hp = pData.hp,
            maxHp = pData.maxHp,
            atk = pData.atk,
            def = pData.def,
            activeQuests = pData.activeQuests,
            completedQuests = pData.completedQuests,
        })
    end
end)

print("[Server] Shop system ready!")

-- ============================================
-- DIALOGUE SYSTEM
-- ============================================

-- Track current dialogue node per player
local playerDialogueState = {}

-- Check if player has quest ready to turn in for this NPC
local function getReadyQuest(playerData, npcId)
    for questId, quest in pairs(playerData.activeQuests) do
        if quest.readyToComplete then
            local questData = GameData:GetQuest(questId)
            if questData and questData.giver == npcId then
                return questId, questData
            end
        end
    end
    return nil, nil
end

-- Complete quest and give rewards
local function completeQuest(player, pData, questId, questData)
    -- Mark as completed
    pData.completedQuests[questId] = true
    pData.activeQuests[questId] = nil
    
    -- Give rewards
    local rewards = questData.rewards
    local rewardText = ""
    
    if rewards.exp then
        pData.exp = pData.exp + rewards.exp
        rewardText = rewardText .. "+" .. rewards.exp .. " EXP"
    end
    
    if rewards.gold then
        pData.gold = pData.gold + rewards.gold
        if rewardText ~= "" then rewardText = rewardText .. ", " end
        rewardText = rewardText .. "+" .. rewards.gold .. " Gold"
    end
    
    if rewards.items then
        for _, item in ipairs(rewards.items) do
            pData.inventory[item.itemId] = (pData.inventory[item.itemId] or 0) + item.count
            if rewardText ~= "" then rewardText = rewardText .. ", " end
            rewardText = rewardText .. item.itemId .. " x" .. item.count
        end
    end
    
    print("[Server] " .. player.Name .. " completed quest: " .. questId .. " - Rewards: " .. rewardText)
    
    -- Check level up
    local expNeeded = GameData:CalculateExpForLevel(pData.level + 1)
    while pData.exp >= expNeeded do
        pData.exp = pData.exp - expNeeded
        pData.level = pData.level + 1
        pData.maxHp = pData.maxHp + 10
        pData.hp = pData.maxHp
        pData.atk = pData.atk + 2
        pData.def = pData.def + 1
        expNeeded = GameData:CalculateExpForLevel(pData.level + 1)
        print("[Server] " .. player.Name .. " level up! Lv." .. pData.level)
    end
    
    -- Send reward notification
    UpdateEvent:FireClient(player, {
        type = "QuestCompleted",
        questId = questId,
        questName = questData.name,
        rewards = rewardText,
    })
    
    -- Send update
    UpdateEvent:FireClient(player, {
        type = "Update",
        level = pData.level,
        exp = pData.exp,
        gold = pData.gold,
        hp = pData.hp,
        maxHp = pData.maxHp,
        atk = pData.atk,
        def = pData.def,
        activeQuests = pData.activeQuests,
        completedQuests = pData.completedQuests,
    })
end

-- Helper: Build quest preview text
local function buildQuestPreview(questData)
    local preview = ""
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━\n"
    preview = preview .. "📜 Quest: " .. questData.name .. "\n"
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━\n"
    preview = preview .. "📋 Objektif:\n"
    for _, obj in ipairs(questData.objectives) do
        preview = preview .. "  • " .. obj.description .. "\n"
    end
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━\n"
    preview = preview .. "🎁 Reward:\n"
    if questData.rewards.exp then
        preview = preview .. "  • +" .. questData.rewards.exp .. " EXP\n"
    end
    if questData.rewards.gold then
        preview = preview .. "  • +" .. questData.rewards.gold .. " Gold\n"
    end
    if questData.rewards.items then
        for _, item in ipairs(questData.rewards.items) do
            preview = preview .. "  • " .. item.itemId .. " x" .. item.count .. "\n"
        end
    end
    preview = preview .. "━━━━━━━━━━━━━━━━━━━━"
    return preview
end

DialogueEvent.OnServerEvent:Connect(function(player, action, data)
    local pData = playerData[player.UserId]
    if not pData then return end
    
    if action == "talk" then
        local npcId = data.npcId
        local dialogueData = GameData:GetDialogue(npcId)
        if not dialogueData then return end
        
        local npcData = GameData:GetNPC(npcId)
        
        -- CHECK: Does player have quest ready to turn in?
        local readyQuestId, readyQuestData = getReadyQuest(pData, npcId)
        
        if readyQuestId and readyQuestData then
            -- Show quest complete dialogue
            playerDialogueState[player.UserId] = {
                npcId = npcId,
                currentNode = "quest_complete",
                questId = readyQuestId,
            }
            
            DialogueEvent:FireClient(player, {
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
            
            print("[Server] " .. player.Name .. " - showing quest turn in for " .. readyQuestId)
        else
            -- Normal greeting
            playerDialogueState[player.UserId] = {
                npcId = npcId,
                currentNode = "greeting",
            }
            
            DialogueEvent:FireClient(player, {
                type = "Start",
                npcId = npcId,
                npcName = npcData and npcData.name or npcId,
                dialogue = dialogueData.greeting,
            })
            
            print("[Server] " .. player.Name .. " started dialogue with " .. npcId)
        end
        
    elseif action == "respond" then
        local npcId = data.npcId
        local responseText = data.responseText
        
        -- Get current dialogue state
        local state = playerDialogueState[player.UserId]
        if not state or state.npcId ~= npcId then
            warn("[Server] No dialogue state for " .. player.Name)
            return
        end
        
        -- Handle quest completion
        if state.currentNode == "quest_complete" and state.questId then
            -- Complete the quest
            local questData = GameData:GetQuest(state.questId)
            if questData then
                completeQuest(player, pData, state.questId, questData)
            end
            
            -- End dialogue
            playerDialogueState[player.UserId] = nil
            DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
            return
        end
        
        -- Normal dialogue flow
        local dialogueData = GameData:GetDialogue(npcId)
        if not dialogueData then return end
        
        -- Get current node
        local currentNode = dialogueData[state.currentNode]
        if not currentNode then
            warn("[Server] Current node not found: " .. state.currentNode)
            return
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
            warn("[Server] Response not found: " .. responseText)
            return
        end
        
        print("[Server] " .. player.Name .. " selected: " .. responseText)
        
        -- Go to next dialogue node
        if selected.next then
            local nextNode = dialogueData[selected.next]
            if nextNode then
                -- Update state to next node
                playerDialogueState[player.UserId] = {
                    npcId = npcId,
                    currentNode = selected.next,
                }
                
                -- Check if next node opens shop
                if nextNode.openShop then
                    local shopData = GameData:GetShop(nextNode.openShop)
                    if shopData then
                        local shopItems = GameData:GetShopItems(nextNode.openShop)
                        ShopEvent:FireClient(player, {
                            type = "Open",
                            shop = shopData,
                            items = shopItems,
                            gold = pData.gold,
                        })
                    end
                    playerDialogueState[player.UserId] = nil
                    DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
                    return
                end
                
                -- Check if next node gives quest
                if nextNode.questId then
                    local questData = GameData:GetQuest(nextNode.questId)
                    if questData and not pData.activeQuests[nextNode.questId] and not pData.completedQuests[nextNode.questId] then
                        local canAccept = true
                        if questData.prerequisite and not pData.completedQuests[questData.prerequisite] then
                            canAccept = false
                        end
                        
                        if canAccept then
                            -- SHOW QUEST PREVIEW - Player must choose!
                            local questPreview = buildQuestPreview(questData)
                            
                            -- Update state to track quest node
                            playerDialogueState[player.UserId] = {
                                npcId = npcId,
                                currentNode = selected.next,  -- Keep track of quest node
                            }
                            
                            DialogueEvent:FireClient(player, {
                                type = "Continue",
                                npcId = npcId,
                                npcName = npcData and npcData.name or npcId,
                                dialogue = {
                                    text = nextNode.text .. "\n\n" .. questPreview,
                                    questId = nextNode.questId,
                                    responses = {
                                        {text = "✓ Saya terima quest ini!", next = "accept_quest"},
                                        {text = "✗ Nanti saja, saya belum siap.", next = nil},
                                    },
                                },
                            })
                            return
                        end
                    end
                    
                    -- Quest already active or completed - show status
                    if pData.activeQuests[nextNode.questId] then
                        local quest = pData.activeQuests[nextNode.questId]
                        local questInfo = GameData:GetQuest(nextNode.questId)
                        local statusText = "Kamu masih dalam quest: " .. questInfo.name .. "\n\n"
                        for i, obj in ipairs(questInfo.objectives) do
                            local prog = quest.progress[i] or 0
                            local done = prog >= obj.count
                            local status = done and "✓" or ">"
                            statusText = statusText .. status .. " " .. obj.description .. ": " .. prog .. "/" .. obj.count .. "\n"
                        end
                        
                        DialogueEvent:FireClient(player, {
                            type = "Continue",
                            npcId = npcId,
                            npcName = npcData and npcData.name or npcId,
                            dialogue = {
                                text = statusText,
                                responses = {
                                    {text = "Baik, saya akan menyelesaikannya!", next = nil},
                                },
                            },
                        })
                    else
                        DialogueEvent:FireClient(player, {
                            type = "Continue",
                            npcId = npcId,
                            npcName = npcData and npcData.name or npcId,
                            dialogue = {
                                text = "Kau sudah menyelesaikan quest itu. Terima kasih!",
                                responses = {
                                    {text = "Sama-sama!", next = nil},
                                },
                            },
                        })
                    end
                    return
                end
                
                -- Handle quest acceptance
                if selected.next == "accept_quest" then
                    -- Find quest from current node
                    local currentState = playerDialogueState[player.UserId]
                    local questNodeId = currentState.currentNode
                    local questNode = dialogueData[questNodeId]
                    
                    if questNode and questNode.questId then
                        local questData = GameData:GetQuest(questNode.questId)
                        if questData then
                            -- Accept quest
                            pData.activeQuests[questNode.questId] = {
                                id = questNode.questId,
                                progress = {},
                                readyToComplete = false,
                            }
                            for i, obj in ipairs(questData.objectives) do
                                pData.activeQuests[questNode.questId].progress[i] = 0
                            end
                            print("[Server] " .. player.Name .. " accepted quest: " .. questNode.questId)
                            
                            UpdateEvent:FireClient(player, {
                                type = "QuestAccepted",
                                questId = questNode.questId,
                                questName = questData.name,
                            })
                            
                            UpdateEvent:FireClient(player, {
                                type = "Update",
                                level = pData.level,
                                exp = pData.exp,
                                gold = pData.gold,
                                hp = pData.hp,
                                maxHp = pData.maxHp,
                                atk = pData.atk,
                                def = pData.def,
                                activeQuests = pData.activeQuests,
                                completedQuests = pData.completedQuests,
                            })
                        end
                    end
                    
                    playerDialogueState[player.UserId] = nil
                    DialogueEvent:FireClient(player, {type = "End", npcId = npcId})
                    return
                end
                
                -- Normal dialogue - show next node
                DialogueEvent:FireClient(player, {
                    type = "Continue",
                    npcId = npcId,
                    npcName = npcData and npcData.name or npcId,
                    dialogue = nextNode,
                })
            else
                warn("[Server] Next node not found: " .. selected.next)
            end
        else
            -- End dialogue (no next)
            playerDialogueState[player.UserId] = nil
            DialogueEvent:FireClient(player, {
                type = "End",
                npcId = npcId,
            })
        end
    end
end)

print("[Server] Dialogue system ready!")

-- ============================================
-- SPAWN NPCs
-- ============================================

task.wait(1)

local npcFolder = Instance.new("Folder")
npcFolder.Name = "NPCs"
npcFolder.Parent = workspace

for npcId, npcData in pairs(GameData.NPCs) do
    local npc = Instance.new("Part")
    npc.Name = npcId
    npc.Size = Vector3.new(2, 5, 2)
    npc.Position = npcData.position + Vector3.new(0, 2.5, 0)
    npc.Anchored = true
    npc.CanCollide = true
    npc.Color = npcData.color or Color3.fromRGB(200, 200, 200)
    npc.Material = Enum.Material.SmoothPlastic
    
    -- Name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = npc
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = npcData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
    titleLabel.Position = UDim2.new(0, 0, 0.6, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = npcData.title or ""
    titleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.TextScaled = true
    titleLabel.Parent = billboard
    
    -- Attributes
    npc:SetAttribute("NPCId", npcId)
    npc:SetAttribute("HasShop", npcData.hasShop or false)
    npc:SetAttribute("HasQuest", npcData.hasQuest or false)
    if npcData.hasShop then
        npc:SetAttribute("ShopId", npcData.shopId)
    end
    
    -- ClickDetector
    local click = Instance.new("ClickDetector")
    click.MaxActivationDistance = 15
    click.Parent = npc
    
    npc.Parent = npcFolder
end

print("[Server] NPCs spawned!")

-- ============================================
-- SPAWN MONSTERS
-- ============================================

local monsterFolder = Instance.new("Folder")
monsterFolder.Name = "Monsters"
monsterFolder.Parent = workspace

for monsterId, monsterData in pairs(GameData.Monsters) do
    local spawnData = GameData.SpawnPositions[monsterData.spawnArea]
    if spawnData then
        local count = 1
        if monsterId == "Slime" then count = 5
        elseif monsterId == "Wolf" then count = 4
        elseif monsterId == "Boar" then count = 3
        end
        
        for i = 1, count do
            local positions = spawnData.positions
            local posIndex = ((i - 1) % #positions) + 1
            local basePos = positions[posIndex]
            local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
            
            local monster = Instance.new("Part")
            monster.Name = monsterId
            monster.Size = monsterData.size
            monster.Position = basePos + offset + Vector3.new(0, monsterData.size.Y / 2, 0)
            monster.Anchored = true
            monster.CanCollide = true
            monster.Color = monsterData.color
            monster.Material = Enum.Material.SmoothPlastic
            
            if monsterData.shape == "Ball" then
                monster.Shape = Enum.PartType.Ball
            end
            
            -- Name tag
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 120, 0, 60)
            billboard.StudsOffset = Vector3.new(0, monsterData.size.Y + 1, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = monster
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = monsterData.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextScaled = true
            nameLabel.Parent = billboard
            
            local levelLabel = Instance.new("TextLabel")
            levelLabel.Size = UDim2.new(1, 0, 0.3, 0)
            levelLabel.Position = UDim2.new(0, 0, 0.5, 0)
            levelLabel.BackgroundTransparency = 1
            levelLabel.Text = "Lv." .. monsterData.level
            levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            levelLabel.TextStrokeTransparency = 0
            levelLabel.Font = Enum.Font.Gotham
            levelLabel.TextScaled = true
            levelLabel.Parent = billboard
            
            -- Attributes
            monster:SetAttribute("MonsterId", monsterId)
            monster:SetAttribute("CurrentHP", monsterData.hp)
            monster:SetAttribute("MaxHP", monsterData.hp)
            
            -- ClickDetector
            local click = Instance.new("ClickDetector")
            click.MaxActivationDistance = 20
            click.Parent = monster
            
            monster.Parent = monsterFolder
        end
    end
end

print("[Server] Monsters spawned!")

print("[Server] ==========================================")
print("[Server] Server ready!")
print("[Server] ==========================================")
