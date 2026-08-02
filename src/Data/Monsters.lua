--[[
    Arcadia Online - Monster Data
    
    SEMUA data monster ada di sini!
    Sesuai GDD 11_Monsters.md
    
    @author arcadiastore
    @version 3.0.0
]]

local Monsters = {}

Monsters["Slime"] = {
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
}

Monsters["Wolf"] = {
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
}

Monsters["Boar"] = {
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
}

Monsters["Guardian"] = {
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
}

return Monsters
