--[[
    Arcadia Online - Monster Spawner
    
    Creates monsters according to GDD:
    - Slime (Lv.1-3) - Training Ground
    - Wolf (Lv.5-8) - Forest Entrance
    - Boar (Lv.7-10) - Deep Forest
    - Guardian Boss (Lv.10) - Forest Gate
    
    Place di: ServerScriptService/World (as Script)
    
    @author arcadiastore
    @version 1.0.0
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

-- Tunggu game load
task.wait(4)

print("[Monster] Spawning Monsters...")

-- ============================================
-- MONSTER DEFINITIONS (GDD)
-- ============================================

local MONSTER_DATA = {
    -- Slime (Lv.1-3) - Training Ground
    {
        id = "Slime",
        name = "Slime",
        level = 1,
        hp = 50,
        atk = 5,
        def = 3,
        exp = 20,
        gold = 10,
        color = Color3.fromRGB(50, 200, 50),  -- Green
        size = Vector3.new(3, 3, 3),
        shape = "Ball",
        positions = {
            Vector3.new(10, 2, 45),
            Vector3.new(-10, 2, 45),
            Vector3.new(15, 2, 50),
            Vector3.new(-15, 2, 50),
            Vector3.new(0, 2, 55),
        },
    },
    -- Wolf (Lv.5-8) - Forest Entrance
    {
        id = "Wolf",
        name = "Serigala",
        level = 5,
        hp = 120,
        atk = 15,
        def = 8,
        exp = 50,
        gold = 25,
        color = Color3.fromRGB(128, 128, 128),  -- Gray
        size = Vector3.new(3, 2, 5),
        shape = "Block",
        positions = {
            Vector3.new(20, 1.5, -40),
            Vector3.new(-20, 1.5, -40),
            Vector3.new(15, 1.5, -50),
            Vector3.new(-15, 1.5, -50),
        },
    },
    -- Boar (Lv.7-10) - Deep Forest
    {
        id = "Boar",
        name = "Babi Hutan",
        level = 7,
        hp = 180,
        atk = 20,
        def = 12,
        exp = 80,
        gold = 40,
        color = Color3.fromRGB(139, 90, 43),  -- Brown
        size = Vector3.new(4, 3, 5),
        shape = "Block",
        positions = {
            Vector3.new(30, 2, -60),
            Vector3.new(-30, 2, -60),
            Vector3.new(25, 2, -70),
        },
    },
    -- Guardian Boss (Lv.10) - Forest Gate
    {
        id = "Guardian",
        name = "Guardian of the Forest",
        level = 10,
        hp = 500,
        atk = 35,
        def = 20,
        exp = 200,
        gold = 100,
        color = Color3.fromRGB(200, 50, 50),  -- Red (boss)
        size = Vector3.new(6, 8, 4),
        shape = "Block",
        positions = {
            Vector3.new(0, 4, -80),
        },
    },
}

-- ============================================
-- MONSTER CREATION FUNCTION
-- ============================================

local function createMonster(monsterData, position, index)
    -- Create model
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
    
    -- Add Humanoid for health system
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
    
    -- Health bar background
    local hpBg = Instance.new("Frame")
    hpBg.Name = "HealthBG"
    hpBg.Size = UDim2.new(1, 0, 0.3, 0)
    hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    hpBg.BorderSizePixel = 0
    hpBg.Parent = billboard
    
    local hpCorner = Instance.new("UICorner")
    hpCorner.CornerRadius = UDim.new(0, 4)
    hpCorner.Parent = hpBg
    
    -- Health bar fill
    local hpFill = Instance.new("Frame")
    hpFill.Name = "HealthFill"
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    
    local hpFillCorner = Instance.new("UICorner")
    hpFillCorner.CornerRadius = UDim.new(0, 4)
    hpFillCorner.Parent = hpFill
    
    -- Name text
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
    
    -- Set attributes for data
    body:SetAttribute("MonsterId", monsterData.id)
    body:SetAttribute("MonsterName", monsterData.name)
    body:SetAttribute("Level", monsterData.level)
    body:SetAttribute("HP", monsterData.hp)
    body:SetAttribute("ATK", monsterData.atk)
    body:SetAttribute("DEF", monsterData.def)
    body:SetAttribute("EXP", monsterData.exp)
    body:SetAttribute("Gold", monsterData.gold)
    body:SetAttribute("SpawnPosition", tostring(position))
    
    -- ClickDetector for targeting
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 20
    clickDetector.Parent = body
    
    -- Update health bar
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
        
        -- Respawn after delay
        task.delay(10, function()
            humanoid.Health = humanoid.MaxHealth
            body.Position = position
            print("[Monster] " .. monsterData.name .. " respawned!")
        end)
    end)
    
    monster.Parent = Workspace:FindFirstChild("Monsters") or Workspace
    
    return monster
end

-- ============================================
-- SPAWN ALL MONSTERS
-- ============================================

-- Create Monsters folder if not exists
local monstersFolder = Workspace:FindFirstChild("Monsters")
if not monstersFolder then
    monstersFolder = Instance.new("Folder")
    monstersFolder.Name = "Monsters"
    monstersFolder.Parent = Workspace
end

-- Spawn monsters
for _, monsterData in ipairs(MONSTER_DATA) do
    for i, position in ipairs(monsterData.positions) do
        createMonster(monsterData, position, i)
    end
end

print("[Monster] All monsters spawned!")
print("[Monster] - Slime x5 (Training Ground)")
print("[Monster] - Wolf x4 (Forest Entrance)")
print("[Monster] - Boar x3 (Deep Forest)")
print("[Monster] - Guardian Boss x1 (Forest Gate)")
