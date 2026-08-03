--[[
    CombatSystem.lua
    Handles monster attacking, damage, death, respawn
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local CombatSystem = {}

-- Anti-spam: track last attack time per player
local lastAttackTime = {}

-- Skill cooldowns per player: {playerId = {skillId = lastUseTime}}
local skillCooldowns = {}

-- Handle skill usage
function CombatSystem:HandleSkill(player, monsterPart, skillId, playerData, events)
    local data = playerData:Get(player)
    if not data then return end
    if not data.job then return end
    
    -- Get skill data
    local skillData = GameData.Skills and GameData.Skills[skillId]
    if not skillData then
        warn("[Combat] Skill not found: " .. skillId)
        return
    end
    
    -- Check if player has learned this skill
    if not data.learnedSkills or not data.learnedSkills[skillId] then
        warn("[Combat] " .. player.Name .. " hasn't learned " .. skillId)
        return
    end
    
    -- Check MP
    if (data.mp or 0) < skillData.mpCost then
        events.UpdateEvent:FireClient(player, {
            type = "Notification",
            text = "MP tidak cukup! Butuh " .. skillData.mpCost .. " MP",
            notifType = "error",
        })
        return
    end
    
    -- Check cooldown
    local now = tick()
    if not skillCooldowns[player.UserId] then skillCooldowns[player.UserId] = {} end
    if skillCooldowns[player.UserId][skillId] then
        local elapsed = now - skillCooldowns[player.UserId][skillId]
        if elapsed < skillData.cooldown then
            local remaining = math.ceil(skillData.cooldown - elapsed)
            events.UpdateEvent:FireClient(player, {
                type = "Notification",
                text = "Cooldown! " .. remaining .. "s",
                notifType = "error",
            })
            return
        end
    end
    
    -- Consume MP
    data.mp = data.mp - skillData.mpCost
    skillCooldowns[player.UserId][skillId] = now
    
    -- Execute skill based on type
    if skillData.type == "physical" or skillData.type == "magic" then
        -- Damage skill - need monster target
        if not monsterPart or not monsterPart.Parent then return end
        
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        -- Range check (skills have extended range)
        local attackRange = GameData:GetAttackRange(data) * 1.5
        local dist = (monsterPart.Position - rootPart.Position).Magnitude
        if dist > attackRange then return end
        
        local monsterId = monsterPart:GetAttribute("MonsterId")
        if not monsterId then return end
        local monsterData = GameData:GetMonster(monsterId)
        if not monsterData then return end
        
        local monsterHP = monsterPart:GetAttribute("CurrentHP") or monsterData.hp
        
        -- Calculate skill damage
        local baseAtk = skillData.type == "magic" and (data.matk or data.atk) or data.atk
        local damage = GameData:CalculateDamage(baseAtk, skillData.damageMultiplier, monsterData.def)
        
        -- Apply damage
        monsterHP = monsterHP - damage
        monsterPart:SetAttribute("CurrentHP", monsterHP)
        
        print("[Skill] " .. player.Name .. " used " .. skillData.name .. " on " .. monsterId .. " DMG:" .. damage)
        
        -- Send skill effect to client
        events.UpdateEvent:FireClient(player, {
            type = "SkillUsed",
            skillName = skillData.name,
            damage = damage,
            monsterName = monsterPart.Name,
            currentHP = math.max(0, monsterHP),
            maxHP = monsterData.hp,
            mp = data.mp,
            maxMp = data.maxMp or 50,
        })
        
        -- Check monster death
        if monsterHP <= 0 then
            self:OnMonsterDeath(player, monsterPart, monsterId, monsterData, data, playerData, events)
        end
        
    elseif skillData.type == "heal" then
        -- Heal skill
        local healValue = 0
        for _, effect in ipairs(skillData.effects) do
            if effect.type == "heal" then
                healValue = effect.value
            end
        end
        
        data.hp = math.min(data.maxHp, data.hp + healValue)
        
        events.UpdateEvent:FireClient(player, {
            type = "SkillUsed",
            skillName = skillData.name,
            heal = healValue,
            hp = data.hp,
            maxHp = data.maxHp,
            mp = data.mp,
            maxMp = data.maxMp or 50,
        })
        
        print("[Skill] " .. player.Name .. " used " .. skillData.name .. " healed " .. healValue)
        
    elseif skillData.type == "buff" then
        -- Buff skill (simplified - just notify)
        events.UpdateEvent:FireClient(player, {
            type = "SkillUsed",
            skillName = skillData.name,
            buff = true,
            mp = data.mp,
            maxMp = data.maxMp or 50,
        })
        
        print("[Skill] " .. player.Name .. " used buff " .. skillData.name)
    end
    
    -- Send data update
    playerData:SendUpdate(player, events)
end

-- Get attack cooldown based on weapon (seconds)
local function getAttackCooldown(playerData)
    local GameDataItems = GameData.Items or {}
    local weaponId = playerData.equipment.weapon1h or playerData.equipment.weapon2h
    if weaponId and GameDataItems[weaponId] then
        local wData = GameDataItems[weaponId]
        -- Weapon attack speed (lower = faster): sword=1.0, dagger=0.6, staff=1.5, bow=1.2
        if wData.stats and wData.stats.spd then
            -- Higher SPD stat = faster attack (lower cooldown)
            return math.max(0.4, 1.2 - (wData.stats.spd * 0.05))
        end
    end
    return 1.0  -- Default: 1 attack per second (fist)
end

-- Handle attack event
function CombatSystem:HandleAttack(player, monsterPart, playerData, events)
    print("[Combat] HandleAttack called by " .. player.Name)
    
    if not monsterPart or not monsterPart.Parent then
        warn("[Combat] Invalid monster part")
        return
    end
    
    -- ANTI-SPAM: Check attack cooldown
    local now = tick()
    local data = playerData:Get(player)
    if not data then return end
    
    local cooldown = getAttackCooldown(data)
    if lastAttackTime[player.UserId] then
        local elapsed = now - lastAttackTime[player.UserId]
        if elapsed < cooldown then
            -- Too fast! Reject attack
            return
        end
    end
    lastAttackTime[player.UserId] = now
    
    -- MELEE RANGE CHECK - based on equipped weapon
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local attackRange = GameData:GetAttackRange(data)
    local dist = (monsterPart.Position - rootPart.Position).Magnitude
    if dist > attackRange then
        -- Too far, reject attack
        return
    end
    
    local monsterId = monsterPart:GetAttribute("MonsterId")
    print("[Combat] MonsterId: " .. tostring(monsterId))
    
    if not monsterId then
        warn("[Combat] No MonsterId attribute on " .. monsterPart.Name)
        return
    end
    
    local monsterData = GameData:GetMonster(monsterId)
    if not monsterData then return end
    
    -- Get monster HP
    local monsterHP = monsterPart:GetAttribute("CurrentHP")
    if not monsterHP then
        monsterHP = monsterData.hp
        monsterPart:SetAttribute("CurrentHP", monsterHP)
    end
    
    -- Calculate damage
    local damage = GameData:CalculateDamage(data.atk, 1.0, monsterData.def)
    
    -- Apply damage
    monsterHP = monsterHP - damage
    monsterPart:SetAttribute("CurrentHP", monsterHP)
    
    print("[Combat] " .. player.Name .. " hit " .. monsterId .. " DMG:" .. damage .. " HP:" .. monsterHP .. "/" .. monsterData.hp)
    
    -- Send damage + HP update to client
    events.UpdateEvent:FireClient(player, {
        type = "Damage",
        damage = damage,
        monsterName = monsterPart.Name,
        currentHP = math.max(0, monsterHP),
        maxHP = monsterData.hp,
    })
    
    -- Check if monster died
    if monsterHP <= 0 then
        self:OnMonsterDeath(player, monsterPart, monsterId, monsterData, data, playerData, events)
    end
end

-- Handle monster death
function CombatSystem:OnMonsterDeath(player, monsterPart, monsterId, monsterData, data, playerData, events)
    -- Give rewards
    data.exp = data.exp + monsterData.exp
    data.gold = data.gold + monsterData.gold
    print("[Combat] " .. player.Name .. " killed " .. monsterId .. " +" .. monsterData.exp .. "EXP +" .. monsterData.gold .. "G")
    
    -- Update quest progress (ONLY ON DEATH!)
    for questId, quest in pairs(data.activeQuests) do
        local questData = GameData:GetQuest(questId)
        if questData then
            for i, obj in ipairs(questData.objectives) do
                if obj.type == "kill" and obj.target == monsterId then
                    quest.progress[i] = (quest.progress[i] or 0) + 1
                    print("[Combat] Quest progress: " .. questId .. " " .. quest.progress[i] .. "/" .. obj.count)
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
                print("[Combat] Quest ready to turn in: " .. questId)
                
                -- Notify player
                events.UpdateEvent:FireClient(player, {
                    type = "QuestReady",
                    questId = questId,
                    questName = questData.name,
                    npcName = questData.giver,
                })
            end
        end
    end
    
    -- Check level up
    playerData:CheckLevelUp(player, events)
    
    -- Send update
    playerData:SendUpdate(player, events)
    
    -- Hide monster
    monsterPart.Transparency = 1
    monsterPart.CanCollide = false
    
    -- Disable ClickDetector
    local clickDetector = monsterPart:FindFirstChild("ClickDetector")
    if clickDetector then
        clickDetector.MaxActivationDistance = 0
    end
    
    -- Hide name tag
    local billboard = monsterPart:FindFirstChild("NameTag")
    if billboard then
        billboard.Enabled = false
    end
    
    -- Respawn monster
    task.delay(monsterData.respawnTime, function()
        if monsterPart and monsterPart.Parent then
            monsterPart:SetAttribute("CurrentHP", monsterData.hp)
            monsterPart.Transparency = 0
            monsterPart.CanCollide = true
            
            if clickDetector then
                clickDetector.MaxActivationDistance = 20
            end
            if billboard then
                billboard.Enabled = true
            end
            
            -- Notify all clients to reset HP display
            events.UpdateEvent:FireAllClients({
                type = "MonsterRespawn",
                monsterName = monsterPart.Name,
                maxHP = monsterData.hp,
            })
            
            print("[Combat] Monster respawned: " .. monsterId)
        end
    end)
end

return CombatSystem
