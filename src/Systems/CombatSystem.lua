--[[
    Arcadia Online - Combat System (v2 - Data-Driven)
    
    Semua data dari GameData module
    Tidak ada hardcode!
    
    Place di: ServerScriptService/Systems (as Script)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[Combat] Combat System initializing...")

-- ============================================
-- COMBAT MANAGER
-- ============================================

local CombatManager = {}
CombatManager.__index = CombatManager

function CombatManager.new()
    local self = setmetatable({}, CombatManager)
    self.playerStats = {}
    return self
end

function CombatManager:Init()
    self:SetupPlayerConnections()
    self:SetupCombatEvents()
    
    -- Create Events folder if not exists
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then
        eventsFolder = Instance.new("Folder")
        eventsFolder.Name = "Events"
        eventsFolder.Parent = ReplicatedStorage
    end
    
    print("[Combat] Combat System initialized!")
end

function CombatManager:SetupPlayerConnections()
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

function CombatManager:OnPlayerAdded(player)
    self.playerStats[player.UserId] = {
        level = 1,
        exp = 0,
        gold = 100,
        atk = 10,
        def = 5,
        hp = 100,
        maxHp = 100,
        expToNextLevel = 100,
    }
    print("[Combat] Player stats initialized: " .. player.Name)
end

function CombatManager:OnPlayerRemoving(player)
    self.playerStats[player.UserId] = nil
end

function CombatManager:SetupCombatEvents()
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    
    local attackEvent = Instance.new("RemoteEvent")
    attackEvent.Name = "AttackMonster"
    attackEvent.Parent = eventsFolder
    
    local combatFeedback = Instance.new("RemoteEvent")
    combatFeedback.Name = "CombatFeedback"
    combatFeedback.Parent = eventsFolder
    
    attackEvent.OnServerEvent:Connect(function(player, monsterPart)
        self:HandleAttack(player, monsterPart)
    end)
end

function CombatManager:HandleAttack(player, monsterPart)
    if not monsterPart or not monsterPart.Parent then return end
    
    local monsterId = monsterPart:GetAttribute("MonsterId")
    if not monsterId then return end
    
    local playerStats = self.playerStats[player.UserId]
    if not playerStats then return end
    
    -- Get monster data from GameData
    local monsterData = GameData:GetMonster(monsterId)
    if not monsterData then return end
    
    -- Get current HP from attribute
    local monsterHP = monsterPart:GetAttribute("HP")
    local monsterDEF = monsterData.def
    
    -- Calculate damage
    local damage = math.max(1, playerStats.atk - monsterDEF)
    
    -- Random critical (10% chance)
    local isCrit = math.random(1, 100) <= 10
    if isCrit then
        damage = damage * 2
    end
    
    -- Apply damage
    local newHP = monsterHP - damage
    monsterPart:SetAttribute("HP", newHP)
    
    -- Update health bar
    local humanoid = monsterPart.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = newHP
    end
    
    -- Send feedback
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    local combatFeedback = eventsFolder:FindFirstChild("CombatFeedback")
    if combatFeedback then
        combatFeedback:FireClient(player, {
            type = "DamageDealt",
            target = monsterData.name,
            damage = damage,
            isCrit = isCrit,
            targetHP = newHP,
            targetMaxHP = monsterData.hp,
        })
    end
    
    print("[Combat] " .. player.Name .. " dealt " .. damage .. " damage to " .. monsterData.name)
    
    -- Check death
    if newHP <= 0 then
        self:HandleMonsterDeath(player, monsterPart, monsterData)
    end
end

function CombatManager:HandleMonsterDeath(player, monsterPart, monsterData)
    print("[Combat] " .. monsterData.name .. " defeated by " .. player.Name)
    
    -- Give rewards from GameData
    local playerStats = self.playerStats[player.UserId]
    if playerStats then
        playerStats.exp = playerStats.exp + monsterData.exp
        playerStats.gold = playerStats.gold + monsterData.gold
        
        -- Check level up
        self:CheckLevelUp(player, playerStats)
        
        -- Send feedback
        local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
        local combatFeedback = eventsFolder:FindFirstChild("CombatFeedback")
        if combatFeedback then
            combatFeedback:FireClient(player, {
                type = "MonsterDefeated",
                monsterName = monsterData.name,
                expReward = monsterData.exp,
                goldReward = monsterData.gold,
                totalExp = playerStats.exp,
                totalGold = playerStats.gold,
                level = playerStats.level,
            })
        end
        
        print("[Combat] Rewards: +" .. monsterData.exp .. " EXP, +" .. monsterData.gold .. " Gold")
        
        -- Handle drops from GameData
        self:HandleDrops(player, monsterData)
        
        -- Update ALL active quests
        if _G.QuestManager then
            local playerQuestData = _G.QuestManager:GetPlayerQuests(player)
            if playerQuestData and playerQuestData.activeQuests then
                for questId, quest in pairs(playerQuestData.activeQuests) do
                    _G.QuestManager:UpdateQuestProgress(player, questId, "kill", monsterData.id, 1)
                end
            end
        end
    end
    
    -- Respawn monster using GameData respawnTime
    local model = monsterPart.Parent
    if model then
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        
        local clickDetector = monsterPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            clickDetector.MaxActivationDistance = 0
        end
        
        task.delay(monsterData.respawnTime, function()
            monsterPart:SetAttribute("HP", monsterData.hp)
            
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = monsterData.hp
            end
            
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
            
            if clickDetector then
                clickDetector.MaxActivationDistance = 20
            end
            
            print("[Combat] " .. monsterData.name .. " respawned!")
        end)
    end
end

function CombatManager:HandleDrops(player, monsterData)
    if not monsterData.drops then return end
    
    for _, drop in ipairs(monsterData.drops) do
        if math.random() <= drop.chance then
            local itemData = GameData:GetItem(drop.itemId)
            if itemData then
                -- Add to inventory (if ShopManager exists)
                if _G.ShopManager then
                    _G.ShopManager:AddToInventory(player, drop.itemId, 1)
                end
                
                -- Notify player
                local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
                local combatFeedback = eventsFolder:FindFirstChild("CombatFeedback")
                if combatFeedback then
                    combatFeedback:FireClient(player, {
                        type = "ItemDropped",
                        itemName = itemData.name,
                        itemId = drop.itemId,
                    })
                end
                
                print("[Combat] " .. player.Name .. " received drop: " .. itemData.name)
            end
        end
    end
end

function CombatManager:CheckLevelUp(player, playerStats)
    while playerStats.exp >= playerStats.expToNextLevel do
        playerStats.exp = playerStats.exp - playerStats.expToNextLevel
        playerStats.level = playerStats.level + 1
        
        playerStats.maxHp = playerStats.maxHp + 10
        playerStats.hp = playerStats.maxHp
        playerStats.atk = playerStats.atk + 2
        playerStats.def = playerStats.def + 1
        
        playerStats.expToNextLevel = math.floor(playerStats.expToNextLevel * 1.5)
        
        local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
        local combatFeedback = eventsFolder:FindFirstChild("CombatFeedback")
        if combatFeedback then
            combatFeedback:FireClient(player, {
                type = "LevelUp",
                level = playerStats.level,
                maxHp = playerStats.maxHp,
                atk = playerStats.atk,
                def = playerStats.def,
                expToNextLevel = playerStats.expToNextLevel,
            })
        end
        
        print("[Combat] " .. player.Name .. " leveled up to Lv." .. playerStats.level)
    end
end

function CombatManager:GetPlayerStats(player)
    return self.playerStats[player.UserId]
end

-- Initialize
local combatManager = CombatManager.new()
combatManager:Init()
_G.CombatManager = combatManager

print("[Combat] Combat System ready!")
