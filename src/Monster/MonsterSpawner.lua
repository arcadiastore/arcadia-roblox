--[[
    Arcadia Online - Monster Spawner (v2 - Data-Driven)
    
    Semua data dari GameData module
    Tidak ada hardcode!
    
    Place di: ServerScriptService/World (as Script)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Wait for GameData
task.wait(3)
local GameData = require(ReplicatedStorage:WaitForChild("GameData"))

print("[Monster] Spawning Monsters from GameData...")

-- ============================================
-- MONSTER CREATION
-- ============================================

local function createMonster(monsterData, position, index)
    local monster = Instance.new("Model")
    monster.Name = monsterData.id .. "_" .. index
    
    -- Create body
    local body
    if monsterData.shape == "Ball" then
        body = Instance.new("Part")
        body.Shape = Enum.PartType.Ball
    else
        body = Instance.new("Part")
    end
    
    body.Name = "Body"
    body.Size = monsterData.size
    body.Position = position
    body.Anchored = false
    body.Material = Enum.Material.SmoothPlastic
    body.Color = monsterData.color
    body.Parent = monster
    
    -- Humanoid for health
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = monsterData.hp
    humanoid.Health = monsterData.hp
    humanoid.Parent = monster
    
    -- Name tag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Size = UDim2.new(6, 0, 2, 0)
    billboard.StudsOffset = Vector3.new(0, monsterData.size.Y + 1, 0)
    billboard.Adornee = body
    billboard.Parent = body
    
    -- Health bar
    local hpBg = Instance.new("Frame")
    hpBg.Name = "HealthBG"
    hpBg.Size = UDim2.new(1, 0, 0.3, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = billboard
    
    local hpFill = Instance.new("Frame")
    hpFill.Name = "HealthFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.Size = UDim2.new(1, 0, 0.7, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.3, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = monsterData.name .. " Lv." .. monsterData.level
    nameLabel.Parent = billboard
    
    -- ClickDetector
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 20
    clickDetector.Parent = body
    
    -- Set attributes (only ID, data from GameData)
    body:SetAttribute("MonsterId", monsterData.id)
    body:SetAttribute("HP", monsterData.hp)
    
    -- Health bar update
    humanoid.HealthChanged:Connect(function(newHealth)
        local percent = newHealth / humanoid.MaxHealth
        hpFill.Size = UDim2.new(percent, 0, 1, 0)
        
        if percent > 0.5 then
            hpFill.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        elseif percent > 0.25 then
            hpFill.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
        else
            hpFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        end
    end)
    
    -- Death handler
    humanoid.Died:Connect(function()
        print("[Monster] " .. monsterData.name .. " defeated!")
        
        -- Respawn using GameData respawnTime
        task.delay(monsterData.respawnTime, function()
            humanoid.Health = monsterData.hp
            body:SetAttribute("HP", monsterData.hp)
            body.Position = position
            print("[Monster] " .. monsterData.name .. " respawned!")
        end)
    end)
    
    monster.Parent = Workspace:FindFirstChild("Monsters") or Workspace
    
    return monster
end

-- ============================================
-- SPAWN FROM GAMEDATA
-- ============================================

-- Create Monsters folder
local monstersFolder = Workspace:FindFirstChild("Monsters")
if not monstersFolder then
    monstersFolder = Instance.new("Folder")
    monstersFolder.Name = "Monsters"
    monstersFolder.Parent = Workspace
end

-- Spawn monsters from GameData
local totalSpawned = 0
for monsterId, monsterData in pairs(GameData.Monsters) do
    local spawnArea = monsterData.spawnArea
    local positions = GameData.SpawnPositions[spawnArea]
    
    if positions then
        for i, position in ipairs(positions) do
            createMonster(monsterData, position, i)
            totalSpawned = totalSpawned + 1
        end
    else
        warn("[Monster] No spawn positions for area: " .. spawnArea)
    end
end

print("[Monster] All monsters spawned from GameData: " .. totalSpawned .. " total")
