--[[
    Arcadia Online - Quest Data
    
    SEMUA data quest ada di sini!
    Sesuai GDD 14_Quest.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Quests = {}

Quests["quest_kill_slimes"] = {
    id = "quest_kill_slimes",
    name = "Permintaan Tetua",
    description = "Bunuh 5 Slime di Training Ground",
    type = "main",
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
}

Quests["quest_kill_wolves"] = {
    id = "quest_kill_wolves",
    name = "Ancaman Serigala",
    description = "Bunuh 3 Serigala di Forest Entrance",
    type = "main",
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
}

Quests["quest_kill_boars"] = {
    id = "quest_kill_boars",
    name = "Pemburu Babi Hutan",
    description = "Bunuh 5 Babi Hutan di Deep Forest",
    type = "main",
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
}

Quests["quest_kill_guardian"] = {
    id = "quest_kill_guardian",
    name = "Guardian of the Forest",
    description = "Kalahkan Guardian Boss",
    type = "main",
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
        },
    },
    prerequisite = "quest_kill_boars",
    nextQuest = nil,
}

return Quests
