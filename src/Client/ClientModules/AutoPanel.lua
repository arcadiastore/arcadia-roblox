--[[
    AutoPanel.lua
    Auto Combat, Auto Skill, Auto Potion with Settings
]]

local AutoPanel = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- GUI elements
local gui, mainFrame = nil, nil
local settingsFrame = nil
local settingsOpen = false

-- State
local autoCombatEnabled = false
local autoSkillEnabled = true
local autoPotionEnabled = true

-- Settings (configurable)
local hpPotionThreshold = 50
local mpPotionThreshold = 30
local selectedHpPotion = "hp_potion_small"
local selectedMpPotion = "mp_potion_small"
local selectedSkillSlot = 1

-- Tracking
local currentTarget = nil
local currentData = nil
local potionInventory = {}
local lastPotionUse = 0
local POTION_COOLDOWN = 2
local lastSkillUse = 0
local SKILL_COOLDOWN = 1

-- Auto quest state
local autoQuestActive = false
local autoQuestPhase = "idle"
local autoQuestTarget = nil
local autoQuestNPC = nil
local autoQuestId = nil

local ATTACK_RANGE = 30
local currentWeaponRange = 8
local NPC_INTERACT_RANGE = 10

-- Labels
local hpPotionLabel = nil
local mpPotionLabel = nil
local hpThresholdLabel = nil
local mpThresholdLabel = nil

-- ============================================
-- UTILITY
-- ============================================

local function getGameData()
    local ok, data = pcall(function()
        return require(ReplicatedStorage:WaitForChild("GameData"))
    end)
    return ok and data or nil
end

local function getNearestMonster()
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then return nil end
    local nearest, nearestDist = nil, ATTACK_RANGE
    for _, monster in ipairs(monsterFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP") or 0
        if hp > 0 then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < nearestDist then nearestDist, nearest = dist, monster end
        end
    end
    return nearest, nearestDist
end

local function getMonsterByType(monsterType)
    local character = player.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    local monsterFolder = workspace:FindFirstChild("Monsters")
    if not monsterFolder then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, monster in ipairs(monsterFolder:GetChildren()) do
        local hp = monster:GetAttribute("CurrentHP") or 0
        local mId = monster:GetAttribute("MonsterId") or ""
        if hp > 0 and mId == monsterType then
            local dist = (monster.Position - rootPart.Position).Magnitude
            if dist < nearestDist then nearestDist, nearest = dist, monster end
        end
    end
    return nearest, nearestDist
end

local function getNPCPart(npcId)
    local npcFolder = workspace:FindFirstChild("NPCs")
    if not npcFolder then return nil end
    return npcFolder:FindFirstChild(npcId)
end

local function moveToward(targetPos)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid:MoveTo(targetPos) end
end

local function stopMoving()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoid and rootPart then humanoid:MoveTo(rootPart.Position) end
end

local function getDistTo(pos)
    local character = player.Character
    if not character then return math.huge end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return math.huge end
    return (pos - rootPart.Position).Magnitude
end

-- ============================================
-- AUTO SKILL
-- ============================================

local jobSkillMap = {
    Warrior = {"warrior_power_strike", "warrior_shout"},
    Mage = {"mage_fireball", "mage_ice_shield"},
    Archer = {"archer_arrow_rain", "archer_eagle_eye"},
}

local function tryAutoSkill(monsterTarget)
    if not autoSkillEnabled then return false end
    if not currentData or not currentData.job then return false end
    if not currentData.learnedSkills then return false end
    local now = tick()
    if now - lastSkillUse < SKILL_COOLDOWN then return false end
    
    local skills = jobSkillMap[currentData.job]
    if not skills then return false end
    
    -- Try selected slot first, then others
    local slotsToTry = {selectedSkillSlot}
    for i = 1, 4 do
        if i ~= selectedSkillSlot then table.insert(slotsToTry, i) end
    end
    
    for _, slot in ipairs(slotsToTry) do
        local skillId = skills[slot]
        if skillId and currentData.learnedSkills[skillId] then
            local GameData = getGameData()
            if GameData and GameData.Skills then
                local skillData = GameData.Skills[skillId]
                if skillData and (currentData.mp or 0) >= skillData.mpCost then
                    local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
                    local SkillEvent = EventsFolder and EventsFolder:FindFirstChild("SkillEvent")
                    if SkillEvent then
                        if skillData.type == "buff" or skillData.type == "heal" then
                            SkillEvent:FireServer({skillId = skillId, monsterPart = nil})
                            lastSkillUse = now
                            return true
                        elseif monsterTarget and monsterTarget.Parent and (monsterTarget:GetAttribute("CurrentHP") or 0) > 0 then
                            SkillEvent:FireServer({skillId = skillId, monsterPart = monsterTarget})
                            lastSkillUse = now
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- ============================================
-- AUTO POTION
-- ============================================

local function tryAutoPotion()
    if not autoPotionEnabled then return false end
    if not currentData then return false end
    local now = tick()
    if now - lastPotionUse < POTION_COOLDOWN then return false end
    
    local EventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local InventoryEvent = EventsFolder and EventsFolder:FindFirstChild("InventoryEvent")
    if not InventoryEvent then return false end
    
    -- HP check
    local hpPct = (currentData.hp or 0) / (currentData.maxHp or 100) * 100
    if hpPct < hpPotionThreshold then
        local count = potionInventory[selectedHpPotion] or 0
        if count > 0 then
            InventoryEvent:FireServer("use", {itemId = selectedHpPotion})
            lastPotionUse = now
            print("[AutoPanel] HP potion used! HP=" .. math.floor(hpPct) .. "%")
            return true
        end
    end
    
    -- MP check
    local mpPct = (currentData.mp or 0) / (currentData.maxMp or 50) * 100
    if mpPct < mpPotionThreshold then
        local count = potionInventory[selectedMpPotion] or 0
        if count > 0 then
            InventoryEvent:FireServer("use", {itemId = selectedMpPotion})
            lastPotionUse = now
            print("[AutoPanel] MP potion used! MP=" .. math.floor(mpPct) .. "%")
            return true
        end
    end
    return false
end

-- ============================================
-- COMBAT LOOPS
-- ============================================

local function autoCombatLoop()
    while autoCombatEnabled do
        if autoQuestActive then task.wait(0.5) continue end
        
        tryAutoPotion()
        
        -- Update target
        if currentTarget and (not currentTarget.Parent or (currentTarget:GetAttribute("CurrentHP") or 0) <= 0) then
            currentTarget = nil
            stopMoving()
        end
        
        if not currentTarget then currentTarget = getNearestMonster() end
        
        if currentTarget then
            local character = player.Character
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if rootPart and humanoid then
                    local dist = (currentTarget.Position - rootPart.Position).Magnitude
                    if dist <= currentWeaponRange then
                        stopMoving()
                        local usedSkill = tryAutoSkill(currentTarget)
                        if not usedSkill then
                            local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                            if AttackEvent then AttackEvent:FireServer(currentTarget) end
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

local function autoQuestLoop()
    while autoQuestActive do
        tryAutoPotion()
        if autoQuestPhase == "fighting" then
            if not autoQuestTarget then autoQuestPhase = "idle" task.wait(1) continue end
            if not currentTarget or not currentTarget.Parent or (currentTarget:GetAttribute("CurrentHP") or 0) <= 0 then
                currentTarget = getMonsterByType(autoQuestTarget)
            end
            if currentTarget then
                local dist = getDistTo(currentTarget.Position)
                if dist <= currentWeaponRange then
                    stopMoving()
                    local usedSkill = tryAutoSkill(currentTarget)
                    if not usedSkill then
                        local AttackEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("AttackEvent")
                        if AttackEvent then AttackEvent:FireServer(currentTarget) end
                    end
                else
                    moveToward(currentTarget.Position)
                end
            end
        elseif autoQuestPhase == "walking_to_npc" then
            if not autoQuestNPC then autoQuestPhase = "idle" task.wait(1) continue end
            local npcPart = getNPCPart(autoQuestNPC)
            if npcPart then
                local dist = getDistTo(npcPart.Position)
                if dist <= NPC_INTERACT_RANGE then stopMoving() autoQuestPhase = "reporting"
                else moveToward(npcPart.Position) end
            end
        elseif autoQuestPhase == "reporting" then
            stopMoving()
            local DialogueEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DialogueEvent")
            if DialogueEvent then DialogueEvent:FireServer("talk", {npcId = autoQuestNPC}) end
            task.wait(1)
            autoQuestActive = false
            autoQuestPhase = "idle"
            autoQuestId, autoQuestNPC, autoQuestTarget, currentTarget = nil, nil, nil, nil
        else
            task.wait(1)
        end
        task.wait(0.3)
    end
    currentTarget = nil
    autoQuestPhase = "idle"
    stopMoving()
end

-- ============================================
-- SETTINGS PANEL
-- ============================================

local function createSettingsPanel()
    settingsFrame = Instance.new("Frame")
    settingsFrame.Name = "SettingsPanel"
    settingsFrame.Size = UDim2.new(0, 260, 0, 380)
    settingsFrame.Position = UDim2.new(0.5, -130, 0.5, -190)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    settingsFrame.BackgroundTransparency = 0.05
    settingsFrame.BorderSizePixel = 0
    settingsFrame.Visible = false
    settingsFrame.Parent = gui
    Instance.new("UICorner", settingsFrame).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", settingsFrame).Color = Color3.fromRGB(100, 100, 200)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
    title.Text = "⚙ Auto Settings"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = settingsFrame
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        settingsFrame.Visible = false
        settingsOpen = false
    end)
    
    local y = 45
    
    -- Toggle Auto Skill
    local skillToggle = Instance.new("TextButton")
    skillToggle.Size = UDim2.new(0.9, 0, 0, 28)
    skillToggle.Position = UDim2.new(0.05, 0, 0, y)
    skillToggle.BackgroundColor3 = autoSkillEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 80)
    skillToggle.Text = "⚔ Auto Skill: ON"
    skillToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    skillToggle.TextSize = 13
    skillToggle.Font = Enum.Font.GothamBold
    skillToggle.Parent = settingsFrame
    Instance.new("UICorner", skillToggle).CornerRadius = UDim.new(0, 6)
    skillToggle.MouseButton1Click:Connect(function()
        autoSkillEnabled = not autoSkillEnabled
        skillToggle.BackgroundColor3 = autoSkillEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 80)
        skillToggle.Text = "⚔ Auto Skill: " .. (autoSkillEnabled and "ON" or "OFF")
    end)
    y = y + 32
    
    -- Skill slot selector
    local slotLabel = Instance.new("TextLabel")
    slotLabel.Size = UDim2.new(0.45, 0, 0, 18)
    slotLabel.Position = UDim2.new(0.05, 0, 0, y)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Text = "Priority Slot:"
    slotLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    slotLabel.TextSize = 11
    slotLabel.Font = Enum.Font.Gotham
    slotLabel.TextXAlignment = Enum.TextXAlignment.Left
    slotLabel.Parent = settingsFrame
    y = y + 20
    
    local slotButtons = {}
    for i = 1, 4 do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.2, 0, 0, 24)
        btn.Position = UDim2.new(0.05 + (i-1) * 0.23, 0, 0, y)
        btn.BackgroundColor3 = (i == selectedSkillSlot) and Color3.fromRGB(100, 100, 200) or Color3.fromRGB(50, 50, 70)
        btn.Text = "[" .. i .. "]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.Parent = settingsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function()
            selectedSkillSlot = i
            for j = 1, 4 do
                slotButtons[j].BackgroundColor3 = (j == i) and Color3.fromRGB(100, 100, 200) or Color3.fromRGB(50, 50, 70)
            end
        end)
        slotButtons[i] = btn
    end
    y = y + 30
    
    -- Separator
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(0.9, 0, 0, 1)
    sep.Position = UDim2.new(0.05, 0, 0, y)
    sep.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    sep.BorderSizePixel = 0
    sep.Parent = settingsFrame
    y = y + 8
    
    -- Toggle Auto Potion
    local potionToggle = Instance.new("TextButton")
    potionToggle.Size = UDim2.new(0.9, 0, 0, 28)
    potionToggle.Position = UDim2.new(0.05, 0, 0, y)
    potionToggle.BackgroundColor3 = autoPotionEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 80)
    potionToggle.Text = "🧪 Auto Potion: ON"
    potionToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    potionToggle.TextSize = 13
    potionToggle.Font = Enum.Font.GothamBold
    potionToggle.Parent = settingsFrame
    Instance.new("UICorner", potionToggle).CornerRadius = UDim.new(0, 6)
    potionToggle.MouseButton1Click:Connect(function()
        autoPotionEnabled = not autoPotionEnabled
        potionToggle.BackgroundColor3 = autoPotionEnabled and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(80, 80, 80)
        potionToggle.Text = "🧪 Auto Potion: " .. (autoPotionEnabled and "ON" or "OFF")
    end)
    y = y + 35
    
    -- HP Potion section
    hpThresholdLabel = Instance.new("TextLabel")
    hpThresholdLabel.Size = UDim2.new(0.9, 0, 0, 18)
    hpThresholdLabel.Position = UDim2.new(0.05, 0, 0, y)
    hpThresholdLabel.BackgroundTransparency = 1
    hpThresholdLabel.Text = "❤ HP Potion at: " .. hpPotionThreshold .. "%"
    hpThresholdLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    hpThresholdLabel.TextSize = 12
    hpThresholdLabel.Font = Enum.Font.GothamBold
    hpThresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
    hpThresholdLabel.Parent = settingsFrame
    y = y + 20
    
    local hpButtons = {}
    for _, pct in ipairs({25, 50, 75}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.28, 0, 0, 22)
        btn.Position = UDim2.new(0.05 + (_-1) * 0.31, 0, 0, y)
        btn.BackgroundColor3 = (hpPotionThreshold == pct) and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 50, 70)
        btn.Text = pct .. "%"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = settingsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        hpButtons[pct] = btn
        btn.MouseButton1Click:Connect(function()
            hpPotionThreshold = pct
            hpThresholdLabel.Text = "❤ HP Potion at: " .. pct .. "%"
            for p, b in pairs(hpButtons) do
                b.BackgroundColor3 = (p == pct) and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(50, 50, 70)
            end
        end)
    end
    y = y + 28
    
    -- HP Potion selector
    hpPotionLabel = Instance.new("TextLabel")
    hpPotionLabel.Size = UDim2.new(0.7, 0, 0, 22)
    hpPotionLabel.Position = UDim2.new(0.05, 0, 0, y)
    hpPotionLabel.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
    hpPotionLabel.Text = "  " .. selectedHpPotion .. " x0"
    hpPotionLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
    hpPotionLabel.TextSize = 11
    hpPotionLabel.Font = Enum.Font.GothamBold
    hpPotionLabel.TextXAlignment = Enum.TextXAlignment.Left
    hpPotionLabel.Parent = settingsFrame
    Instance.new("UICorner", hpPotionLabel).CornerRadius = UDim.new(0, 4)
    
    local hpCycle = Instance.new("TextButton")
    hpCycle.Size = UDim2.new(0.2, 0, 0, 22)
    hpCycle.Position = UDim2.new(0.77, 0, 0, y)
    hpCycle.BackgroundColor3 = Color3.fromRGB(100, 60, 60)
    hpCycle.Text = "Change >"
    hpCycle.TextColor3 = Color3.fromRGB(255, 255, 255)
    hpCycle.TextSize = 10
    hpCycle.Font = Enum.Font.GothamBold
    hpCycle.Parent = settingsFrame
    Instance.new("UICorner", hpCycle).CornerRadius = UDim.new(0, 4)
    hpCycle.MouseButton1Click:Connect(function()
        local potions = {"hp_potion_small", "hp_potion_medium", "hp_potion_large"}
        local idx = table.find(potions, selectedHpPotion) or 1
        selectedHpPotion = potions[(idx % #potions) + 1]
        AutoPanel:UpdatePotionDisplay()
    end)
    y = y + 28
    
    -- Separator
    local sep2 = Instance.new("Frame")
    sep2.Size = UDim2.new(0.9, 0, 0, 1)
    sep2.Position = UDim2.new(0.05, 0, 0, y)
    sep2.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    sep2.BorderSizePixel = 0
    sep2.Parent = settingsFrame
    y = y + 8
    
    -- MP Potion section
    mpThresholdLabel = Instance.new("TextLabel")
    mpThresholdLabel.Size = UDim2.new(0.9, 0, 0, 18)
    mpThresholdLabel.Position = UDim2.new(0.05, 0, 0, y)
    mpThresholdLabel.BackgroundTransparency = 1
    mpThresholdLabel.Text = "💙 MP Potion at: " .. mpPotionThreshold .. "%"
    mpThresholdLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    mpThresholdLabel.TextSize = 12
    mpThresholdLabel.Font = Enum.Font.GothamBold
    mpThresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
    mpThresholdLabel.Parent = settingsFrame
    y = y + 20
    
    local mpButtons = {}
    for _, pct in ipairs({25, 50, 75}) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.28, 0, 0, 22)
        btn.Position = UDim2.new(0.05 + (_-1) * 0.31, 0, 0, y)
        btn.BackgroundColor3 = (mpPotionThreshold == pct) and Color3.fromRGB(50, 50, 200) or Color3.fromRGB(50, 50, 70)
        btn.Text = pct .. "%"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = settingsFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        mpButtons[pct] = btn
        btn.MouseButton1Click:Connect(function()
            mpPotionThreshold = pct
            mpThresholdLabel.Text = "💙 MP Potion at: " .. pct .. "%"
            for p, b in pairs(mpButtons) do
                b.BackgroundColor3 = (p == pct) and Color3.fromRGB(50, 50, 200) or Color3.fromRGB(50, 50, 70)
            end
        end)
    end
    y = y + 28
    
    -- MP Potion selector
    mpPotionLabel = Instance.new("TextLabel")
    mpPotionLabel.Size = UDim2.new(0.7, 0, 0, 22)
    mpPotionLabel.Position = UDim2.new(0.05, 0, 0, y)
    mpPotionLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    mpPotionLabel.Text = "  " .. selectedMpPotion .. " x0"
    mpPotionLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    mpPotionLabel.TextSize = 11
    mpPotionLabel.Font = Enum.Font.GothamBold
    mpPotionLabel.TextXAlignment = Enum.TextXAlignment.Left
    mpPotionLabel.Parent = settingsFrame
    Instance.new("UICorner", mpPotionLabel).CornerRadius = UDim.new(0, 4)
    
    local mpCycle = Instance.new("TextButton")
    mpCycle.Size = UDim2.new(0.2, 0, 0, 22)
    mpCycle.Position = UDim2.new(0.77, 0, 0, y)
    mpCycle.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    mpCycle.Text = "Change >"
    mpCycle.TextColor3 = Color3.fromRGB(255, 255, 255)
    mpCycle.TextSize = 10
    mpCycle.Font = Enum.Font.GothamBold
    mpCycle.Parent = settingsFrame
    Instance.new("UICorner", mpCycle).CornerRadius = UDim.new(0, 4)
    mpCycle.MouseButton1Click:Connect(function()
        local potions = {"mp_potion_small", "mp_potion_medium", "mp_potion_large"}
        local idx = table.find(potions, selectedMpPotion) or 1
        selectedMpPotion = potions[(idx % #potions) + 1]
        AutoPanel:UpdatePotionDisplay()
    end)
end

-- ============================================
-- MAIN UI
-- ============================================

function AutoPanel:Create(parentGui)
    gui = Instance.new("ScreenGui")
    gui.Name = "AutoPanel"
    gui.ResetOnSpawn = false
    gui.Parent = parentGui
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 45)
    mainFrame.Position = UDim2.new(0.5, -100, 1, -55)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    
    autoCombatBtn = Instance.new("TextButton")
    autoCombatBtn.Size = UDim2.new(0.55, 0, 0.8, 0)
    autoCombatBtn.Position = UDim2.new(0.02, 0, 0.1, 0)
    autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoCombatBtn.Text = "Auto [OFF]"
    autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    autoCombatBtn.Font = Enum.Font.GothamBold
    autoCombatBtn.TextScaled = true
    autoCombatBtn.Parent = mainFrame
    Instance.new("UICorner", autoCombatBtn).CornerRadius = UDim.new(0, 8)
    
    local settingsBtn = Instance.new("TextButton")
    settingsBtn.Size = UDim2.new(0.38, 0, 0.8, 0)
    settingsBtn.Position = UDim2.new(0.6, 0, 0.1, 0)
    settingsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    settingsBtn.Text = "⚙"
    settingsBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
    settingsBtn.Font = Enum.Font.GothamBold
    settingsBtn.TextScaled = true
    settingsBtn.Parent = mainFrame
    Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 8)
    
    createSettingsPanel()
    
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
            currentTarget = nil
            stopMoving()
        end
    end)
    
    settingsBtn.MouseButton1Click:Connect(function()
        settingsOpen = not settingsOpen
        settingsFrame.Visible = settingsOpen
        settingsBtn.BackgroundColor3 = settingsOpen and Color3.fromRGB(100, 100, 180) or Color3.fromRGB(60, 60, 100)
    end)
    
    print("[AutoPanel] Created!")
end

function AutoPanel:UpdatePotionDisplay()
    if hpPotionLabel then
        local count = potionInventory[selectedHpPotion] or 0
        local displayName = selectedHpPotion:gsub("hp_potion_", "HP "):gsub("_", " ")
        hpPotionLabel.Text = "  " .. displayName .. " x" .. count
    end
    if mpPotionLabel then
        local count = potionInventory[selectedMpPotion] or 0
        local displayName = selectedMpPotion:gsub("mp_potion_", "MP "):gsub("_", " ")
        mpPotionLabel.Text = "  " .. displayName .. " x" .. count
    end
end

function AutoPanel:Update(data)
    if data then
        currentData = data
        -- Update potion inventory
        if data.inventory then
            potionInventory = {}
            for _, item in ipairs(data.inventory) do
                if item.itemId and item.count then
                    potionInventory[item.itemId] = (potionInventory[item.itemId] or 0) + item.count
                end
            end
            self:UpdatePotionDisplay()
        end
        -- Update weapon range
        if data.equipment then
            local GameData = getGameData()
            if GameData and GameData.GetAttackRange then
                currentWeaponRange = GameData:GetAttackRange(data)
            end
        end
    end
end

function AutoPanel:IsOpen() return settingsOpen end

-- ============================================
-- AUTO QUEST
-- ============================================

function AutoPanel:StartAutoQuest(questId, monsterType, npcId)
    if autoQuestActive then return end
    autoQuestActive = true
    autoQuestPhase = "fighting"
    autoQuestId = questId
    autoQuestTarget = monsterType
    autoQuestNPC = npcId
    currentTarget = nil
    
    if autoCombatEnabled then
        autoCombatEnabled = false
        autoCombatBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        autoCombatBtn.Text = "Quest [ON]"
        autoCombatBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
    end
    
    task.spawn(autoQuestLoop)
    print("[AutoPanel] Auto quest started: " .. monsterType)
end

function AutoPanel:StopAutoQuest()
    autoQuestActive = false
    autoQuestPhase = "idle"
    autoQuestId, autoQuestNPC, autoQuestTarget, currentTarget = nil, nil, nil, nil
    stopMoving()
    autoCombatBtn.Text = "Auto [OFF]"
    autoCombatBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end

function AutoPanel:QuestReady(questId)
    if autoQuestActive and autoQuestPhase == "fighting" then
        autoQuestPhase = "walking_to_npc"
        currentTarget = nil
        stopMoving()
    end
end

return AutoPanel
