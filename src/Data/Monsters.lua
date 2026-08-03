--[[
    Arcadia Online - Monster Data
    Sesuai GDD 11_Monsters.md
]]

local Monsters = {}

Monsters["Slime"] = {
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
}

Monsters["Wolf"] = {
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
}

Monsters["Goblin"] = {
    id = "Goblin",
    name = "Goblin",
    level = 8,
    hp = 100,
    atk = 18,
    def = 5,
    exp = 65,
    gold = 35,
    color = Color3.fromRGB(50, 150, 50),
    size = Vector3.new(2.5, 2.5, 2.5),
    shape = "Block",
    spawnArea = "GreenForest",
    respawnTime = 15,
}

Monsters["ForestSpirit"] = {
    id = "ForestSpirit",
    name = "Roh Hutan",
    level = 12,
    hp = 200,
    atk = 25,
    def = 15,
    exp = 100,
    gold = 50,
    color = Color3.fromRGB(100, 255, 150),
    size = Vector3.new(3, 4, 3),
    shape = "Ball",
    spawnArea = "GreenForest",
    respawnTime = 20,
}

Monsters["Boar"] = {
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
}

Monsters["ForestSpider"] = {
    id = "ForestSpider",
    name = "Laba-laba Hutan",
    level = 10,
    hp = 150,
    atk = 22,
    def = 10,
    exp = 90,
    gold = 45,
    color = Color3.fromRGB(80, 40, 80),
    size = Vector3.new(3, 2, 4),
    shape = "Block",
    spawnArea = "GreenForest",
    respawnTime = 18,
}

Monsters["Guardian"] = {
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
}

return Monsters
