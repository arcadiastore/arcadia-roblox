--[[
    Arcadia Online - Beginner Village Builder
    
    Creates the Beginner Village according to GDD:
    - Village Center
    - Training Ground
    - Forest Entrance
    - NPCs
    - Environment
    
    Place di: ServerScriptService/World (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- Tunggu game load
task.wait(2)

print("[Village] Building Beginner Village...")

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Buat Part dengan properties
local function createPart(properties)
    local part = Instance.new("Part")
    part.Name = properties.Name or "Part"
    part.Size = properties.Size or Vector3.new(10, 1, 10)
    part.Position = properties.Position or Vector3.new(0, 0, 0)
    part.Anchored = true
    part.Material = properties.Material or Enum.Material.SmoothPlastic
    part.Color = properties.Color or Color3.fromRGB(128, 128, 128)
    part.CanCollide = properties.CanCollide ~= false
    part.Transparency = properties.Transparency or 0
    part.Parent = properties.Parent or Workspace
    return part
end

-- Buat Model
local function createModel(name, parent)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent or Workspace
    return model
end

-- ============================================
-- GROUND & FLOOR
-- ============================================

-- Ground utama
createPart({
    Name = "Ground",
    Size = Vector3.new(400, 1, 400),
    Position = Vector3.new(0, 0, 0),
    Material = Enum.Material.Grass,
    Color = Color3.fromRGB(86, 152, 59),
})

-- Village Center - lantai batu
createPart({
    Name = "VillageCenterFloor",
    Size = Vector3.new(60, 1, 60),
    Position = Vector3.new(0, 0.5, 0),
    Material = Enum.Material.Cobblestone,
    Color = Color3.fromRGB(150, 140, 130),
})

-- Training Ground - lantai tanah
createPart({
    Name = "TrainingGroundFloor",
    Size = Vector3.new(40, 1, 40),
    Position = Vector3.new(0, 0.5, 40),
    Material = Enum.Material.Sand,
    Color = Color3.fromRGB(194, 178, 128),
})

-- Path ke Forest
createPart({
    Name = "ForestPath",
    Size = Vector3.new(8, 1, 100),
    Position = Vector3.new(0, 0.5, -50),
    Material = Enum.Material.Cobblestone,
    Color = Color3.fromRGB(139, 119, 101),
})

-- ============================================
-- BUILDINGS
-- ============================================

local buildingsFolder = createModel("Buildings")

-- Elder's House
local elderHouse = createModel("ElderHouse", buildingsFolder)
createPart({
    Name = "Wall",
    Size = Vector3.new(12, 8, 10),
    Position = Vector3.new(-25, 4, -15),
    Material = Enum.Material.WoodPlanks,
    Color = Color3.fromRGB(139, 90, 43),
    Parent = elderHouse,
})
createPart({
    Name = "Roof",
    Size = Vector3.new(14, 3, 12),
    Position = Vector3.new(-25, 10, -15),
    Material = Enum.Material.Slate,
    Color = Color3.fromRGB(139, 69, 19),
    Parent = elderHouse,
})

-- Blacksmith
local blacksmith = createModel("Blacksmith", buildingsFolder)
createPart({
    Name = "Wall",
    Size = Vector3.new(10, 7, 10),
    Position = Vector3.new(25, 3.5, -10),
    Material = Enum.Material.Brick,
    Color = Color3.fromRGB(120, 80, 60),
    Parent = blacksmith,
})
createPart({
    Name = "Roof",
    Size = Vector3.new(12, 2, 12),
    Position = Vector3.new(25, 8, -10),
    Material = Enum.Material.Slate,
    Color = Color3.fromRGB(100, 50, 30),
    Parent = blacksmith,
})

-- Shop
local shop = createModel("Shop", buildingsFolder)
createPart({
    Name = "Wall",
    Size = Vector3.new(10, 7, 10),
    Position = Vector3.new(-25, 3.5, 10),
    Material = Enum.Material.WoodPlanks,
    Color = Color3.fromRGB(160, 120, 80),
    Parent = shop,
})
createPart({
    Name = "Roof",
    Size = Vector3.new(12, 2, 12),
    Position = Vector3.new(-25, 8, 10),
    Material = Enum.Material.Slate,
    Color = Color3.fromRGB(139, 90, 43),
    Parent = shop,
})

-- ============================================
-- ENVIRONMENT
-- ============================================

local envFolder = createModel("Environment")

-- Trees
local treePositions = {
    Vector3.new(-50, 0, -50),
    Vector3.new(-55, 0, -40),
    Vector3.new(50, 0, -50),
    Vector3.new(55, 0, -40),
    Vector3.new(-60, 0, 0),
    Vector3.new(60, 0, 0),
    Vector3.new(-50, 0, 50),
    Vector3.new(50, 0, 50),
}

for i, pos in ipairs(treePositions) do
    local tree = createModel("Tree_" .. i, envFolder)
    
    -- Trunk
    createPart({
        Name = "Trunk",
        Size = Vector3.new(2, 8, 2),
        Position = pos + Vector3.new(0, 4, 0),
        Material = Enum.Material.WoodPlanks,
        Color = Color3.fromRGB(101, 67, 33),
        Parent = tree,
    })
    
    -- Leaves
    createPart({
        Name = "Leaves",
        Size = Vector3.new(6, 6, 6),
        Position = pos + Vector3.new(0, 10, 0),
        Material = Enum.Material.Grass,
        Color = Color3.fromRGB(50, 120, 50),
        Parent = tree,
    })
end

-- Rocks
local rockPositions = {
    Vector3.new(30, 0, 30),
    Vector3.new(-30, 0, 30),
    Vector3.new(40, 0, -20),
}

for i, pos in ipairs(rockPositions) do
    createPart({
        Name = "Rock_" .. i,
        Size = Vector3.new(4, 3, 4),
        Position = pos + Vector3.new(0, 1.5, 0),
        Material = Enum.Material.Rock,
        Color = Color3.fromRGB(128, 128, 128),
        Parent = envFolder,
    })
end

-- Fence around village
for x = -35, 35, 7 do
    createPart({
        Name = "Fence",
        Size = Vector3.new(1, 3, 1),
        Position = Vector3.new(x, 1.5, -35),
        Material = Enum.Material.WoodPlanks,
        Color = Color3.fromRGB(139, 90, 43),
        Parent = envFolder,
    })
    createPart({
        Name = "Fence",
        Size = Vector3.new(1, 3, 1),
        Position = Vector3.new(x, 1.5, 35),
        Material = Enum.Material.WoodPlanks,
        Color = Color3.fromRGB(139, 90, 43),
        Parent = envFolder,
    })
end

-- ============================================
-- FOUNTAIN (Village Center)
-- ============================================

local fountain = createModel("Fountain")
createPart({
    Name = "Base",
    Size = Vector3.new(8, 2, 8),
    Position = Vector3.new(0, 1, 0),
    Material = Enum.Material.Marble,
    Color = Color3.fromRGB(200, 200, 200),
    Parent = fountain,
})
createPart({
    Name = "Pillar",
    Size = Vector3.new(1, 4, 1),
    Position = Vector3.new(0, 4, 0),
    Material = Enum.Material.Marble,
    Color = Color3.fromRGB(220, 220, 220),
    Parent = fountain,
})

-- ============================================
-- MARKER / SIGNS
-- ============================================

-- Sign: Training Ground
local trainingSign = createModel("Sign_TrainingGround")
createPart({
    Name = "Post",
    Size = Vector3.new(0.5, 3, 0.5),
    Position = Vector3.new(0, 1.5, 20),
    Material = Enum.Material.WoodPlanks,
    Color = Color3.fromRGB(139, 90, 43),
    Parent = trainingSign,
})
createPart({
    Name = "Board",
    Size = Vector3.new(4, 2, 0.3),
    Position = Vector3.new(0, 3.5, 20),
    Material = Enum.Material.WoodPlanks,
    Color = Color3.fromRGB(160, 120, 80),
    Parent = trainingSign,
})

-- Sign: Forest Entrance
local forestSign = createModel("Sign_ForestEntrance")
createPart({
    Name = "Post",
    Size = Vector3.new(0.5, 3, 0.5),
    Position = Vector3.new(0, 1.5, -30),
    Material = Enum.Material.WoodPlanks,
    Color = Color3.fromRGB(139, 90, 43),
    Parent = forestSign,
})
createPart({
    Name = "Board",
    Size = Vector3.new(4, 2, 0.3),
    Position = Vector3.new(0, 3.5, -30),
    Material = Enum.Material.WoodPlanks,
    Color = Color3.fromRGB(160, 120, 80),
    Parent = forestSign,
})

print("[Village] Beginner Village created!")
print("[Village] Village Center: (0, 0, 0)")
print("[Village] Training Ground: (0, 0, 40)")
print("[Village] Forest Entrance: (0, 0, -30)")
print("[Village] Elder House: (-25, 0, -15)")
print("[Village] Blacksmith: (25, 0, -10)")
print("[Village] Shop: (-25, 0, 10)")
