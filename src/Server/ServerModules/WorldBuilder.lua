--[[
    WorldBuilder.lua
    Spawns NPCs and Monsters with patrol + combat AI
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local GameData = require(game.ReplicatedStorage:WaitForChild("GameData"))

-- Get PlayerData module (loaded after MainServer)
local PlayerData = nil
local function getPlayerData()
    if not PlayerData then
        local ok, mod = pcall(function()
            return require(ServerScriptService.MainServer.ServerModules.PlayerData)
        end)
        if ok then PlayerData = mod end
    end
    return PlayerData
end

local WorldBuilder = {}

-- Settings
local PATROL_RADIUS = 15
local PATROL_SPEED = 3
local PATROL_WAIT_MIN = 2
local PATROL_WAIT_MAX = 5
local CHASE_RANGE = 20     -- Detect player within this range
local ATTACK_RANGE = 8     -- Attack player within this range
local RETURN_RANGE = 30    -- Return to spawn if player goes beyond this
local ATTACK_COOLDOWN = 2  -- Seconds between monster attacks

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

-- Get nearest player to a position
local function getNearestPlayer(pos, maxRange)
    local nearest = nil
    local nearestDist = maxRange
    
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (root.Position - pos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = {player = plr, rootPart = root, dist = dist}
                end
            end
        end
    end
    
    return nearest
end

-- Monster AI loop
local function monsterAI(monster, spawnPos, monsterData)
    local state = "PATROL"  -- PATROL, CHASE, ATTACK, RETURN
    local currentTween = nil
    local lastAttackTime = 0
    
    while monster and monster.Parent do
        local hp = monster:GetAttribute("CurrentHP") or 0
        
        -- Dead: wait for respawn
        if hp <= 0 then
            state = "PATROL"
            if currentTween then currentTween:Cancel() currentTween = nil end
            task.wait(2)
            continue
        end
        
        local monsterPos = monster.Position
        
        if state == "PATROL" then
            -- Check for nearby players
            local target = getNearestPlayer(monsterPos, CHASE_RANGE)
            if target then
                state = "CHASE"
                if currentTween then currentTween:Cancel() currentTween = nil end
                continue
            end
            
            -- Random patrol movement
            if not currentTween or not currentTween.PlaybackState == Enum.PlaybackState.Playing then
                local angle = math.random() * math.pi * 2
                local distance = math.random() * PATROL_RADIUS
                local targetPos = spawnPos + Vector3.new(math.cos(angle) * distance, spawnPos.Y, math.sin(angle) * distance)
                local dist = (targetPos - monster.Position).Magnitude
                local duration = math.max(dist / PATROL_SPEED, 0.5)
                
                currentTween = TweenService:Create(monster, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Position = targetPos})
                currentTween:Play()
            end
            
            task.wait(1)
            
        elseif state == "CHASE" then
            local target = getNearestPlayer(monsterPos, RETURN_RANGE)
            
            if not target then
                -- Player left area, return to spawn
                state = "RETURN"
                if currentTween then currentTween:Cancel() currentTween = nil end
                continue
            end
            
            if target.dist <= ATTACK_RANGE then
                -- Close enough to attack
                state = "ATTACK"
                if currentTween then currentTween:Cancel() currentTween = nil end
                continue
            end
            
            -- Move toward player
            monster.Position = monster.Position:Lerp(target.rootPart.Position, 0.1)
            
            task.wait(0.3)
            
        elseif state == "ATTACK" then
            local target = getNearestPlayer(monsterPos, ATTACK_RANGE + 2)
            
            if not target then
                state = "RETURN"
                continue
            end
            
            if target.dist > ATTACK_RANGE + 2 then
                -- Player moved away, chase again
                state = "CHASE"
                continue
            end
            
            -- Attack with cooldown
            local now = tick()
            if now - lastAttackTime >= ATTACK_COOLDOWN then
                lastAttackTime = now
                
                local humanoid = target.rootPart.Parent:FindFirstChild("Humanoid")
                if humanoid then
                    local damage = monsterData.atk or 5
                    
                    -- Update playerData HP
                    local pd = getPlayerData()
                    local pData = pd and pd:Get(target.player)
                    
                    if pData then
                        pData.hp = math.max(0, pData.hp - damage)
                        humanoid.Health = pData.hp
                        
                        local events = game.ReplicatedStorage:FindFirstChild("Events")
                        if events then
                            pd:SendUpdate(target.player, events)
                            events.UpdateEvent:FireClient(target.player, {
                                type = "MonsterAttack",
                                monsterName = monsterData.name,
                                damage = damage,
                            })
                            
                            -- Check if player died
                            if pData.hp <= 0 then
                                -- Send death event
                                events.UpdateEvent:FireClient(target.player, {
                                    type = "PlayerDied",
                                })
                                print("[World] " .. target.player.Name .. " killed by " .. monsterData.name)
                            end
                        end
                    else
                        humanoid:TakeDamage(damage)
                    end
                end
            end
            
            -- Face player
            local dir = (target.rootPart.Position - monsterPos).Unit
            monster.CFrame = CFrame.lookAt(monsterPos, monsterPos + Vector3.new(dir.X, 0, dir.Z))
            
            task.wait(0.5)
            
        elseif state == "RETURN" then
            -- Move back to spawn
            local dist = (spawnPos - monster.Position).Magnitude
            if dist > 2 then
                monster.Position = monster.Position:Lerp(spawnPos, 0.1)
                task.wait(0.3)
            else
                -- Arrived at spawn
                monster.Position = spawnPos
                state = "PATROL"
                task.wait(1)
            end
        end
    end
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
        
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 20
        clickDetector.Parent = npc
        
        createNameTag(npc, npcData.name, Color3.fromRGB(100, 255, 100))
        print("[World] NPC spawned: " .. npcData.name)
    end
    
    print("[World] All NPCs spawned!")
end

-- Spawn all monsters with AI
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
                
                local clickDetector = Instance.new("ClickDetector")
                clickDetector.MaxActivationDistance = 20
                clickDetector.Parent = monster
                
                local billboard = createNameTag(monster, monsterData.name, Color3.fromRGB(255, 100, 100))
                
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
                
                -- Start monster AI
                task.spawn(function()
                    monsterAI(monster, spawnPos, monsterData)
                end)
                
                print("[World] Monster spawned: " .. monsterData.name .. " at " .. tostring(pos))
            end
        end
    end
    
    print("[World] All monsters spawned!")
end

-- Spawn checkpoints
function WorldBuilder:SpawnCheckpoints()
    local cpFolder = Instance.new("Folder")
    cpFolder.Name = "Checkpoints"
    cpFolder.Parent = workspace
    
    local checkpoints = GameData.SpawnPositions and GameData.SpawnPositions["Checkpoints"]
    if not checkpoints then
        warn("[World] No checkpoint data found!")
        return
    end
    
    for i, cp in ipairs(checkpoints) do
        -- Create checkpoint tower
        local tower = Instance.new("Part")
        tower.Name = "Checkpoint_" .. cp.area
        tower.Size = Vector3.new(3, 6, 3)
        tower.Position = cp.position + Vector3.new(0, 3, 0)
        tower.Anchored = true
        tower.BrickColor = BrickColor.new("Cyan")
        tower.Material = Enum.Material.Neon
        tower.CanCollide = false
        tower.Parent = cpFolder
        
        -- Glow effect
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(0, 255, 255)
        light.Range = 15
        light.Brightness = 2
        light.Parent = tower
        
        -- ClickDetector for interaction
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.MaxActivationDistance = 15
        clickDetector.Parent = tower
        
        -- Name tag
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 150, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = tower
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "📍 " .. cp.name
        nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.Parent = billboard
        
        -- Click detection - save checkpoint
        clickDetector.MouseClick:Connect(function(player)
            local pd = getPlayerData()
            if not pd then return end
            
            local pData = pd:Get(player)
            if not pData then return end
            
            -- Save checkpoint position
            local oldCP = pData.lastCheckpoint
            local newCP = cp.position
            
            -- Only update if different checkpoint
            if (oldCP - newCP).Magnitude > 5 then
                pData.lastCheckpoint = newCP
                
                local events = game.ReplicatedStorage:FindFirstChild("Events")
                if events then
                    pd:SendUpdate(player, events)
                    events.UpdateEvent:FireClient(player, {
                        type = "Notification",
                        text = "Checkpoint tersimpan: " .. cp.name,
                        notifType = "info",
                    })
                end
                print("[Checkpoint] " .. player.Name .. " saved: " .. cp.name)
            end
        end)
        
        print("[World] Checkpoint: " .. cp.name .. " at " .. tostring(cp.position))
    end
    
    print("[World] All checkpoints spawned!")
end

-- Create Green Forest area
function WorldBuilder:CreateGreenForest()
    print("[World] Creating Green Forest...")
    
    local forestFolder = Instance.new("Folder")
    forestFolder.Name = "GreenForest"
    forestFolder.Parent = workspace
    
    -- Green ground
    local ground = Instance.new("Part")
    ground.Name = "GreenForestGround"
    ground.Size = Vector3.new(100, 1, 80)
    ground.Position = Vector3.new(0, -0.5, -140)
    ground.Anchored = true
    ground.Color = Color3.fromRGB(34, 100, 34)
    ground.Material = Enum.Material.Grass
    ground.Parent = forestFolder
    
    -- Trees (decorative)
    local treePositions = {
        Vector3.new(-30, 0, -120), Vector3.new(-25, 0, -135), Vector3.new(-15, 0, -145),
        Vector3.new(10, 0, -125), Vector3.new(20, 0, -140), Vector3.new(30, 0, -130),
        Vector3.new(-40, 0, -130), Vector3.new(35, 0, -145), Vector3.new(-35, 0, -150),
        Vector3.new(25, 0, -150), Vector3.new(0, 0, -155), Vector3.new(-10, 0, -115),
    }
    
    for i, pos in ipairs(treePositions) do
        local tree = Instance.new("Model")
        tree.Name = "Tree_" .. i
        tree.Parent = forestFolder
        
        -- Trunk
        local trunk = Instance.new("Part")
        trunk.Name = "Trunk"
        trunk.Size = Vector3.new(2, 8, 2)
        trunk.Position = pos + Vector3.new(0, 4, 0)
        trunk.Anchored = true
        trunk.Color = Color3.fromRGB(101, 67, 33)
        trunk.Material = Enum.Material.Wood
        trunk.Parent = tree
        
        -- Leaves
        local leaves = Instance.new("Part")
        leaves.Name = "Leaves"
        leaves.Size = Vector3.new(8, 6, 8)
        leaves.Position = pos + Vector3.new(0, 10, 0)
        leaves.Anchored = true
        leaves.Color = Color3.fromRGB(34, 139, 34)
        leaves.Material = Enum.Material.Grass
        leaves.Shape = Enum.PartType.Ball
        leaves.Parent = tree
    end
    
    -- Forest Gate (entry arch)
    local gate = Instance.new("Part")
    gate.Name = "ForestGate"
    gate.Size = Vector3.new(12, 10, 2)
    gate.Position = Vector3.new(0, 5, -105)
    gate.Anchored = true
    gate.Color = Color3.fromRGB(139, 90, 43)
    gate.Material = Enum.Material.Wood
    gate.Parent = forestFolder
    
    -- Gate sign
    local sign = Instance.new("BillboardGui")
    sign.Size = UDim2.new(0, 200, 0, 50)
    sign.StudsOffset = Vector3.new(0, 7, 0)
    sign.AlwaysOnTop = true
    sign.Parent = gate
    
    local signLabel = Instance.new("TextLabel")
    signLabel.Size = UDim2.new(1, 0, 1, 0)
    signLabel.BackgroundTransparency = 1
    signLabel.Text = "GREEN FOREST"
    signLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    signLabel.TextSize = 24
    signLabel.Font = Enum.Font.SourceSansBold
    signLabel.Parent = sign
    
    print("[World] Green Forest created!")
end

-- Build the entire world
function WorldBuilder:Build()
    print("[World] Building world...")
    self:CreateGreenForest()
    self:SpawnNPCs()
    self:SpawnMonsters()
    self:SpawnCheckpoints()
    print("[World] World built!")
end

return WorldBuilder
