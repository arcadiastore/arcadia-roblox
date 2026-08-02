--[[
    Arcadia Online - Monster Spawner (v3 - Data-Driven)
    
    Spawns monsters based on GameData module.
    Sets proper attributes for combat system.
    
    Place di: ServerScriptService/World (as Script)
    
    @author arcadiastore
    @version 3.0.0
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[MonsterSpawner] Monster Spawner initializing...")

-- Create Monsters folder
local monsterFolder = Instance.new("Folder")
monsterFolder.Name = "Monsters"
monsterFolder.Parent = workspace

-- ============================================
-- SPAWN MONSTER FUNCTION
-- ============================================

local function spawnMonster(monsterId, monsterData, position)
    -- Create monster part
    local monster = Instance.new("Part")
    monster.Name = monsterId
    monster.Size = monsterData.size or Vector3.new(3, 3, 3)
    monster.Position = position + Vector3.new(0, monster.Size.Y / 2, 0)
    monster.Anchored = true
    monster.CanCollide = true
    monster.Material = Enum.Material.SmoothPlastic
    
    -- Set shape
    if monsterData.shape == "Ball" then
        monster.Shape = Enum.PartType.Ball
    end
    
    -- Set color
    if monsterData.color then
        monster.Color = monsterData.color
    end
    
    -- Add name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Size = UDim2.new(0, 120, 0, 60)
    billboard.StudsOffset = Vector3.new(0, monster.Size.Y + 1, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = monster
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = monsterData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    
    local levelLabel = Instance.new("TextLabel")
    levelLabel.Name = "Level"
    levelLabel.Size = UDim2.new(1, 0, 0.3, 0)
    levelLabel.Position = UDim2.new(0, 0, 0.5, 0)
    levelLabel.BackgroundTransparency = 1
    levelLabel.Text = "Lv." .. monsterData.level
    levelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    levelLabel.TextStrokeTransparency = 0
    levelLabel.Font = Enum.Font.Gotham
    levelLabel.TextScaled = true
    levelLabel.Parent = billboard
    
    -- HP Bar
    local hpBarBg = Instance.new("Frame")
    hpBarBg.Name = "HPBarBg"
    hpBarBg.Size = UDim2.new(0.8, 0, 0.15, 0)
    hpBarBg.Position = UDim2.new(0.1, 0, 0.8, 0)
    hpBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    hpBarBg.BorderSizePixel = 0
    hpBarBg.Parent = billboard
    
    local hpBar = Instance.new("Frame")
    hpBar.Name = "HPBar"
    hpBar.Size = UDim2.new(1, 0, 1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    hpBar.BorderSizePixel = 0
    hpBar.Parent = hpBarBg
    
    -- Set attributes for combat system
    monster:SetAttribute("MonsterId", monsterId)
    monster:SetAttribute("CurrentHP", monsterData.hp)
    monster:SetAttribute("MaxHP", monsterData.hp)
    monster:SetAttribute("Level", monsterData.level)
    
    -- Add ClickDetector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 20
    clickDetector.Parent = monster
    
    monster.Parent = monsterFolder
    
    print("[MonsterSpawner] Spawned " .. monsterId .. " at " .. tostring(position))
    return monster
end

-- ============================================
-- SPAWN ALL MONSTERS FROM GAMEDATA
-- ============================================

for monsterId, monsterData in pairs(GameData.Monsters) do
    local spawnArea = monsterData.spawnArea
    local spawnPositions = GameData.SpawnPositions[spawnArea]
    
    if spawnPositions then
        -- Spawn multiple monsters based on count or use default positions
        local count = 1
        if monsterId == "Slime" then count = 5
        elseif monsterId == "Wolf" then count = 4
        elseif monsterId == "Boar" then count = 3
        elseif monsterId == "Guardian" then count = 1
        end
        
        for i = 1, count do
            local positions = spawnPositions.monsterPositions
            if positions and #positions > 0 then
                local posIndex = ((i - 1) % #positions) + 1
                local basePos = positions[posIndex]
                -- Add some randomness
                local offset = Vector3.new(
                    math.random(-5, 5),
                    0,
                    math.random(-5, 5)
                )
                spawnMonster(monsterId, monsterData, basePos + offset)
            end
        end
    else
        warn("[MonsterSpawner] No spawn positions for area: " .. spawnArea)
    end
end

print("[MonsterSpawner] All monsters spawned successfully!")
