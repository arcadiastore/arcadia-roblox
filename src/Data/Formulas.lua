--[[
    Arcadia Online - Game Formulas
    
    SEMUA formula ada di sini!
    Sesuai GDD 08_Stats.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Formulas = {}

-- ============================================
-- EXP FORMULA
-- ============================================

-- EXP needed per level: Base * (Level ^ 1.5)
function Formulas.expPerLevel(level)
    return math.floor(100 * (level ^ 1.5))
end

-- ============================================
-- DAMAGE FORMULAS
-- ============================================

-- Physical Damage: (ATK * Skill_Multiplier) - (Target_DEF * 0.5)
function Formulas.physicalDamage(atk, multiplier, targetDef)
    local damage = (atk * multiplier) - (targetDef * 0.5)
    return math.max(1, math.floor(damage))
end

-- Magic Damage: (MATK * Skill_Multiplier) - (Target_MDEF * 0.5)
function Formulas.magicDamage(matk, multiplier, targetMdef)
    local damage = (matk * multiplier) - (targetMdef * 0.5)
    return math.max(1, math.floor(damage))
end

-- Heal Amount: MATK * Skill_Multiplier
function Formulas.healAmount(matk, multiplier)
    return math.floor(matk * multiplier)
end

-- ============================================
-- CRITICAL FORMULAS
-- ============================================

-- Critical Rate: Base + (LUK * 0.1) + Equipment
function Formulas.critRate(luk, equipmentBonus)
    return 5 + (luk * 0.1) + (equipmentBonus or 0)
end

-- Critical Damage: Normal_Damage * (CD / 100)
function Formulas.criticalDamage(normalDamage, critDamagePercent)
    return math.floor(normalDamage * (critDamagePercent / 100))
end

-- Default Crit Damage: 150%
function Formulas.defaultCritDamage(normalDamage)
    return math.floor(normalDamage * 1.5)
end

-- ============================================
-- DEFENSE FORMULAS
-- ============================================

-- Evasion Rate: Base + (SPD * 0.05) + Equipment
function Formulas.evasionRate(spd, equipmentBonus)
    return 5 + (spd * 0.05) + (equipmentBonus or 0)
end

-- Accuracy: Base + (SPD * 0.03) + Equipment
function Formulas.accuracy(spd, equipmentBonus)
    return 90 + (spd * 0.03) + (equipmentBonus or 0)
end

-- Attack Speed: Base + (SPD * 0.1)
function Formulas.attackSpeed(spd)
    return 100 + (spd * 0.1)
end

-- ============================================
-- ELEMENTAL SYSTEM
-- ============================================

-- Elemental Strengths
local ELEMENTAL_STRENGTHS = {
    fire = "wind",
    water = "fire",
    wind = "water",
    earth = "wind",
    light = "dark",
    dark = "light",
}

-- Elemental Bonus: +30% damage if strong
function Formulas.elementalMultiplier(attackerElement, defenderElement)
    if not attackerElement or not defenderElement then
        return 1.0
    end
    
    if ELEMENTAL_STRENGTHS[attackerElement] == defenderElement then
        return 1.3  -- +30% damage
    end
    
    return 1.0
end

-- ============================================
-- STAT CALCULATION
-- ============================================

-- Calculate stats for job at level
function Formulas.calculateStats(jobData, level)
    local stats = {}
    for stat, base in pairs(jobData.baseStats) do
        local growthKey = stat .. "PerLevel"
        local growth = jobData.growthStats[growthKey] or 0
        stats[stat] = base + (growth * (level - 1))
    end
    return stats
end

-- ============================================
-- CAP VALUES
-- ============================================

Formulas.Caps = {
    critRate = 100,
    evasion = 75,
    attackSpeed = 200,
    elementalResist = 80,
}

return Formulas
