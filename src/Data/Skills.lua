--[[
    Arcadia Online - Skill Data
    
    SEMUA data skill ada di sini!
    Sesuai GDD 07_Skills.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Skills = {}

-- ============================================
-- WARRIOR SKILLS
-- ============================================

Skills["slash"] = {
    id = "slash",
    name = "Slash",
    description = "Serangan dasar pedang",
    job = "Warrior",
    tier = 1,
    type = "active",
    mpCost = 5,
    cooldown = 3,
    damageType = "physical",
    multiplier = 1.5,
    levelReq = 1,
}

Skills["shield_bash"] = {
    id = "shield_bash",
    name = "Shield Bash",
    description = "Stun target selama 2 detik",
    job = "Warrior",
    tier = 2,
    type = "active",
    mpCost = 15,
    cooldown = 8,
    damageType = "physical",
    multiplier = 1.0,
    effect = {type = "stun", duration = 2},
    levelReq = 10,
}

Skills["war_cry"] = {
    id = "war_cry",
    name = "War Cry",
    description = "Party ATK +20% selama 10 detik",
    job = "Warrior",
    tier = 3,
    type = "active",
    mpCost = 30,
    cooldown = 30,
    damageType = "none",
    effect = {type = "buff", stat = "atk", value = 0.2, duration = 10, target = "party"},
    levelReq = 20,
}

Skills["berserk"] = {
    id = "berserk",
    name = "Berserk",
    description = "ATK +50%, DEF -30% selama 15 detik",
    job = "Warrior",
    tier = 5,
    type = "ultimate",
    mpCost = 100,
    cooldown = 120,
    damageType = "none",
    effect = {type = "self_buff", stats = {atk = 0.5, def = -0.3}, duration = 15},
    levelReq = 50,
}

-- ============================================
-- MAGE SKILLS
-- ============================================

Skills["fire_bolt"] = {
    id = "fire_bolt",
    name = "Fire Bolt",
    description = "Lemparkan api",
    job = "Mage",
    tier = 1,
    type = "active",
    mpCost = 10,
    cooldown = 5,
    damageType = "magic",
    element = "fire",
    multiplier = 1.8,
    levelReq = 1,
}

Skills["ice_wall"] = {
    id = "ice_wall",
    name = "Ice Wall",
    description = "Buat tembok es dan slow target",
    job = "Mage",
    tier = 2,
    type = "active",
    mpCost = 25,
    cooldown = 15,
    damageType = "magic",
    element = "water",
    multiplier = 1.2,
    effect = {type = "slow", value = 0.5, duration = 5},
    levelReq = 10,
}

Skills["thunder"] = {
    id = "thunder",
    name = "Thunder",
    description = "Petir menghantam target",
    job = "Mage",
    tier = 3,
    type = "active",
    mpCost = 40,
    cooldown = 20,
    damageType = "magic",
    element = "wind",
    multiplier = 2.5,
    levelReq = 20,
}

Skills["meteor"] = {
    id = "meteor",
    name = "Meteor",
    description = "AoE besar - MATK * 3.0",
    job = "Mage",
    tier = 4,
    type = "active",
    mpCost = 80,
    cooldown = 60,
    damageType = "magic",
    element = "fire",
    multiplier = 3.0,
    aoe = true,
    levelReq = 40,
}

Skills["archmages_fury"] = {
    id = "archmages_fury",
    name = "Archmage's Fury",
    description = "Semua skill tanpa CD selama 10 detik",
    job = "Mage",
    tier = 5,
    type = "ultimate",
    mpCost = 100,
    cooldown = 180,
    damageType = "none",
    effect = {type = "self_buff", noCooldown = true, duration = 10},
    levelReq = 60,
}

-- ============================================
-- ARCHER SKILLS
-- ============================================

Skills["aimed_shot"] = {
    id = "aimed_shot",
    name = "Aimed Shot",
    description = "Tembakan terarah dengan damage tinggi",
    job = "Archer",
    tier = 1,
    type = "active",
    mpCost = 8,
    cooldown = 5,
    damageType = "physical",
    multiplier = 2.0,
    levelReq = 1,
}

Skills["rapid_fire"] = {
    id = "rapid_fire",
    name = "Rapid Fire",
    description = "Tembakan bertubi-tubi (5 hit)",
    job = "Archer",
    tier = 2,
    type = "active",
    mpCost = 20,
    cooldown = 10,
    damageType = "physical",
    multiplier = 0.8,
    hits = 5,
    levelReq = 10,
}

Skills["arrow_rain"] = {
    id = "arrow_rain",
    name = "Arrow Rain",
    description = "Hujan panah AoE",
    job = "Archer",
    tier = 3,
    type = "active",
    mpCost = 35,
    cooldown = 25,
    damageType = "physical",
    multiplier = 1.5,
    aoe = true,
    levelReq = 20,
}

Skills["eagle_eye"] = {
    id = "eagle_eye",
    name = "Eagle Eye",
    description = "CR +50% selama 10 detik",
    job = "Archer",
    tier = 4,
    type = "active",
    mpCost = 50,
    cooldown = 45,
    damageType = "none",
    effect = {type = "self_buff", stat = "cr", value = 50, duration = 10},
    levelReq = 30,
}

-- ============================================
-- KNIGHT SKILLS
-- ============================================

Skills["fortify"] = {
    id = "fortify",
    name = "Fortify",
    description = "DEF +30% selama 10 detik",
    job = "Knight",
    tier = 3,
    type = "active",
    mpCost = 25,
    cooldown = 30,
    damageType = "none",
    effect = {type = "self_buff", stat = "def", value = 0.3, duration = 10},
    levelReq = 30,
}

Skills["guardian"] = {
    id = "guardian",
    name = "Guardian",
    description = "Protect ally, terima damage untuk mereka",
    job = "Knight",
    tier = 4,
    type = "active",
    mpCost = 40,
    cooldown = 60,
    damageType = "none",
    effect = {type = "protect", duration = 10},
    levelReq = 40,
}

Skills["invulnerable"] = {
    id = "invulnerable",
    name = "Invulnerable",
    description = "Tidak terima damage selama 5 detik",
    job = "Knight",
    tier = 5,
    type = "ultimate",
    mpCost = 100,
    cooldown = 180,
    damageType = "none",
    effect = {type = "self_buff", invulnerable = true, duration = 5},
    levelReq = 60,
}

-- ============================================
-- BERSERKER SKILLS
-- ============================================

Skills["whirlwind"] = {
    id = "whirlwind",
    name = "Whirlwind",
    description = "Serangan AoE berputar",
    job = "Berserker",
    tier = 3,
    type = "active",
    mpCost = 25,
    cooldown = 15,
    damageType = "physical",
    multiplier = 1.8,
    aoe = true,
    levelReq = 30,
}

Skills["bloodlust"] = {
    id = "bloodlust",
    name = "Bloodlust",
    description = "Lifesteal 20% selama 10 detik",
    job = "Berserker",
    tier = 4,
    type = "active",
    mpCost = 40,
    cooldown = 45,
    damageType = "none",
    effect = {type = "self_buff", lifesteal = 0.2, duration = 10},
    levelReq = 40,
}

-- ============================================
-- CLERIC SKILLS
-- ============================================

Skills["heal"] = {
    id = "heal",
    name = "Heal",
    description = "Pulihkan HP target",
    job = "Cleric",
    tier = 1,
    type = "active",
    mpCost = 15,
    cooldown = 5,
    damageType = "heal",
    multiplier = 2.0,
    levelReq = 30,
}

Skills["blessing"] = {
    id = "blessing",
    name = "Blessing",
    description = "Party DEF +15% selama 15 detik",
    job = "Cleric",
    tier = 2,
    type = "active",
    mpCost = 30,
    cooldown = 30,
    damageType = "none",
    effect = {type = "buff", stat = "def", value = 0.15, duration = 15, target = "party"},
    levelReq = 35,
}

Skills["holy_light"] = {
    id = "holy_light",
    name = "Holy Light",
    description = "Magic damage + heal party",
    job = "Cleric",
    tier = 3,
    type = "active",
    mpCost = 50,
    cooldown = 25,
    damageType = "magic",
    element = "light",
    multiplier = 2.5,
    healMultiplier = 1.0,
    aoe = true,
    levelReq = 40,
}

Skills["resurrection"] = {
    id = "resurrection",
    name = "Resurrection",
    description = "Hidupkan kembali party member yang KO",
    job = "Cleric",
    tier = 5,
    type = "ultimate",
    mpCost = 100,
    cooldown = 300,
    damageType = "heal",
    effect = {type = "resurrect"},
    levelReq = 50,
}

-- ============================================
-- ASSASSIN SKILLS
-- ============================================

Skills["backstab"] = {
    id = "backstab",
    name = "Backstab",
    description = "Serangan dari belakang, damage tinggi",
    job = "Assassin",
    tier = 1,
    type = "active",
    mpCost = 10,
    cooldown = 5,
    damageType = "physical",
    multiplier = 2.5,
    levelReq = 30,
}

Skills["poison_blade"] = {
    id = "poison_blade",
    name = "Poison Blade",
    description = "Serangan beracun, damage over time",
    job = "Assassin",
    tier = 2,
    type = "active",
    mpCost = 15,
    cooldown = 10,
    damageType = "physical",
    multiplier = 1.5,
    effect = {type = "dot", damage = 10, duration = 5, interval = 1},
    levelReq = 35,
}

Skills["shadow_step"] = {
    id = "shadow_step",
    name = "Shadow Step",
    description = "Teleport ke target, ATK +30% 3 detik",
    job = "Assassin",
    tier = 3,
    type = "active",
    mpCost = 25,
    cooldown = 20,
    damageType = "none",
    effect = {type = "teleport_buff", stat = "atk", value = 0.3, duration = 3},
    levelReq = 40,
}

Skills["assassinate"] = {
    id = "assassinate",
    name = "Assassinate",
    description = "Serangan maut, high crit chance",
    job = "Assassin",
    tier = 5,
    type = "ultimate",
    mpCost = 80,
    cooldown = 120,
    damageType = "physical",
    multiplier = 5.0,
    critBonus = 50,
    levelReq = 50,
}

return Skills
