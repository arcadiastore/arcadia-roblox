--[[
    Arcadia Online - Combat System
    
    Handles combat mechanics:
    - Damage calculation
    - Critical hits
    - Skill usage
    - Buff/debuff management
    
    @author arcadiastore
    @version 1.0.0
]]

local CombatSystem = {}
CombatSystem.__index = CombatSystem

-- Damage types
local DamageType = {
    PHYSICAL = "Physical",
    MAGICAL = "Magical",
    TRUE = "True",  -- Ignores defense
}

function CombatSystem.new()
    local self = setmetatable({}, CombatSystem)
    
    self.activeBuffs = {}
    self.cooldowns = {}
    
    return self
end

-- Calculate damage from attacker to target
function CombatSystem:CalculateDamage(attackerStats, targetStats, skillData)
    local damage = 0
    local isCritical = false
    
    -- Base damage from attacker
    local baseDamage = attackerStats:CalculateDamage()
    
    -- Skill multiplier
    local skillMultiplier = skillData and skillData.damageMultiplier or 1.0
    
    -- Calculate raw damage
    local rawDamage = baseDamage * skillMultiplier
    
    -- Check for critical hit
    local critRate = attackerStats:CalculateCritRate()
    if math.random(100) <= critRate then
        isCritical = true
        local critDamage = attackerStats:CalculateCritDamage()
        rawDamage = rawDamage * critDamage
    end
    
    -- Apply defense reduction
    if skillData and skillData.damageType == DamageType.TRUE then
        damage = rawDamage
    else
        local defense = targetStats:CalculateDefense()
        local damageReduction = defense / (defense + 100)  -- Diminishing returns
        damage = rawDamage * (1 - damageReduction)
    end
    
    -- Ensure minimum damage
    damage = math.max(1, math.floor(damage))
    
    return {
        damage = damage,
        isCritical = isCritical,
        damageType = skillData and skillData.damageType or DamageType.PHYSICAL,
    }
end

-- Apply damage to target
function CombatSystem:ApplyDamage(target, damageResult)
    local humanoid = target:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.Health - damageResult.damage
        
        -- Check if target died
        if humanoid.Health <= 0 then
            self:OnTargetDeath(target)
        end
        
        return true
    end
    return false
end

-- Handle target death
function CombatSystem:OnTargetDeath(target)
    -- Award EXP and loot to attacker
    -- This would be connected to the quest and loot systems
    print("[Combat] Target defeated: " .. target.Name)
end

-- Use skill
function CombatSystem:UseSkill(player, skillId, target)
    -- Check cooldown
    if self:IsOnCooldown(player, skillId) then
        return false, "Skill is on cooldown"
    end
    
    -- Get skill data
    local skillData = self:GetSkillData(skillId)
    if not skillData then
        return false, "Invalid skill"
    end
    
    -- Check MP cost
    local playerStats = self:GetPlayerStats(player)
    if playerStats:GetStat("maxMp") < skillData.mpCost then
        return false, "Not enough MP"
    end
    
    -- Consume MP
    playerStats:ConsumeMp(skillData.mpCost)
    
    -- Set cooldown
    self:SetCooldown(player, skillId, skillData.cooldown)
    
    -- Apply skill effect
    if skillData.type == "damage" then
        -- Damage skill
        local damageResult = self:CalculateDamage(playerStats, target, skillData)
        self:ApplyDamage(target, damageResult)
        return true, damageResult
    elseif skillData.type == "heal" then
        -- Healing skill
        local healAmount = self:CalculateHeal(playerStats, skillData)
        self:ApplyHeal(target, healAmount)
        return true, { heal = healAmount }
    elseif skillData.type == "buff" then
        -- Buff skill
        self:ApplyBuff(player, skillData)
        return true, { buff = skillData.buffType }
    end
    
    return false, "Unknown skill type"
end

-- Calculate heal amount
function CombatSystem:CalculateHeal(healerStats, skillData)
    local int = healerStats:GetStat("INT")
    local healPower = skillData.healPower or 10
    
    -- Heal formula: healPower + INT * 2
    return math.floor(healPower + int * 2)
end

-- Apply heal to target
function CombatSystem:ApplyHeal(target, amount)
    local humanoid = target:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + amount)
    end
end

-- Apply buff to target
function CombatSystem:ApplyBuff(target, skillData)
    local buffId = skillData.buffType
    local duration = skillData.buffDuration or 10
    
    -- Store buff
    self.activeBuffs[target] = self.activeBuffs[target] or {}
    self.activeBuffs[target][buffId] = {
        startTime = tick(),
        duration = duration,
        stats = skillData.buffStats,
    }
    
    -- Apply buff stats
    local playerStats = self:GetPlayerStats(target)
    if playerStats and skillData.buffStats then
        playerStats:AddBonusStats(skillData.buffStats)
    end
    
    -- Set timer to remove buff
    task.delay(duration, function()
        self:RemoveBuff(target, buffId)
    end)
end

-- Remove buff from target
function CombatSystem:RemoveBuff(target, buffId)
    if self.activeBuffs[target] and self.activeBuffs[target][buffId] then
        local buff = self.activeBuffs[target][buffId]
        
        -- Remove buff stats
        local playerStats = self:GetPlayerStats(target)
        if playerStats and buff.stats then
            local negativeStats = {}
            for stat, value in pairs(buff.stats) do
                negativeStats[stat] = -value
            end
            playerStats:AddBonusStats(negativeStats)
        end
        
        -- Remove buff
        self.activeBuffs[target][buffId] = nil
    end
end

-- Check if skill is on cooldown
function CombatSystem:IsOnCooldown(player, skillId)
    local playerCooldowns = self.cooldowns[player]
    if playerCooldowns and playerCooldowns[skillId] then
        return tick() < playerCooldowns[skillId]
    end
    return false
end

-- Set cooldown
function CombatSystem:SetCooldown(player, skillId, duration)
    self.cooldowns[player] = self.cooldowns[player] or {}
    self.cooldowns[player][skillId] = tick() + duration
end

-- Get skill data (placeholder - would load from data)
function CombatSystem:GetSkillData(skillId)
    local skills = {
        -- Warrior Skills
        warrior_slash = {
            name = "Slash",
            type = "damage",
            damageType = DamageType.PHYSICAL,
            damageMultiplier = 1.5,
            mpCost = 10,
            cooldown = 2,
        },
        warrior_whirlwind = {
            name = "Whirlwind",
            type = "damage",
            damageType = DamageType.PHYSICAL,
            damageMultiplier = 2.0,
            mpCost = 25,
            cooldown = 8,
            isAoE = true,
        },
        -- Knight Skills
        knight_shield_bash = {
            name = "Shield Bash",
            type = "damage",
            damageType = DamageType.PHYSICAL,
            damageMultiplier = 1.2,
            mpCost = 15,
            cooldown = 5,
            stunDuration = 2,
        },
        -- Mage Skills
        mage_fireball = {
            name = "Fireball",
            type = "damage",
            damageType = DamageType.MAGICAL,
            damageMultiplier = 2.5,
            mpCost = 20,
            cooldown = 3,
        },
        mage_heal = {
            name = "Heal",
            type = "heal",
            healPower = 30,
            mpCost = 25,
            cooldown = 5,
        },
        -- Archer Skills
        archer_double_arrow = {
            name = "Double Arrow",
            type = "damage",
            damageType = DamageType.PHYSICAL,
            damageMultiplier = 1.8,
            mpCost = 15,
            cooldown = 4,
            hitCount = 2,
        },
        -- Cleric Skills
        cleric_party_heal = {
            name = "Party Heal",
            type = "heal",
            healPower = 40,
            mpCost = 30,
            cooldown = 10,
            isAoE = true,
        },
        cleric_atk_buff = {
            name = "Attack Buff",
            type = "buff",
            buffType = "atk_up",
            buffDuration = 30,
            buffStats = { atk = 10 },
            mpCost = 20,
            cooldown = 60,
        },
    }
    
    return skills[skillId]
end

-- Get player stats (placeholder - would connect to player system)
function CombatSystem:GetPlayerStats(player)
    -- This would be implemented to get actual player stats
    return nil
end

return CombatSystem.new()
