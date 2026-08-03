-- Skills.lua
-- Skill definitions based on GDD
-- Each skill has: name, description, type, mpCost, cooldown, damage multiplier, effects

local Skills = {
    -- ============================================
    -- BASIC ATTACK
    -- ============================================
    basic_attack = {
        id = "basic_attack",
        name = "Serangan Dasar",
        description = "Serangan fisik biasa",
        type = "physical",
        mpCost = 0,
        cooldown = 0,
        damageMultiplier = 1.0,
        effects = {},
    },
    
    -- ============================================
    -- WARRIOR SKILLS
    -- ============================================
    warrior_power_strike = {
        id = "warrior_power_strike",
        name = "Power Strike",
        description = "Serangan kuat dengan damage 150%",
        type = "physical",
        mpCost = 10,
        cooldown = 3,
        damageMultiplier = 1.5,
        effects = {},
    },
    
    warrior_shout = {
        id = "warrior_shout",
        name = "Battle Shout",
        description = "Tingkatkan ATK 20% selama 10 detik",
        type = "buff",
        mpCost = 15,
        cooldown = 15,
        damageMultiplier = 0,
        effects = {
            {type = "buff", stat = "atk", value = 0.2, duration = 10},
        },
    },
    
    -- ============================================
    -- MAGE SKILLS
    -- ============================================
    mage_fireball = {
        id = "mage_fireball",
        name = "Fireball",
        description = "Serangan magic dengan damage 180%",
        type = "magic",
        mpCost = 15,
        cooldown = 5,
        damageMultiplier = 1.8,
        effects = {},
    },
    
    mage_ice_shield = {
        id = "mage_ice_shield",
        name = "Ice Shield",
        description = "Buat shield yang absorbs damage",
        type = "buff",
        mpCost = 20,
        cooldown = 20,
        damageMultiplier = 0,
        effects = {
            {type = "shield", value = 100, duration = 15},
        },
    },
    
    -- ============================================
    -- CLERIC SKILLS
    -- ============================================
    cleric_heal = {
        id = "cleric_heal",
        name = "Heal",
        description = "Pulihkan HP 50",
        type = "heal",
        mpCost = 20,
        cooldown = 8,
        damageMultiplier = 0,
        effects = {
            {type = "heal", value = 50},
        },
    },
    
    cleric_blessing = {
        id = "cleric_blessing",
        name = "Blessing",
        description = "Buff DEF 20% untuk party",
        type = "buff",
        mpCost = 25,
        cooldown = 30,
        damageMultiplier = 0,
        effects = {
            {type = "buff", stat = "def", value = 0.2, duration = 15, target = "party"},
        },
    },
    
    -- ============================================
    -- KNIGHT SKILLS
    -- ============================================
    knight_shield_bash = {
        id = "knight_shield_bash",
        name = "Shield Bash",
        description = "Serangan dengan shield, stun 2 detik",
        type = "physical",
        mpCost = 12,
        cooldown = 6,
        damageMultiplier = 1.2,
        effects = {
            {type = "stun", duration = 2},
        },
    },
    
    knight_taunt = {
        id = "knight_taunt",
        name = "Taunt",
        description = "Tarik perhatian musuh selama 5 detik",
        type = "taunt",
        mpCost = 10,
        cooldown = 10,
        damageMultiplier = 0,
        effects = {
            {type = "taunt", duration = 5},
        },
    },
    
    -- ============================================
    -- JESTER SKILLS
    -- ============================================
    jester_backstab = {
        id = "jester_backstab",
        name = "Backstab",
        description = "Serangan dari belakang, damage 200%",
        type = "physical",
        mpCost = 15,
        cooldown = 4,
        damageMultiplier = 2.0,
        effects = {},
    },
    
    jester_trick = {
        id = "jester_trick",
        name = "Magic Trick",
        description = "Hilang dari pandangan 3 detik",
        type = "stealth",
        mpCost = 20,
        cooldown = 15,
        damageMultiplier = 0,
        effects = {
            {type = "stealth", duration = 3},
        },
    },
    
    -- ============================================
    -- ARCHER SKILLS (for Archer job)
    -- ============================================
    archer_arrow_rain = {
        id = "archer_arrow_rain",
        name = "Arrow Rain",
        description = "Hujan panah dengan damage 160%",
        type = "physical",
        mpCost = 15,
        cooldown = 6,
        damageMultiplier = 1.6,
        effects = {},
    },
    
    archer_eagle_eye = {
        id = "archer_eagle_eye",
        name = "Eagle Eye",
        description = "Tingkatkan akurasi dan critical rate 20%",
        type = "buff",
        mpCost = 20,
        cooldown = 18,
        damageMultiplier = 0,
        effects = {
            {type = "buff", stat = "critRate", value = 0.2, duration = 12},
        },
    },
}

return Skills
