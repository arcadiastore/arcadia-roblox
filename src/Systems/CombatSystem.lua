--[[
    Arcadia Online - Combat System
    
    Handles player attacks on monsters:
    - Click to attack
    - Damage calculation (ATK vs DEF)
    - Monster HP tracking
    - Death handling (EXP, Gold)
    - Level up system
    
    Place di: ServerScriptService/Systems (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Tunggu game load
task.wait(5)

print("[Combat] Combat System initializing...")

-- ============================================
-- COMBAT MANAGER
-- ============================================

local CombatManager = {}
CombatManager.__index = CombatManager

function CombatManager.new()
    local self = setmetatable({}, CombatManager)
    
    -- Player stats cache
    self.playerStats = {}
    
    return self
end

function CombatManager:Init()
    -- Setup connections
    self:SetupPlayerConnections()
    self:SetupCombatEvents()
    
    print("[Combat] Combat System initialized!")
end

function CombatManager:SetupPlayerConnections()
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

function CombatManager:OnPlayerAdded(player)
    -- Initialize player stats
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
    -- Cleanup
    self.playerStats[player.UserId] = nil
end

function CombatManager:SetupCombatEvents()
    -- RemoteEvent untuk attack
    local attackEvent = Instance.new("RemoteEvent")
    attackEvent.Name = "AttackMonster"
    attackEvent.Parent = ReplicatedStorage:FindFirstChild("Events")
    
    -- RemoteEvent untuk combat feedback
    local combatFeedback = Instance.new("RemoteEvent")
    combatFeedback.Name = "CombatFeedback"
    combatFeedback.Parent = ReplicatedStorage:FindFirstChild("Events")
    
    -- Handle attack request
    attackEvent.OnServerEvent:Connect(function(player, monsterPart)
        self:HandleAttack(player, monsterPart)
    end)
end

function CombatManager:HandleAttack(player, monsterPart)
    -- Validate
    if not monsterPart or not monsterPart.Parent then
        return
    end
    
    -- Check if monster
    local monsterId = monsterPart:GetAttribute("MonsterId")
    if not monsterId then
        return
    end
    
    -- Get player stats
    local playerStats = self.playerStats[player.UserId]
    if not playerStats then
        return
    end
    
    -- Get monster stats
    local monsterHP = monsterPart:GetAttribute("HP")
    local monsterATK = monsterPart:GetAttribute("ATK")
    local monsterDEF = monsterPart:GetAttribute("DEF")
    local monsterEXP = monsterPart:GetAttribute("EXP")
    local monsterGold = monsterPart:GetAttribute("Gold")
    local monsterLevel = monsterPart:GetAttribute("Level")
    
    -- Calculate damage
    local damage = math.max(1, playerStats.atk - monsterDEF)
    
    -- Random critical (10% chance)
    local isCrit = math.random(1, 100) <= 10
    if isCrit then
        damage = damage * 2
    end
    
    -- Apply damage to monster
    local newHP = monsterHP - damage
    monsterPart:SetAttribute("HP", newHP)
    
    -- Update health bar
    local humanoid = monsterPart.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Health = newHP
    end
    
    -- Send feedback to player
    local combatFeedback = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("CombatFeedback")
    if combatFeedback then
        combatFeedback:FireClient(player, {
            type = "DamageDealt",
            target = monsterPart:GetAttribute("MonsterName"),
            damage = damage,
            isCrit = isCrit,
            targetHP = newHP,
            targetMaxHP = monsterPart:GetAttribute("HP") + damage,
        })
    end
    
    print("[Combat] " .. player.Name .. " dealt " .. damage .. " damage to " .. monsterPart:GetAttribute("MonsterName"))
    
    -- Check if monster died
    if newHP <= 0 then
        self:HandleMonsterDeath(player, monsterPart, monsterEXP, monsterGold)
    end
end

function CombatManager:HandleMonsterDeath(player, monsterPart, expReward, goldReward)
    local monsterName = monsterPart:GetAttribute("MonsterName")
    local monsterId = monsterPart:GetAttribute("MonsterId")
    
    print("[Combat] " .. monsterName .. " defeated by " .. player.Name)
    
    -- Give rewards
    local playerStats = self.playerStats[player.UserId]
    if playerStats then
        playerStats.exp = playerStats.exp + expReward
        playerStats.gold = playerStats.gold + goldReward
        
        -- Check level up
        self:CheckLevelUp(player, playerStats)
        
        -- Send feedback
        local combatFeedback = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("CombatFeedback")
        if combatFeedback then
            combatFeedback:FireClient(player, {
                type = "MonsterDefeated",
                monsterName = monsterName,
                expReward = expReward,
                goldReward = goldReward,
                totalExp = playerStats.exp,
                totalGold = playerStats.gold,
                level = playerStats.level,
            })
        end
        
        print("[Combat] Rewards: +" .. expReward .. " EXP, +" .. goldReward .. " Gold")
        
        -- Update ALL active quests that have kill objectives for this monster
        if _G.QuestManager then
            local playerQuestData = _G.QuestManager:GetPlayerQuests(player)
            if playerQuestData and playerQuestData.activeQuests then
                for questId, quest in pairs(playerQuestData.activeQuests) do
                    _G.QuestManager:UpdateQuestProgress(player, questId, "kill", monsterName, 1)
                end
            end
        end
    end
    
    -- Monster death handling (respawn)
    local model = monsterPart.Parent
    if model then
        -- Hide monster
        for _, part in ipairs(model:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
        
        -- Disable click detector
        local clickDetector = monsterPart:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            clickDetector.MaxActivationDistance = 0
        end
        
        -- Respawn after delay
        task.delay(10, function()
            -- Reset HP
            local maxHP = monsterPart:GetAttribute("HP") + 100  -- Store original HP
            monsterPart:SetAttribute("HP", maxHP)
            
            -- Reset humanoid
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = maxHP
            end
            
            -- Show monster
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                end
            end
            
            -- Enable click detector
            if clickDetector then
                clickDetector.MaxActivationDistance = 20
            end
            
            print("[Combat] " .. monsterName .. " respawned!")
        end)
    end
end

function CombatManager:CheckLevelUp(player, playerStats)
    while playerStats.exp >= playerStats.expToNextLevel do
        -- Level up!
        playerStats.exp = playerStats.exp - playerStats.expToNextLevel
        playerStats.level = playerStats.level + 1
        
        -- Increase stats
        playerStats.maxHp = playerStats.maxHp + 10
        playerStats.hp = playerStats.maxHp  -- Full heal on level up
        playerStats.atk = playerStats.atk + 2
        playerStats.def = playerStats.def + 1
        
        -- Increase EXP requirement
        playerStats.expToNextLevel = math.floor(playerStats.expToNextLevel * 1.5)
        
        -- Send feedback
        local combatFeedback = ReplicatedStorage:FindFirstChild("Events"):FindFirstChild("CombatFeedback")
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

-- Initialize combat manager
local combatManager = CombatManager.new()
combatManager:Init()

-- Make accessible from other scripts
_G.CombatManager = combatManager

print("[Combat] Combat System ready!")
