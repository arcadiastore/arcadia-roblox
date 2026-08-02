--[[
    WorldBuilder.lua
    Spawns NPCs and Monsters with patrol behavior
]]

local TweenService = game:GetService("TweenService")
local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

local WorldBuilder = {}

-- Patrol settings
local PATROL_RADIUS = 15  -- studs from spawn
local PATROL_SPEED = 3    -- studs per second
local PATROL_WAIT_MIN = 2 -- seconds
local PATROL_WAIT_MAX = 5 -- seconds

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

-- Start patrol behavior for a monster
local function startPatrol(monster, spawnPos)
    task.spawn(function()
        while monster and monster.Parent do
            -- Check if monster is alive
            local hp = monster:GetAttribute("CurrentHP") or 0
            if hp <= 0 then
                -- Dead: wait for respawn
                task.wait(2)
                continue
            end
            
            -- Pick random point near spawn
            local angle = math.random() * math.pi * 2
            local distance = math.random() * PATROL_RADIUS
            local offsetX = math.cos(angle) * distance
            local offsetZ = math.sin(angle) * distance
            local targetPos = spawnPos + Vector3.new(offsetX, spawnPos.Y, offsetZ)
            
            -- Calculate tween duration
            local dist = (targetPos - monster.Position).Magnitude
            local duration = math.max(dist / PATROL_SPEED, 0.5)
            
            -- Tween to target
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(monster, tweenInfo, {Position = targetPos})
            tween:Play()
            
            -- Wait for tween to finish
            tween.Completed:Wait()
            
            -- Wait at destination
            local waitTime = math.random(PATROL_WAIT_MIN * 10, PATROL_WAIT_MAX * 10) / 10
            task.wait(waitTime)
        end
    end)
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

-- Spawn all monsters with patrol
function WorldBuilder:SpawnMonsters()
    local monsterFolder = Instance.new("Folder")
    monsterFolder.Name = "Monsters"
    monsterFolder.Parent = workspace
    
    for monsterId, monsterData in pairs(GameData.Monsters) do
        local spawnArea = GameData.SpawnPositions[monsterData.spawnArea]
        local positions = spawnArea and spawnArea.positions
        if positions then
            for i, pos in ipairs(positions) do
                local spawnPos = pos + Vector3.new(0, 1, 0)
                
                local monster = Instance.new("Part")
                monster.Name = monsterId .. "_" .. i
                monster.Size = Vector3.new(2, 2, 2)
                monster.Position = spawnPos
                monster.Anchored = true
                monster.CanCollide = true
                monster.BrickColor = BrickColor.new(monsterData.color or "Medium stone grey")
                monster:SetAttribute("MonsterId", monsterId)
                monster:SetAttribute("CurrentHP", monsterData.hp)
                monster:SetAttribute("SpawnPos", tostring(pos))
                monster.Parent = monsterFolder
                
                -- Add ClickDetector
                local clickDetector = Instance.new("ClickDetector")
                clickDetector.MaxActivationDistance = 20
                clickDetector.Parent = monster
                
                -- Add name tag with HP
                local billboard = createNameTag(monster, monsterData.name, Color3.fromRGB(255, 100, 100))
                
                -- HP label
                local hpLabel = Instance.new("TextLabel")
                hpLabel.Name = "HPLabel"
                hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
                hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
                hpLabel.BackgroundTransparency = 1
                hpLabel.Text = "HP: " .. monsterData.hp .. "/" .. monsterData.hp
                hpLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                hpLabel.TextStrokeTransparency = 0
                hpLabel.Font = Enum.Font.Gotham
                hpLabel.TextScaled = true
                hpLabel.Parent = billboard
                
                -- Start patrol
                startPatrol(monster, spawnPos)
                
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
