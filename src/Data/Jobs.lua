--[[
    Arcadia Online - Job Data
    
    SEMUA data job ada di sini!
    Sesuai GDD 06_Jobs.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Jobs = {}

-- ============================================
-- TIER 1 (Starter Jobs)
-- ============================================

Jobs["Warrior"] = {
    id = "Warrior",
    name = "Warrior",
    description = "Tank / Melee DPS - HP tinggi, DEF tinggi",
    tier = 1,
    weapons = {"Sword", "Axe", "Hammer"},
    armor = "Heavy",
    baseStats = {
        hp = 120,
        mp = 30,
        atk = 15,
        def = 12,
        matk = 5,
        mdef = 8,
        spd = 8,
        luk = 5,
    },
    growthStats = {
        hpPerLevel = 12,
        mpPerLevel = 3,
        atkPerLevel = 2,
        defPerLevel = 2,
        matkPerLevel = 1,
        mdefPerLevel = 1,
        spdPerLevel = 1,
    },
    skills = {"slash", "shield_bash", "war_cry", "berserk"},
    color = Color3.fromRGB(200, 50, 50),
}

Jobs["Mage"] = {
    id = "Mage",
    name = "Mage",
    description = "Ranged Magic DPS / Support - MATK tinggi, AoE damage",
    tier = 1,
    weapons = {"Staff", "Wand", "Orb"},
    armor = "Cloth",
    baseStats = {
        hp = 80,
        mp = 100,
        atk = 5,
        def = 5,
        matk = 15,
        mdef = 10,
        spd = 7,
        luk = 8,
    },
    growthStats = {
        hpPerLevel = 8,
        mpPerLevel = 10,
        atkPerLevel = 1,
        defPerLevel = 1,
        matkPerLevel = 2,
        mdefPerLevel = 2,
        spdPerLevel = 1,
    },
    skills = {"fire_bolt", "ice_wall", "thunder", "meteor"},
    color = Color3.fromRGB(100, 50, 200),
}

Jobs["Archer"] = {
    id = "Archer",
    name = "Archer",
    description = "Ranged Physical DPS - SPD tinggi, range jauh",
    tier = 1,
    weapons = {"Bow", "Crossbow", "Dagger"},
    armor = "Light",
    baseStats = {
        hp = 100,
        mp = 50,
        atk = 12,
        def = 8,
        matk = 6,
        mdef = 6,
        spd = 12,
        luk = 10,
    },
    growthStats = {
        hpPerLevel = 10,
        mpPerLevel = 5,
        atkPerLevel = 2,
        defPerLevel = 1,
        matkPerLevel = 1,
        mdefPerLevel = 1,
        spdPerLevel = 2,
    },
    skills = {"aimed_shot", "rapid_fire", "arrow_rain", "eagle_eye"},
    color = Color3.fromRGB(50, 200, 50),
}

-- ============================================
-- TIER 2 (Job Advancement - Lv 30)
-- ============================================

Jobs["Knight"] = {
    id = "Knight",
    name = "Knight",
    description = "Tank murni - Defense, HP, invulnerability",
    tier = 2,
    parentJob = "Warrior",
    levelReq = 30,
    weapons = {"Sword", "Shield"},
    armor = "Heavy",
    baseStats = {
        hp = 150,
        mp = 20,
        atk = 10,
        def = 18,
        matk = 3,
        mdef = 12,
        spd = 5,
        luk = 5,
    },
    growthStats = {
        hpPerLevel = 15,
        mpPerLevel = 2,
        atkPerLevel = 1,
        defPerLevel = 3,
        matkPerLevel = 1,
        mdefPerLevel = 2,
        spdPerLevel = 1,
    },
    skills = {"shield_bash", "fortify", "guardian", "invulnerable"},
    color = Color3.fromRGB(100, 100, 200),
}

Jobs["Berserker"] = {
    id = "Berserker",
    name = "Berserker",
    description = "Melee DPS murni - ATK tinggi, lifesteal",
    tier = 2,
    parentJob = "Warrior",
    levelReq = 30,
    weapons = {"Axe", "Two-Handed Sword"},
    armor = "Medium",
    baseStats = {
        hp = 130,
        mp = 20,
        atk = 20,
        def = 8,
        matk = 3,
        mdef = 5,
        spd = 10,
        luk = 8,
    },
    growthStats = {
        hpPerLevel = 13,
        mpPerLevel = 2,
        atkPerLevel = 3,
        defPerLevel = 1,
        matkPerLevel = 1,
        mdefPerLevel = 1,
        spdPerLevel = 2,
    },
    skills = {"slash", "whirlwind", "bloodlust", "berserk"},
    color = Color3.fromRGB(200, 100, 50),
}

Jobs["Wizard"] = {
    id = "Wizard",
    name = "Wizard",
    description = "Magic DPS - AoE besar, crowd control",
    tier = 2,
    parentJob = "Mage",
    levelReq = 30,
    weapons = {"Staff", "Orb"},
    armor = "Cloth",
    baseStats = {
        hp = 70,
        mp = 120,
        atk = 3,
        def = 4,
        matk = 22,
        mdef = 15,
        spd = 6,
        luk = 10,
    },
    growthStats = {
        hpPerLevel = 7,
        mpPerLevel = 12,
        atkPerLevel = 1,
        defPerLevel = 1,
        matkPerLevel = 3,
        mdefPerLevel = 2,
        spdPerLevel = 1,
    },
    skills = {"fire_bolt", "ice_wall", "meteor", "archmages_fury"},
    color = Color3.fromRGB(150, 50, 200),
}

Jobs["Cleric"] = {
    id = "Cleric",
    name = "Cleric",
    description = "Healer/Support - Healing, party buffs",
    tier = 2,
    parentJob = "Mage",
    levelReq = 30,
    weapons = {"Staff", "Wand"},
    armor = "Cloth",
    baseStats = {
        hp = 90,
        mp = 110,
        atk = 5,
        def = 8,
        matk = 18,
        mdef = 18,
        spd = 6,
        luk = 8,
    },
    growthStats = {
        hpPerLevel = 9,
        mpPerLevel = 11,
        atkPerLevel = 1,
        defPerLevel = 2,
        matkPerLevel = 2,
        mdefPerLevel = 2,
        spdPerLevel = 1,
    },
    skills = {"heal", "blessing", "holy_light", "resurrection"},
    color = Color3.fromRGB(255, 215, 0),
}

Jobs["Ranger"] = {
    id = "Ranger",
    name = "Ranger",
    description = "Ranged DPS - Critical tinggi, evasion",
    tier = 2,
    parentJob = "Archer",
    levelReq = 30,
    weapons = {"Bow", "Crossbow"},
    armor = "Light",
    baseStats = {
        hp = 90,
        mp = 60,
        atk = 16,
        def = 7,
        matk = 5,
        mdef = 6,
        spd = 15,
        luk = 15,
    },
    growthStats = {
        hpPerLevel = 9,
        mpPerLevel = 6,
        atkPerLevel = 2,
        defPerLevel = 1,
        matkPerLevel = 1,
        mdefPerLevel = 1,
        spdPerLevel = 2,
    },
    skills = {"aimed_shot", "rapid_fire", "arrow_rain", "eagle_eye"},
    color = Color3.fromRGB(100, 200, 100),
}

Jobs["Assassin"] = {
    id = "Assassin",
    name = "Assassin",
    description = "Melee DPS - Stealth, critical damage",
    tier = 2,
    parentJob = "Archer",
    levelReq = 30,
    weapons = {"Dagger", "Katar"},
    armor = "Light",
    baseStats = {
        hp = 85,
        mp = 40,
        atk = 18,
        def = 5,
        matk = 3,
        mdef = 4,
        spd = 18,
        luk = 20,
    },
    growthStats = {
        hpPerLevel = 8,
        mpPerLevel = 4,
        atkPerLevel = 3,
        defPerLevel = 1,
        matkPerLevel = 1,
        mdefPerLevel = 1,
        spdPerLevel = 2,
    },
    skills = {"backstab", "poison_blade", "shadow_step", "assassinate"},
    color = Color3.fromRGB(80, 80, 80),
}

return Jobs
