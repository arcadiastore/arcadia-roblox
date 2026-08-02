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

return Quests
