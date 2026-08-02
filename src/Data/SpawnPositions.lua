--[[
    Arcadia Online - Spawn Positions
    
    SEMUA posisi spawn ada di sini!
    
    @author arcadiastore
    @version 3.0.0
]]

local SpawnPositions = {}

SpawnPositions["TrainingGround"] = {
    area = "TrainingGround",
    description = "Area latihan untuk pemula",
    monsterPositions = {
        Vector3.new(0, 1, 40),
        Vector3.new(-10, 1, 50),
        Vector3.new(10, 1, 45),
        Vector3.new(-5, 1, 55),
        Vector3.new(5, 1, 50),
    },
}

SpawnPositions["ForestEntrance"] = {
    area = "ForestEntrance",
    description = "Pintu masuk hutan",
    monsterPositions = {
        Vector3.new(0, 1, -50),
        Vector3.new(-10, 1, -60),
        Vector3.new(10, 1, -55),
        Vector3.new(-5, 1, -65),
    },
}

SpawnPositions["DeepForest"] = {
    area = "DeepForest",
    description = "Hutan dalam",
    monsterPositions = {
        Vector3.new(0, 1, -80),
        Vector3.new(-15, 1, -90),
        Vector3.new(15, 1, -85),
    },
}

SpawnPositions["ForestGate"] = {
    area = "ForestGate",
    description = "Gerbang hutan - Boss area",
    monsterPositions = {
        Vector3.new(0, 3, -100),
    },
}

return SpawnPositions
