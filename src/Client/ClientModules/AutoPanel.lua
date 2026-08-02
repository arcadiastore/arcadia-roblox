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
local currentTarget = nil

-- Auto quest state
local autoQuestActive = false
local autoQuestPhase = "idle"  -- "idle", "fighting", "walking_to_npc", "reporting"
local autoQuestTarget = nil  -- monster type to kill
local autoQuestNPC = nil  -- NPC to report to
local autoQuestId = nil  -- current quest ID

local ATTACK_RANGE = 30  -- Find monsters within this range
local MELEE_RANGE = 8    -- Default fist range (overridden by weapon)
local NPC_INTERACT_RANGE = 10  -- Must be close to talk to NPC

-- Current weapon range (updated from server)
local currentWeaponRange = 8

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

-- Move toward target (called repeatedly)
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

-- Interact with NPC
local function interactNPC(npcId)
    local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
    if DialogueEvent then
        DialogueEvent:FireServer("talk", {npcId = npcId})
    end
end

-- Send dialogue response
local function sendResponse(text, npcId)
    local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
    if DialogueEvent and npcId then
        DialogueEvent:FireServer("respond", {responseText = text, npcId = npcId})
    end
end

-- Report quest and accept next
local function doReporting(npcId, questId)
    -- Step 1: Talk to NPC (establishes dialogue state)
    interactNPC(npcId)
    task.wait(2)  -- Wait for dialogue state
    
    -- Step 2: Complete quest - take reward
    sendResponse("Terima kasih! (Ambil Reward)", npcId)
    task.wait(1.5)
    
    -- Step 3: Close any remaining dialogue
    sendResponse("Sama-sama!", npcId)
    task.wait(1)
    sendResponse("exit", npcId)
    task.wait(1)
    
    -- Step 4: Talk again to accept new quest
    interactNPC(npcId)
    task.wait(2)
    sendResponse("Saya terima quest ini!", npcId)
    task.wait(1)
    sendResponse("Saya akan membantu!", npcId)
    task.wait(1)
    sendResponse("exit", npcId)
    task.wait(0.5)
    
    print("[AutoPanel] Reporting done for quest: " .. tostring(questId))
end

-- Main auto quest loop
local function autoQuestLoop()
    while autoQuestActive do
        -- Phase: Fighting
        if autoQuestPhase == "fighting" then
            if not autoQuestTarget then
                autoQuestPhase = "idle"
                task.wait(1)
                continue
            end
            
            -- Double-check phase didn't change (e.g. QuestReady)
            if autoQuestPhase ~= "fighting" then
                continue
            end
            
            -- Find and attack quest monsters
            if not currentTarget or not currentTarget.Parent or (currentTarget:GetAttribute("CurrentHP") or 0) <= 0 then
                currentTarget = getMonsterByType(autoQuestTarget)
            end
            
            if currentTarget then
                local dist = getDistTo(currentTarget.Position)
                if dist <= currentWeaponRange then
                    stopMoving()
                    local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                    if AttackEvent then
                        AttackEvent:FireServer(currentTarget)
                    end
                else
                    moveToward(currentTarget.Position)
                end
            end
            
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
                    stopMoving()
                    autoQuestPhase = "reporting"
                else
                    moveToward(npcPart.Position)
                end
            end
            
        -- Phase: Reporting to NPC
        elseif autoQuestPhase == "reporting" then
            stopMoving()
            doReporting(autoQuestNPC, autoQuestId)
            
            -- Reset for next cycle
            autoQuestPhase = "idle"
            local prevNPC = autoQuestNPC
            autoQuestId = nil
            autoQuestNPC = nil
            autoQuestTarget = nil
            currentTarget = nil
            
            -- Wait then restart cycle with same NPC
            task.wait(3)
            
            -- Check if there's a new quest from same NPC
            -- The doReporting should have accepted new quest
            -- Reset to fighting if we have a new quest target
            autoQuestPhase = "idle"
            
        -- Phase: Idle
        elseif autoQuestPhase == "idle" then
            task.wait(1)
        end
        
        task.wait(0.3)
    end
    
    currentTarget = nil
    autoQuestPhase = "idle"
    stopMoving()
end

-- Auto combat loop (only when auto quest NOT active)
local function autoCombatLoop()
    while autoCombatEnabled do
        -- SKIP entirely if auto quest is running (quest loop handles combat)
        if autoQuestActive then
            task.wait(1)
            continue
        end
        
        if currentTarget then
            local hp = currentTarget:GetAttribute("CurrentHP") or 0
            if hp <= 0 or not currentTarget.Parent then
                currentTarget = nil
                stopMoving()
            end
        end
        
        if not currentTarget then
            currentTarget = getNearestMonster()
        end
        
        if currentTarget then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if rootPart and humanoid then
                    local dist = (currentTarget.Position - rootPart.Position).Magnitude
                    if dist <= currentWeaponRange then
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

-- Start auto quest
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
    
    task.spawn(autoQuestLoop)
    print("[AutoPanel] Auto Quest: kill " .. tostring(monsterType) .. " -> " .. tostring(npcId))
end

-- Called when server says quest is ready to complete
function AutoPanel:QuestReady(questId)
    if autoQuestActive and autoQuestId == questId then
        if autoQuestPhase == "fighting" or autoQuestPhase == "idle" then
            autoQuestPhase = "walking_to_npc"
            currentTarget = nil
            stopMoving()  -- Stop immediately
            print("[AutoPanel] Quest ready! Walking to NPC: " .. tostring(autoQuestNPC))
        end
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
end

function AutoPanel:Create(playerGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "AutoPanel"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(0.5, -75, 1, -50)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
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
    -- Update weapon range from equipped items
    if data.equipment then
        local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
        local weaponId = data.equipment.weapon2h or data.equipment.weapon1h
        if weaponId then
            local itemData = GameData:GetItem(weaponId)
            if itemData and itemData.range then
                currentWeaponRange = itemData.range
            else
                currentWeaponRange = 8  -- default melee
            end
        else
            currentWeaponRange = 6  -- fist
        end
    end
    
    -- Check quest completion from server data
    if autoQuestActive and autoQuestId and data.activeQuests then
        local quest = data.activeQuests[autoQuestId]
        if quest and quest.readyToComplete and autoQuestPhase == "fighting" then
            autoQuestPhase = "walking_to_npc"
            currentTarget = nil
            print("[AutoPanel] Quest ready from Update! Walking to NPC")
        elseif not quest then
            -- Quest completed, try restart with same NPC
            if autoQuestActive and autoQuestNPC then
                task.wait(2)
                -- Talk to NPC for new quest
                autoQuestPhase = "reporting"
            end
        end
    end
end

function AutoPanel:IsAutoCombat()
    return autoCombatEnabled
end

return AutoPanel
