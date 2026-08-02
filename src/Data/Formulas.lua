--[[
    Arcadia Online - Game Formulas
    Sesuai GDD 08_Stats.md
]]

local Formulas = {}

function Formulas.physicalDamage(atk, multiplier, targetDef)
    local damage = (atk * multiplier) - (targetDef * 0.5)
    return math.max(1, math.floor(damage))
end

function Formulas.magicDamage(matk, multiplier, targetMdef)
    local damage = (matk * multiplier) - (targetMdef * 0.5)
    return math.max(1, math.floor(damage))
end

function Formulas.expForLevel(level)
    return math.floor(100 * (level ^ 1.5))
end

function Formulas.critRate(luk)
    return 5 + (luk * 0.1)
end

return Formulas
