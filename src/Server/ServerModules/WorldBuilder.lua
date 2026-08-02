--[[
    WorldBuilder.lua
    Spawns NPCs and Monsters in the world
]]

local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local WorldBuilder = {}

-- Create name tag (BillboardGui)
local function createNameTag(parent, name, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameTag"
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = false
    billboard.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Parent = billboard
    
    return billboard
end

-- Spawn all NPCs
function WorldBuilder:SpawnNPCs()
    local npcFolder = Instance.new("Folder")
    npcFolder.Name = "NPCs"
    npcFolder.Parent = workspace
    
    for npcId, npcData in pairs(GameData.NPCs) do
        local npc = Instance.new("Part")
        npc.Name = npcId
        npc.Size = Vector3.new(2, 5, 2)
        npc.Position = npcData.position + Vector3.new(0, 2.5, 0)
        npc.Anchored = true
        npc.CanCollide = true
        npc.BrickColor = BrickColor.new(npcData.color or "Medium stone grey")
        npc:SetAttribute("NPCId", npcId)
        npc:SetAttribute("HasQuest", npcData.hasQuest or false)
        npc:SetAttribute("HasShop", npcData.hasShop or false)
        npc.Parent = npcFolder
        
        -- Add ClickDetector
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 20
        clickDetector.Parent = npc
        
        -- Add name tag
        createNameTag(npc, npcData.name, Color3.fromRGB(100, 255, 100))
        
        print("[World] NPC spawned: " .. npcData.name .. " at " .. tostring(npcData.position))
    end
    
    print("[World] All NPCs spawned!")
end

-- Spawn all monsters
function WorldBuilder:SpawnMonsters()
    local monsterFolder = Instance.new("Folder")
    monsterFolder.Name = "Monsters"
    monsterFolder.Parent = workspace
    
    for monsterId, monsterData in pairs(GameData.Monsters) do
        local positions = GameData.SpawnPositions[monsterData.spawnArea]
        if positions then
            for i, pos in ipairs(positions) do
                local monster = Instance.new("Part")
                monster.Name = monsterId .. "_" .. i
                monster.Size = Vector3.new(2, 2, 2)
                monster.Position = pos + Vector3.new(0, 1, 0)
                monster.Anchored = true
                monster.CanCollide = true
                monster.BrickColor = BrickColor.new(monsterData.color or "Medium stone grey")
                monster:SetAttribute("MonsterId", monsterId)
                monster:SetAttribute("CurrentHP", monsterData.hp)
                monster.Parent = monsterFolder
                
                -- Add ClickDetector
                local clickDetector = Instance.new("ClickDetector")
                clickDetector.MaxActivationDistance = 20
                clickDetector.Parent = monster
                
                -- Add name tag with HP
                local billboard = createNameTag(monster, monsterData.name, Color3.fromRGB(255, 100, 100))
                
                -- HP label
                local hpLabel = Instance.new("TextLabel")
                hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
                hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
                hpLabel.BackgroundTransparency = 1
                hpLabel.Text = "HP: " .. monsterData.hp .. "/" .. monsterData.hp
                hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                hpLabel.TextStrokeTransparency = 0
                hpLabel.Font = Enum.Font.Gotham
                hpLabel.TextScaled = true
                hpLabel.Parent = billboard
                
                print("[World] Monster spawned: " .. monsterData.name .. " at " .. tostring(pos))
            end
        end
    end
    
    print("[World] All monsters spawned!")
end

-- Build the entire world
function WorldBuilder:Build()
    print("[World] Building world...")
    self:SpawnNPCs()
    self:SpawnMonsters()
    print("[World] World built!")
end

return WorldBuilder
