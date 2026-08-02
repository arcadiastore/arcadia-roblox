--[[
    Arcadia Online - Quest Data
    Sesuai GDD 14_Quest.md
]]

local Quests = {}

Quests["quest_kill_slimes"] = {
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
    },
    prerequisite = nil,
}

Quests["quest_kill_wolves"] = {
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
    },
    prerequisite = "quest_kill_slimes",
}

Quests["quest_kill_boars"] = {
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
    },
    prerequisite = "quest_kill_wolves",
}

Quests["quest_kill_guardian"] = {
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
    },
    prerequisite = "quest_kill_boars",
}

return Quests
