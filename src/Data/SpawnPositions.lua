--[[
    Arcadia Online - Spawn Positions
]]

local SpawnPositions = {}

SpawnPositions["TrainingGround"] = {
    positions = {
        Vector3.new(0, 1, 40),
        Vector3.new(-10, 1, 50),
        Vector3.new(10, 1, 45),
        Vector3.new(-5, 1, 55),
        Vector3.new(5, 1, 50),
    },
}

SpawnPositions["ForestEntrance"] = {
    positions = {
        Vector3.new(0, 1, -50),
        Vector3.new(-10, 1, -60),
        Vector3.new(10, 1, -55),
        Vector3.new(-5, 1, -65),
    },
}

SpawnPositions["DeepForest"] = {
    positions = {
        Vector3.new(0, 1, -80),
        Vector3.new(-15, 1, -90),
        Vector3.new(15, 1, -85),
    },
}

SpawnPositions["ForestGate"] = {
    positions = {
        Vector3.new(0, 3, -100),
    },
}

-- Checkpoints (save points) - one per hunting area
SpawnPositions["Checkpoints"] = {
    {name = "Village Checkpoint", area = "Village", position = Vector3.new(0, 1, 15)},
    {name = "Training Ground Checkpoint", area = "TrainingGround", position = Vector3.new(0, 1, 30)},
    {name = "Forest Checkpoint", area = "ForestEntrance", position = Vector3.new(0, 1, -40)},
    {name = "Deep Forest Checkpoint", area = "DeepForest", position = Vector3.new(0, 1, -75)},
}

return SpawnPositions
