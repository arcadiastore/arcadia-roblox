--[[
    AutoPanel.lua
    Auto Combat toggle + Full Auto Quest loop
    Auto Quest: fight → complete → walk to NPC → report → next quest
]]

local AutoPanel = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

local gui, frame = nil, nil
local autoCombatBtn = nil
local autoCombatEnabled = false
local currentTarget = nil  -- Lock target until dead

-- Auto quest state
local autoQuestActive = false
local autoQuestPhase = "idle"  -- "idle", "fighting", "walking_to_npc", "reporting", "walking_to_monster"
local autoQuestTarget = nil  -- monster type to kill
local autoQuestNPC = nil  -- NPC to report to
local autoQuestId = nil  -- current quest ID

local ATTACK_RANGE = 30
local NPC_INTERACT_RANGE = 12

-- Get GameData
local function getGameData()
    local ok, data = pcall(function()
        return require(ReplicatedStorage:WaitForChild("GameData"))
    end)
    return ok and data or nil
end

-- Get specific monster by type (no range limit)
local function getMonsterByType(monsterType)
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then return nil end
    
    local nearest = nil
    local nearestDist = math.huge
    
    for _, monster in ipairs(monsterFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP") or 0
        local mId = monster:GetAttribute("MonsterId") or ""
        if hp > 0 and mId == monsterType then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = monster
            end
        end
    end
    
    return nearest, nearestDist
end

-- Get nearest monster (any type)
local function getNearestMonster()
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then return nil end
    
    local nearest = nil
    local nearestDist = ATTACK_RANGE
    
    for _, monster in ipairs(monsterFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP") or 0
        if hp > 0 then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = monster
            end
        end
    end
    
    return nearest, nearestDist
end

-- Get NPC part
local function getNPCPart(npcId)
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    return npcFolder:FindFirstChild(npcId)
end

-- Move toward target
local function moveToward(targetPos)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    humanoid:MoveTo(targetPos)
end

-- Stop moving
local function stopMoving()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        humanoid:MoveTo(rootPart.Position)
    end
end

-- Get distance to position
local function getDistTo(pos)
    local character = player.Character
    if not character then return math.huge end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end
    return (pos - rootPart.Position).Magnitude
end

-- Check if quest objectives are complete
local function isQuestComplete(questId, progress)
    local GameData = getGameData()
    if not GameData then return false end
    
    local questData = GameData:GetQuest(questId)
    if not questData then return false end
    
    for i, obj in ipairs(questData.objectives) do
        local prog = progress and progress[i] or 0
        if prog < obj.count then
            return false
        end
    end
    return true
end

-- Find quest target monster type from objectives
local function getQuestMonsterType(questId)
    local GameData = getGameData()
    if not GameData then return nil end
    
    local questData = GameData:GetQuest(questId)
    if not questData then return nil end
    
    for _, obj in ipairs(questData.objectives) do
        if obj.type == "kill" and obj.target then
            return obj.target
        end
    end
    return nil
end

-- Find quest giver NPC
local function getQuestGiver(questId)
    local GameData = getGameData()
    if not GameData then return nil end
    
    local questData = GameData:GetQuest(questId)
    if not questData then return nil end
    
    return questData.giver
end

-- Interact with NPC (click)
local function clickNPC(npcPart)
    if not npcPart then return end
    local clickDetector = npcPart:FindFirstChild("ClickDetector")
    if clickDetector then
        -- Fire click event
        local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
        if DialogueEvent then
            local npcId = npcPart:GetAttribute("NPCId") or npcPart.Name
            DialogueEvent:FireServer("talk", npcId)
        end
    end
end

-- Auto report to NPC: send quest complete response
local function reportToNPC(questId)
    local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
    if DialogueEvent then
        DialogueEvent:FireServer("respond", "quest_complete_" .. questId)
        task.wait(0.5)
        -- Also try generic complete
        DialogueEvent:FireServer("respond", "Ambil reward!")
        task.wait(0.5)
        DialogueEvent:FireServer("respond", "Terima kasih!")
    end
end

-- Auto accept next quest from NPC
local function tryAcceptNextQuest(npcId)
    task.wait(0.5)
    local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
    if DialogueEvent then
        -- Try to accept quest
        DialogueEvent:FireServer("respond", "Saya terima quest ini!")
        task.wait(0.5)
        DialogueEvent:FireServer("respond", "Saya akan membantu!")
        task.wait(0.5)
        DialogueEvent:FireServer("respond", "Baik!")
        task.wait(0.5)
        DialogueEvent:FireServer("respond", "Sama-sama!")
    end
end

-- Main auto quest loop
local function autoQuestLoop()
    while autoQuestActive do
        -- Find active quest info
        local playerData = nil
        local GetDataEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("GetDataEvent")
        -- We'll track via HUD updates
        
        -- Phase: Fighting
        if autoQuestPhase == "fighting" then
            if not autoQuestTarget then
                -- No target, stop
                autoQuestPhase = "idle"
                task.wait(1)
                continue
            end
            
            -- Find and attack quest monsters
            if not currentTarget or not currentTarget.Parent or (currentTarget:GetAttribute("CurrentHP") or 0) <= 0 then
                currentTarget = getMonsterByType(autoQuestTarget)
            end
            
            if currentTarget then
                local dist = getDistTo(currentTarget.Position)
                if dist <= 15 then
                    stopMoving()
                    local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                    if AttackEvent then
                        AttackEvent:FireServer(currentTarget)
                    end
                else
                    moveToward(currentTarget.Position)
                end
            end
            
            -- Check if quest complete (will be updated via server)
            -- Transition to reporting happens when server sends quest ready
            
        -- Phase: Walking to NPC
        elseif autoQuestPhase == "walking_to_npc" then
            if not autoQuestNPC then
                autoQuestPhase = "idle"
                task.wait(1)
                continue
            end
            
            local npcPart = getNPCPart(autoQuestNPC)
            if npcPart then
                local dist = getDistTo(npcPart.Position)
                if dist <= NPC_INTERACT_RANGE then
                    -- Arrived at NPC
                    stopMoving()
                    autoQuestPhase = "reporting"
                else
                    moveToward(npcPart.Position)
                end
            end
            
        -- Phase: Reporting to NPC
        elseif autoQuestPhase == "reporting" then
            -- Talk to NPC
            local npcPart = getNPCPart(autoQuestNPC)
            if npcPart then
                clickNPC(npcPart)
                task.wait(1)
                reportToNPC(autoQuestId)
                task.wait(1)
                
                -- Try accept next quest
                tryAcceptNextQuest(autoQuestNPC)
                task.wait(1)
                
                -- Close dialogue
                local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
                if DialogueEvent then
                    DialogueEvent:FireServer("respond", "exit")
                end
                
                -- Reset for next quest cycle
                autoQuestPhase = "idle"
                autoQuestId = nil
                autoQuestNPC = nil
                autoQuestTarget = nil
                currentTarget = nil
                
                -- Wait a bit then check for new quest
                task.wait(2)
            else
                autoQuestPhase = "idle"
            end
            
        -- Phase: Idle - wait for quest assignment
        elseif autoQuestPhase == "idle" then
            -- Wait for quest to be set via StartAutoQuest
            task.wait(1)
        end
        
        task.wait(0.3)
    end
    
    currentTarget = nil
    autoQuestPhase = "idle"
    stopMoving()
end

-- Auto combat loop (independent of quest)
local function autoCombatLoop()
    while autoCombatEnabled do
        -- Check if current target is still valid
        if currentTarget then
            local hp = currentTarget:GetAttribute("CurrentHP") or 0
            if hp <= 0 or not currentTarget.Parent then
                currentTarget = nil
                stopMoving()
            end
        end
        
        -- Find target if none
        if not currentTarget then
            if autoQuestActive and autoQuestTarget then
                currentTarget = getMonsterByType(autoQuestTarget)
            end
            if not currentTarget then
                currentTarget = getNearestMonster()
            end
        end
        
        -- Attack or move
        if currentTarget then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if rootPart and humanoid then
                    local dist = (currentTarget.Position - rootPart.Position).Magnitude
                    if dist <= 15 then
                        stopMoving()
                        local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                        if AttackEvent then
                            AttackEvent:FireServer(currentTarget)
                        end
                    else
                        humanoid:MoveTo(currentTarget.Position)
                    end
                end
            end
        end
        
        task.wait(0.3)
    end
    
    currentTarget = nil
    stopMoving()
end

-- Start auto quest (called when clicking quest in tracker)
function AutoPanel:StartAutoQuest(monsterType, questId, npcId)
    autoQuestActive = true
    autoQuestTarget = monsterType
    autoQuestId = questId
    autoQuestNPC = npcId
    autoQuestPhase = "fighting"
    currentTarget = nil
    
    -- Enable auto combat too
    if not autoCombatEnabled then
        autoCombatEnabled = true
        autoCombatBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        autoCombatBtn.Text = "Auto [ON]"
        autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        task.spawn(autoCombatLoop)
    end
    
    -- Start quest loop if not running
    task.spawn(autoQuestLoop)
    
    print("[AutoPanel] Auto Quest started: kill " .. tostring(monsterType) .. " -> report to " .. tostring(npcId))
end

-- Called when server says quest is ready to complete
function AutoPanel:QuestReady(questId)
    if autoQuestActive and autoQuestId == questId then
        autoQuestPhase = "walking_to_npc"
        currentTarget = nil
        print("[AutoPanel] Quest ready, walking to NPC: " .. tostring(autoQuestNPC))
    end
end

-- Stop auto quest
function AutoPanel:StopAutoQuest()
    autoQuestActive = false
    autoQuestPhase = "idle"
    autoQuestTarget = nil
    autoQuestNPC = nil
    autoQuestId = nil
    currentTarget = nil
    stopMoving()
    print("[AutoPanel] Auto Quest stopped")
end

function AutoPanel:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "AutoPanel"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    -- Panel frame (bottom center)
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(0.5, -75, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    -- Auto Combat toggle button
    autoCombatBtn = Instance.new("TextButton")
    autoCombatBtn.Size = UDim2.new(0.95, 0, 0.8, 0)
    autoCombatBtn.Position = UDim2.new(0.025, 0, 0.1, 0)
    autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoCombatBtn.Text = "Auto [OFF]"
    autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    autoCombatBtn.Font = Enum.Font.GothamBold
    autoCombatBtn.TextScaled = true
    autoCombatBtn.Parent = frame
    Instance.new("UICorner", autoCombatBtn).CornerRadius = UDim.new(0, 6)
    
    -- Toggle Auto Combat
    autoCombatBtn.MouseButton1Click:Connect(function()
        autoCombatEnabled = not autoCombatEnabled
        if autoCombatEnabled then
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            autoCombatBtn.Text = "Auto [ON]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            currentTarget = nil
            task.spawn(autoCombatLoop)
        else
            autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            autoCombatBtn.Text = "Auto [OFF]"
            autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            autoQuestActive = false
            autoQuestPhase = "idle"
            autoQuestTarget = nil
            autoQuestNPC = nil
            autoQuestId = nil
            currentTarget = nil
            stopMoving()
        end
    end)
    
    print("[AutoPanel] Created!")
end

function AutoPanel:Update(data)
    -- Check if current auto quest is complete
    if autoQuestActive and autoQuestId and data.activeQuests then
        local quest = data.activeQuests[autoQuestId]
        if quest and quest.readyToComplete then
            -- Quest ready, switch to walking to NPC
            if autoQuestPhase == "fighting" then
                autoQuestPhase = "walking_to_npc"
                currentTarget = nil
                print("[AutoPanel] Quest ready! Walking to NPC...")
            end
        elseif not quest then
            -- Quest completed or removed
            if autoQuestPhase == "idle" and autoQuestActive then
                -- Try to find and accept next quest from same NPC
                if autoQuestNPC then
                    -- Restart cycle - talk to NPC for new quest
                    autoQuestPhase = "reporting"
                end
            end
        end
    end
end

function AutoPanel:IsAutoCombat()
    return autoCombatEnabled
end

return AutoPanel
