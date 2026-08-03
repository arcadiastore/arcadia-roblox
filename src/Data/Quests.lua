--[[
    Arcadia Online - Quest Data
    Sesuai GDD 14_Quest.md
]]

local Quests = {}

Quests["quest_kill_slimes"] = {
    id = "quest_kill_slimes",
    name = "Permintaan Tetua",
    description = "Bunuh 5 Slime di Training Ground untuk melatih kemampuanmu",
    level = 1,
    giver = "Elder",
    objectives = {
        {type = "kill", target = "Slime", count = 5, description = "Bunuh Slime"},
    },
    rewards = {
        exp = 50,
        gold = 100,
    },
    prerequisite = nil,
}

Quests["quest_kill_wolves"] = {
    id = "quest_kill_wolves",
    name = "Ancaman Serigala",
    description = "Serigala mengancam desa! Bunuh 3 Serigala di Forest Entrance",
    level = 5,
    giver = "Guard",
    objectives = {
        {type = "kill", target = "Wolf", count = 3, description = "Bunuh Serigala"},
    },
    rewards = {
        exp = 150,
        gold = 300,
    },
    prerequisite = "quest_kill_slimes",
}

Quests["quest_kill_boars"] = {
    id = "quest_kill_boars",
    name = "Pemburu Babi Hutan",
    description = "Babi Hutan merusak ladang! Bunuh 5 Babi Hutan di Deep Forest",
    level = 7,
    giver = "Elder",
    objectives = {
        {type = "kill", target = "Boar", count = 5, description = "Bunuh Babi Hutan"},
    },
    rewards = {
        exp = 300,
        gold = 500,
    },
    prerequisite = "quest_kill_wolves",
}

Quests["quest_kill_guardian"] = {
    id = "quest_kill_guardian",
    name = "Guardian of the Forest",
    description = "Kalahkan Guardian Boss yang menguasai Deep Forest",
    level = 10,
    giver = "Elder",
    objectives = {
        {type = "kill", target = "Guardian", count = 1, description = "Kalahkan Guardian Boss"},
    },
    rewards = {
        exp = 1000,
        gold = 2000,
    },
    prerequisite = "quest_kill_boars",
}

-- ============================================
-- GREEN FOREST QUESTS (Lv 10-25)
-- ============================================

Quests["quest_green_forest_goblins"] = {
    id = "quest_green_forest_goblins",
    name = "Ancaman Goblin",
    description = "Goblin menyerang penduduk Green Forest! Bunuh 5 Goblin.",
    level = 10,
    giver = "ForestGuard",
    objectives = {
        {type = "kill", target = "Goblin", count = 5, description = "Bunuh Goblin"},
    },
    rewards = {
        exp = 400,
        gold = 800,
    },
    prerequisite = "quest_kill_guardian",
}

Quests["quest_green_forest_spirits"] = {
    id = "quest_green_forest_spirits",
    name = "Roh Hutan yang Marah",
    description = "Roh Hutan menjadi agresif! Bunuh 3 Roh Hutan untuk meredakan mereka.",
    level = 12,
    giver = "ForestGuard",
    objectives = {
        {type = "kill", target = "ForestSpirit", count = 3, description = "Bunuh Roh Hutan"},
    },
    rewards = {
        exp = 600,
        gold = 1200,
    },
    prerequisite = "quest_green_forest_goblins",
}

Quests["quest_green_forest_spiders"] = {
    id = "quest_green_forest_spiders",
    name = "Sarang Laba-laba",
    description = "Laba-laba Hutan membuat sarang di jalur! Bersihkan dengan membunuh 4 Laba-laba.",
    level = 14,
    giver = "Herbalist",
    objectives = {
        {type = "kill", target = "ForestSpider", count = 4, description = "Bunuh Laba-laba Hutan"},
    },
    rewards = {
        exp = 800,
        gold = 1500,
        items = {"hp_potion_medium"},
    },
    prerequisite = "quest_green_forest_spirits",
}

Quests["quest_green_forest_herb"] = {
    id = "quest_green_forest_herb",
    name = "Ramuan Penyembuh",
    description = "Kumpulkan 3 Herb dari monster di Green Forest untuk membuat ramuan.",
    level = 15,
    giver = "Herbalist",
    objectives = {
        {type = "collect", target = "herb", count = 3, description = "Kumpulkan Herb"},
    },
    rewards = {
        exp = 500,
        gold = 1000,
        items = {"mp_potion_medium"},
    },
    prerequisite = "quest_green_forest_spiders",
}

return Quests
