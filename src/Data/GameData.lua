--[[
    Arcadia Online - Game Data Module (SINGLE SOURCE OF TRUTH)
    
    SEMUA data game ada di sini! (SESUAI GDD)
    - Job definitions (GDD: 06_Jobs.md)
    - Skill definitions (GDD: 07_Skills.md)
    - Stats formula (GDD: 08_Stats.md)
    - Monster definitions (GDD: 11_Monsters.md)
    - Quest definitions (GDD: 14_Quest.md)
    - Item definitions (GDD: 09_Items.md)
    - NPC definitions (GDD: 13_NPC.md)
    - Dialogue definitions (GDD: 15_Dialogue.md)
    - Shop definitions
    
    Place di: ReplicatedStorage (as ModuleScript)
    
    CARA PAKAI:
    local GameData = require(ReplicatedStorage.GameData)
    local slime = GameData.Monsters["Slime"]
    
    @author arcadiastore
    @version 3.0.0 - GDD Compliant
]]

local GameData = {}

-- ============================================
-- JOB DATA (GDD: 06_Jobs.md)
-- ============================================

GameData.Jobs = {
    -- Starter Jobs (Tier 1)
    ["Warrior"] = {
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
    },
    
    ["Mage"] = {
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
    },
    
    ["Archer"] = {
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
    },
    
    -- Job Advancement (Tier 2 - Lv 30)
    ["Knight"] = {
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
    },
    
    ["Berserker"] = {
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
    },
    
    ["Wizard"] = {
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
    },
    
    ["Cleric"] = {
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
    },
    
    ["Ranger"] = {
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
    },
    
    ["Assassin"] = {
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
    },
}

-- ============================================
-- SKILL DATA (GDD: 07_Skills.md)
-- ============================================

GameData.Skills = {
    -- Warrior Skills
    ["slash"] = {
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
    },
    ["shield_bash"] = {
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
    },
    ["war_cry"] = {
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
    },
    ["berserk"] = {
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
    },
    
    -- Mage Skills
    ["fire_bolt"] = {
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
    },
    ["ice_wall"] = {
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
    },
    ["thunder"] = {
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
    },
    ["meteor"] = {
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
    },
    ["archmages_fury"] = {
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
    },
    
    -- Archer Skills
    ["aimed_shot"] = {
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
    },
    ["rapid_fire"] = {
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
    },
    ["arrow_rain"] = {
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
    },
    ["eagle_eye"] = {
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
    },
    
    -- Knight Skills
    ["fortify"] = {
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
    },
    ["guardian"] = {
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
    },
    ["invulnerable"] = {
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
    },
    
    -- Berserker Skills
    ["whirlwind"] = {
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
    },
    ["bloodlust"] = {
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
    },
    
    -- Wizard Skills (additions)
    -- Uses same base skills as Mage but upgraded
    
    -- Cleric Skills
    ["heal"] = {
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
    },
    ["blessing"] = {
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
    },
    ["holy_light"] = {
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
    },
    ["resurrection"] = {
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
    },
    
    -- Ranger Skills (uses Archer base + additions)
    
    -- Assassin Skills
    ["backstab"] = {
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
    },
    ["poison_blade"] = {
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
    },
    ["shadow_step"] = {
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
    },
    ["assassinate"] = {
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
    },
}

-- ============================================
-- STATS FORMULA (GDD: 08_Stats.md)
-- ============================================

GameData.Formulas = {
    -- EXP needed per level: Base * (Level ^ 1.5)
    expPerLevel = function(level)
        return math.floor(100 * (level ^ 1.5))
    end,
    
    -- Physical Damage: (ATK * Skill_Multiplier) - (Target_DEF * 0.5)
    physicalDamage = function(atk, multiplier, targetDef)
        local damage = (atk * multiplier) - (targetDef * 0.5)
        return math.max(1, math.floor(damage))
    end,
    
    -- Magic Damage: (MATK * Skill_Multiplier) - (Target_MDEF * 0.5)
    magicDamage = function(matk, multiplier, targetMdef)
        local damage = (matk * multiplier) - (targetMdef * 0.5)
        return math.max(1, math.floor(damage))
    end,
    
    -- Critical Damage: Normal_Damage * (CD / 100)
    criticalDamage = function(normalDamage, critDamagePercent)
        return math.floor(normalDamage * (critDamagePercent / 100))
    end,
    
    -- Critical Rate: Base + (LUK * 0.1) + Equipment
    critRate = function(luk, equipmentBonus)
        return 5 + (luk * 0.1) + (equipmentBonus or 0)
    end,
    
    -- Evasion Rate: Base + (SPD * 0.05) + Equipment
    evasionRate = function(spd, equipmentBonus)
        return 5 + (spd * 0.05) + (equipmentBonus or 0)
    end,
    
    -- Accuracy: Base + (SPD * 0.03) + Equipment
    accuracy = function(spd, equipmentBonus)
        return 90 + (spd * 0.03) + (equipmentBonus or 0)
    end,
    
    -- Attack Speed: Base + (SPD * 0.1)
    attackSpeed = function(spd)
        return 100 + (spd * 0.1)
    end,
    
    -- Elemental Bonus: +30% damage if strong
    elementalMultiplier = function(attackerElement, defenderElement)
        local strengths = {
            fire = "wind",
            water = "fire",
            wind = "water",
            earth = "wind",
            light = "dark",
            dark = "light",
        }
        if strengths[attackerElement] == defenderElement then
            return 1.3  -- +30% damage
        end
        return 1.0
    end,
}

-- ============================================
-- MONSTER DATA (GDD: 11_Monsters.md)
-- ============================================

GameData.Monsters = {
    ["Slime"] = {
        id = "Slime",
        name = "Slime",
        level = 1,
        hp = 50,
        atk = 5,
        def = 3,
        matk = 0,
        mdef = 2,
        spd = 5,
        luk = 5,
        exp = 20,
        gold = 10,
        color = Color3.fromRGB(50, 200, 50),
        size = Vector3.new(3, 3, 3),
        shape = "Ball",
        spawnArea = "TrainingGround",
        respawnTime = 10,
        element = "earth",
        drops = {
            {itemId = "hp_potion_small", chance = 0.3},
            {itemId = "slime_gel", chance = 0.5},
        },
    },
    
    ["Wolf"] = {
        id = "Wolf",
        name = "Serigala",
        level = 5,
        hp = 120,
        atk = 15,
        def = 8,
        matk = 0,
        mdef = 5,
        spd = 12,
        luk = 8,
        exp = 50,
        gold = 25,
        color = Color3.fromRGB(128, 128, 128),
        size = Vector3.new(3, 2, 5),
        shape = "Block",
        spawnArea = "ForestEntrance",
        respawnTime = 15,
        element = "wind",
        drops = {
            {itemId = "wolf_fang", chance = 0.4},
            {itemId = "leather_armor", chance = 0.1},
        },
    },
    
    ["Boar"] = {
        id = "Boar",
        name = "Babi Hutan",
        level = 7,
        hp = 180,
        atk = 20,
        def = 12,
        matk = 0,
        mdef = 8,
        spd = 8,
        luk = 5,
        exp = 80,
        gold = 40,
        color = Color3.fromRGB(139, 90, 43),
        size = Vector3.new(4, 3, 5),
        shape = "Block",
        spawnArea = "DeepForest",
        respawnTime = 20,
        element = "earth",
        drops = {
            {itemId = "boar_meat", chance = 0.6},
            {itemId = "iron_armor", chance = 0.05},
        },
    },
    
    ["Guardian"] = {
        id = "Guardian",
        name = "Guardian of the Forest",
        level = 10,
        hp = 500,
        atk = 35,
        def = 20,
        matk = 15,
        mdef = 15,
        spd = 10,
        luk = 10,
        exp = 200,
        gold = 100,
        color = Color3.fromRGB(200, 50, 50),
        size = Vector3.new(6, 8, 4),
        shape = "Block",
        spawnArea = "ForestGate",
        respawnTime = 60,
        isBoss = true,
        element = "fire",
        drops = {
            {itemId = "steel_sword", chance = 0.3},
            {itemId = "boss_gem", chance = 1.0},
        },
    },
}

-- ============================================
-- MONSTER DATA
-- ============================================

GameData.Monsters = {
    ["Slime"] = {
        id = "Slime",
        name = "Slime",
        level = 1,
        hp = 50,
        atk = 5,
        def = 3,
        exp = 20,
        gold = 10,
        color = Color3.fromRGB(50, 200, 50),
        size = Vector3.new(3, 3, 3),
        shape = "Ball",
        spawnArea = "TrainingGround",
        respawnTime = 10,
        drops = {
            {itemId = "hp_potion_small", chance = 0.3},
            {itemId = "slime_gel", chance = 0.5},
        },
    },
    
    ["Wolf"] = {
        id = "Wolf",
        name = "Serigala",
        level = 5,
        hp = 120,
        atk = 15,
        def = 8,
        exp = 50,
        gold = 25,
        color = Color3.fromRGB(128, 128, 128),
        size = Vector3.new(3, 2, 5),
        shape = "Block",
        spawnArea = "ForestEntrance",
        respawnTime = 15,
        drops = {
            {itemId = "wolf_fang", chance = 0.4},
            {itemId = "leather_armor", chance = 0.1},
        },
    },
    
    ["Boar"] = {
        id = "Boar",
        name = "Babi Hutan",
        level = 7,
        hp = 180,
        atk = 20,
        def = 12,
        exp = 80,
        gold = 40,
        color = Color3.fromRGB(139, 90, 43),
        size = Vector3.new(4, 3, 5),
        shape = "Block",
        spawnArea = "DeepForest",
        respawnTime = 20,
        drops = {
            {itemId = "boar_meat", chance = 0.6},
            {itemId = "iron_armor", chance = 0.05},
        },
    },
    
    ["Guardian"] = {
        id = "Guardian",
        name = "Guardian of the Forest",
        level = 10,
        hp = 500,
        atk = 35,
        def = 20,
        exp = 200,
        gold = 100,
        color = Color3.fromRGB(200, 50, 50),
        size = Vector3.new(6, 8, 4),
        shape = "Block",
        spawnArea = "ForestGate",
        respawnTime = 60,
        isBoss = true,
        drops = {
            {itemId = "steel_sword", chance = 0.3},
            {itemId = "boss_gem", chance = 1.0},
        },
    },
}

-- ============================================
-- ITEM DATA
-- ============================================

GameData.Items = {
    -- Potions
    ["hp_potion_small"] = {
        id = "hp_potion_small",
        name = "HP Potion (Small)",
        description = "Memulihkan 50 HP",
        type = "consumable",
        subtype = "potion",
        price = 50,
        sellPrice = 25,
        stackable = true,
        maxStack = 99,
        effect = {stat = "hp", value = 50},
    },
    ["hp_potion_medium"] = {
        id = "hp_potion_medium",
        name = "HP Potion (Medium)",
        description = "Memulihkan 100 HP",
        type = "consumable",
        subtype = "potion",
        price = 100,
        sellPrice = 50,
        stackable = true,
        maxStack = 99,
        effect = {stat = "hp", value = 100},
    },
    ["hp_potion_large"] = {
        id = "hp_potion_large",
        name = "HP Potion (Large)",
        description = "Memulihkan 200 HP",
        type = "consumable",
        subtype = "potion",
        price = 200,
        sellPrice = 100,
        stackable = true,
        maxStack = 99,
        effect = {stat = "hp", value = 200},
    },
    ["mp_potion_small"] = {
        id = "mp_potion_small",
        name = "MP Potion (Small)",
        description = "Memulihkan 30 MP",
        type = "consumable",
        subtype = "potion",
        price = 40,
        sellPrice = 20,
        stackable = true,
        maxStack = 99,
        effect = {stat = "mp", value = 30},
    },
    ["mp_potion_medium"] = {
        id = "mp_potion_medium",
        name = "MP Potion (Medium)",
        description = "Memulihkan 60 MP",
        type = "consumable",
        subtype = "potion",
        price = 80,
        sellPrice = 40,
        stackable = true,
        maxStack = 99,
        effect = {stat = "mp", value = 60},
    },
    
    -- Materials (Monster Drops)
    ["slime_gel"] = {
        id = "slime_gel",
        name = "Slime Gel",
        description = "Lendir slime, bisa dijual",
        type = "material",
        subtype = "drop",
        price = 0,
        sellPrice = 5,
        stackable = true,
        maxStack = 99,
    },
    ["wolf_fang"] = {
        id = "wolf_fang",
        name = "Wolf Fang",
        description = "Taring serigala",
        type = "material",
        subtype = "drop",
        price = 0,
        sellPrice = 15,
        stackable = true,
        maxStack = 99,
    },
    ["boar_meat"] = {
        id = "boar_meat",
        name = "Boar Meat",
        description = "Daging babi hutan, bisa dimakan",
        type = "consumable",
        subtype = "food",
        price = 0,
        sellPrice = 20,
        stackable = true,
        maxStack = 99,
        effect = {stat = "hp", value = 80},
    },
    ["boss_gem"] = {
        id = "boss_gem",
        name = "Guardian Gem",
        description = "Permata dari Guardian",
        type = "material",
        subtype = "quest_item",
        price = 0,
        sellPrice = 500,
        stackable = true,
        maxStack = 1,
    },
    
    -- Weapons
    ["wooden_sword"] = {
        id = "wooden_sword",
        name = "Wooden Sword",
        description = "Senjata kayu sederhana",
        type = "equipment",
        subtype = "weapon",
        slot = "weapon",
        price = 100,
        sellPrice = 50,
        stackable = false,
        levelReq = 1,
        stats = {atk = 5},
    },
    ["iron_sword"] = {
        id = "iron_sword",
        name = "Iron Sword",
        description = "Senjata besi yang kuat",
        type = "equipment",
        subtype = "weapon",
        slot = "weapon",
        price = 300,
        sellPrice = 150,
        stackable = false,
        levelReq = 5,
        stats = {atk = 12},
    },
    ["steel_sword"] = {
        id = "steel_sword",
        name = "Steel Sword",
        description = "Senjata baja terbaik",
        type = "equipment",
        subtype = "weapon",
        slot = "weapon",
        price = 600,
        sellPrice = 300,
        stackable = false,
        levelReq = 10,
        stats = {atk = 20},
    },
    
    -- Armor
    ["leather_armor"] = {
        id = "leather_armor",
        name = "Leather Armor",
        description = "Armor kulit ringan",
        type = "equipment",
        subtype = "armor",
        slot = "body",
        price = 150,
        sellPrice = 75,
        stackable = false,
        levelReq = 1,
        stats = {def = 5},
    },
    ["iron_armor"] = {
        id = "iron_armor",
        name = "Iron Armor",
        description = "Armor besi yang kuat",
        type = "equipment",
        subtype = "armor",
        slot = "body",
        price = 400,
        sellPrice = 200,
        stackable = false,
        levelReq = 5,
        stats = {def = 12},
    },
    ["steel_armor"] = {
        id = "steel_armor",
        name = "Steel Armor",
        description = "Armor baja terbaik",
        type = "equipment",
        subtype = "armor",
        slot = "body",
        price = 800,
        sellPrice = 400,
        stackable = false,
        levelReq = 10,
        stats = {def = 20},
    },
    
    -- Accessories
    ["hp_ring"] = {
        id = "hp_ring",
        name = "HP Ring",
        description = "Cincin yang meningkatkan HP",
        type = "equipment",
        subtype = "accessory",
        slot = "ring",
        price = 200,
        sellPrice = 100,
        stackable = false,
        levelReq = 3,
        stats = {hp = 20},
    },
    ["atk_necklace"] = {
        id = "atk_necklace",
        name = "ATK Necklace",
        description = "Kalung yang meningkatkan ATK",
        type = "equipment",
        subtype = "accessory",
        slot = "necklace",
        price = 250,
        sellPrice = 125,
        stackable = false,
        levelReq = 3,
        stats = {atk = 5},
    },
}

-- ============================================
-- QUEST DATA
-- ============================================

GameData.Quests = {
    ["quest_kill_slimes"] = {
        id = "quest_kill_slimes",
        name = "Permintaan Tetua",
        description = "Bunuh 5 Slime di Training Ground",
        level = 1,
        giver = "Elder",
        objectives = {
            {type = "kill", target = "Slime", count = 5},
        },
        rewards = {
            exp = 50,
            gold = 100,
            items = {},
        },
        prerequisite = nil,
        nextQuest = "quest_kill_wolves",
    },
    
    ["quest_kill_wolves"] = {
        id = "quest_kill_wolves",
        name = "Ancaman Serigala",
        description = "Bunuh 3 Serigala di Forest Entrance",
        level = 5,
        giver = "Guard",
        objectives = {
            {type = "kill", target = "Wolf", count = 3},
        },
        rewards = {
            exp = 150,
            gold = 300,
            items = {
                {itemId = "iron_sword", count = 1},
            },
        },
        prerequisite = "quest_kill_slimes",
        nextQuest = "quest_kill_boars",
    },
    
    ["quest_kill_boars"] = {
        id = "quest_kill_boars",
        name = "Pemburu Babi Hutan",
        description = "Bunuh 5 Babi Hutan di Deep Forest",
        level = 7,
        giver = "Elder",
        objectives = {
            {type = "kill", target = "Boar", count = 5},
        },
        rewards = {
            exp = 300,
            gold = 500,
            items = {
                {itemId = "iron_armor", count = 1},
            },
        },
        prerequisite = "quest_kill_wolves",
        nextQuest = "quest_kill_guardian",
    },
    
    ["quest_kill_guardian"] = {
        id = "quest_kill_guardian",
        name = "Guardian of the Forest",
        description = "Kalahkan Guardian Boss",
        level = 10,
        giver = "Elder",
        objectives = {
            {type = "kill", target = "Guardian", count = 1},
        },
        rewards = {
            exp = 1000,
            gold = 2000,
            items = {
                {itemId = "steel_sword", count = 1},
                {itemId = "steel_armor", count = 1},
            },
        },
        prerequisite = "quest_kill_boars",
        nextQuest = nil,
    },
}

-- ============================================
-- NPC DATA
-- ============================================

GameData.NPCs = {
    ["Elder"] = {
        id = "Elder",
        name = "Elder Tetua",
        title = "Kepala Desa",
        color = Color3.fromRGB(200, 200, 200),
        position = Vector3.new(-25, 1, -20),
        hasQuest = true,
        hasShop = false,
        quests = {"quest_kill_slimes", "quest_kill_boars", "quest_kill_guardian"},
    },
    ["Blacksmith"] = {
        id = "Blacksmith",
        name = "Pandai Besi",
        title = "Ahli Senjata",
        color = Color3.fromRGB(139, 90, 43),
        position = Vector3.new(25, 1, -15),
        hasQuest = false,
        hasShop = true,
        shopId = "weapon_shop",
    },
    ["Merchant"] = {
        id = "Merchant",
        name = "Pedagang",
        title = "Penjaja Keliling",
        color = Color3.fromRGB(255, 200, 100),
        position = Vector3.new(-25, 1, 5),
        hasQuest = false,
        hasShop = true,
        shopId = "general_shop",
    },
    ["Guard"] = {
        id = "Guard",
        name = "Penjaga Desa",
        title = "Kapten Penjaga",
        color = Color3.fromRGB(100, 100, 200),
        position = Vector3.new(0, 1, -25),
        hasQuest = true,
        hasShop = false,
        quests = {"quest_kill_wolves"},
    },
    ["TrainingMaster"] = {
        id = "TrainingMaster",
        name = "Master Pelatihan",
        title = "Instruktur Tempur",
        color = Color3.fromRGB(200, 100, 100),
        position = Vector3.new(0, 1, 35),
        hasQuest = false,
        hasShop = false,
    },
}

-- ============================================
-- SHOP DATA
-- ============================================

GameData.Shops = {
    ["general_shop"] = {
        id = "general_shop",
        name = "Toko Umum",
        npcId = "Merchant",
        items = {
            "hp_potion_small",
            "hp_potion_medium",
            "mp_potion_small",
            "mp_potion_medium",
            "boar_meat",
        },
    },
    ["weapon_shop"] = {
        id = "weapon_shop",
        name = "Toko Senjata",
        npcId = "Blacksmith",
        items = {
            "wooden_sword",
            "iron_sword",
            "steel_sword",
            "leather_armor",
            "iron_armor",
            "steel_armor",
            "hp_ring",
            "atk_necklace",
        },
    },
}

-- ============================================
-- DIALOGUE DATA
-- ============================================

GameData.Dialogues = {
    ["Elder"] = {
        npcId = "Elder",
        lines = {
            {text = "Selamat datang di desa kita, petualang muda!", action = nil},
            {text = "Aku punya tugas untukmu. Maukah kau membantu desa?", action = "quest_offer"},
            {text = "Pergilah ke Training Ground dan bunuh Slime yang mengganggu.", action = nil},
        },
    },
    ["Blacksmith"] = {
        npcId = "Blacksmith",
        lines = {
            {text = "Butuh senjata atau armor? Aku punya yang terbaik!", action = "open_shop"},
            {text = "Lihat koleksiku dan pilih yang cocok untukmu.", action = nil},
        },
    },
    ["Merchant"] = {
        npcId = "Merchant",
        lines = {
            {text = "Hei! Mau beli sesuatu? Aku punya barang bagus!", action = "open_shop"},
            {text = "Potion, ramuan, segala macam ada!", action = nil},
        },
    },
    ["Guard"] = {
        npcId = "Guard",
        lines = {
            {text = "Hati-hati di luar desa. Monster semakin berbahaya.", action = nil},
            {text = "Bunuh 3 Serigala untuk membuktikan kekuatanmu!", action = "quest_offer"},
        },
    },
    ["TrainingMaster"] = {
        npcId = "TrainingMaster",
        lines = {
            {text = "Selamat datang di Training Ground!", action = nil},
            {text = "Klik kiri untuk menyerang. Coba serang Slime!", action = "tutorial"},
            {text = "Bicara dengan Elder Tetua untuk quest pertamamu.", action = nil},
        },
    },
}

-- ============================================
-- SPAWN POSITIONS
-- ============================================

GameData.SpawnPositions = {
    VillageCenter = Vector3.new(0, 5, 0),
    
    TrainingGround = {
        Vector3.new(10, 2, 45),
        Vector3.new(-10, 2, 45),
        Vector3.new(15, 2, 50),
        Vector3.new(-15, 2, 50),
        Vector3.new(0, 2, 55),
    },
    
    ForestEntrance = {
        Vector3.new(20, 1.5, -40),
        Vector3.new(-20, 1.5, -40),
        Vector3.new(15, 1.5, -50),
        Vector3.new(-15, 1.5, -50),
    },
    
    DeepForest = {
        Vector3.new(30, 2, -60),
        Vector3.new(-30, 2, -60),
        Vector3.new(25, 2, -70),
    },
    
    ForestGate = {
        Vector3.new(0, 4, -80),
    },
}

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

function GameData:GetMonster(id)
    return self.Monsters[id]
end

function GameData:GetItem(id)
    return self.Items[id]
end

function GameData:GetQuest(id)
    return self.Quests[id]
end

function GameData:GetNPC(id)
    return self.NPCs[id]
end

function GameData:GetShop(id)
    return self.Shops[id]
end

function GameData:GetDialogue(npcId)
    return self.Dialogues[npcId]
end

function GameData:GetMonstersByArea(area)
    local monsters = {}
    for id, monster in pairs(self.Monsters) do
        if monster.spawnArea == area then
            table.insert(monsters, monster)
        end
    end
    return monsters
end

function GameData:GetShopItems(shopId)
    local shop = self.Shops[shopId]
    if not shop then return {} end
    
    local items = {}
    for _, itemId in ipairs(shop.items) do
        local item = self.Items[itemId]
        if item then
            table.insert(items, item)
        end
    end
    return items
end

function GameData:GetAvailableQuests(playerLevel, completedQuests)
    local available = {}
    for id, quest in pairs(self.Quests) do
        if quest.level <= playerLevel then
            if not completedQuests[id] then
                if not quest.prerequisite or completedQuests[quest.prerequisite] then
                    table.insert(available, quest)
                end
            end
        end
    end
    return available
end

-- ============================================
-- JOB & SKILL HELPERS
-- ============================================

function GameData:GetJob(id)
    return self.Jobs[id]
end

function GameData:GetAllJobs()
    return self.Jobs
end

function GameData:GetStarterJobs()
    local starter = {}
    for id, job in pairs(self.Jobs) do
        if job.tier == 1 then
            table.insert(starter, job)
        end
    end
    return starter
end

function GameData:GetJobAdvancements(parentJobId)
    local advancements = {}
    for id, job in pairs(self.Jobs) do
        if job.parentJob == parentJobId then
            table.insert(advancements, job)
        end
    end
    return advancements
end

function GameData:GetJobSkills(jobId)
    local skills = {}
    for id, skill in pairs(self.Skills) do
        if skill.job == jobId then
            table.insert(skills, skill)
        end
    end
    -- Sort by tier
    table.sort(skills, function(a, b) return a.tier < b.tier end)
    return skills
end

function GameData:GetSkill(id)
    return self.Skills[id]
end

function GameData:GetPlayerSkills(jobId, level)
    local skills = {}
    for id, skill in pairs(self.Skills) do
        if skill.job == jobId and skill.levelReq <= level then
            table.insert(skills, skill)
        end
    end
    table.sort(skills, function(a, b) return a.tier < b.tier end)
    return skills
end

function GameData:CalculateExpForLevel(level)
    return self.Formulas.expPerLevel(level)
end

function GameData:CalculateStats(jobId, level)
    local job = self.Jobs[jobId]
    if not job then return nil end
    
    local stats = {}
    for stat, base in pairs(job.baseStats) do
        local growthKey = stat .. "PerLevel"
        local growth = job.growthStats[growthKey] or 0
        stats[stat] = base + (growth * (level - 1))
    end
    return stats
end

return GameData
