--[[
    Arcadia Online - Monster AI
    
    Handles monster behavior:
    - Patrol
    - Chase
    - Attack
    - Death
    
    @author arcadiastore
    @version 1.0.0
]]

local MonsterAI = {}
MonsterAI.__index = MonsterAI

-- Monster states
local MonsterState = {
    IDLE = "Idle",
    PATROL = "Patrol",
    CHASE = "Chase",
    ATTACK = "Attack",
    DEAD = "Dead",
}

-- Monster definitions
local MonsterDatabase = {
    Slime = {
        name = "Slime",
        level = 1,
        maxHp = 50,
        atk = 5,
        def = 3,
        exp = 20,
        gold = 10,
        drops = {
            { itemId = "slime_gel", chance = 0.5, min = 1, max = 2 },
            { itemId = "potion_hp_small", chance = 0.1, min = 1, max = 1 },
        },
        patrolRadius = 10,
        chaseRadius = 15,
        attackRange = 3,
        attackCooldown = 2,
    },
    Wolf = {
        name = "Wolf",
        level = 5,
        maxHp = 120,
        atk = 15,
        def = 8,
        exp = 50,
        gold = 25,
        drops = {
            { itemId = "wolf_fang", chance = 0.4, min = 1, max = 2 },
            { itemId = "potion_hp_small", chance = 0.15, min = 1, max = 1 },
        },
        patrolRadius = 15,
        chaseRadius = 20,
        attackRange = 4,
        attackCooldown = 1.5,
    },
    Boar = {
        name = "Boar",
        level = 7,
        maxHp = 180,
        atk = 20,
        def = 12,
        exp = 80,
        gold = 40,
        drops = {
            { itemId = "herb", chance = 0.3, min = 1, max = 3 },
        },
        patrolRadius = 12,
        chaseRadius = 18,
        attackRange = 4,
        attackCooldown = 2,
    },
    Guardian = {
        name = "Guardian of the Forest",
        level = 10,
        maxHp = 500,
        atk = 35,
        def = 20,
        exp = 200,
        gold = 100,
        isBoss = true,
        drops = {
            { itemId = "sword_iron", chance = 0.5, min = 1, max = 1 },
            { itemId = "armor_iron", chance = 0.3, min = 1, max = 1 },
        },
        patrolRadius = 20,
        chaseRadius = 25,
        attackRange = 5,
        attackCooldown = 2.5,
    },
}

function MonsterAI.new(monsterType, spawnPosition)
    local self = setmetatable({}, MonsterAI)
    
    local monsterDef = MonsterDatabase[monsterType]
    if not monsterDef then
        error("Unknown monster type: " .. monsterType)
    end
    
    self.type = monsterType
    self.name = monsterDef.name
    self.level = monsterDef.level
    self.maxHp = monsterDef.maxHp
    self.hp = monsterDef.maxHp
    self.atk = monsterDef.atk
    self.def = monsterDef.def
    self.exp = monsterDef.exp
    self.gold = monsterDef.gold
    self.drops = monsterDef.drops
    self.isBoss = monsterDef.isBoss or false
    
    self.state = MonsterState.IDLE
    self.spawnPosition = spawnPosition or Vector3.new(0, 0, 0)
    self.target = nil
    self.lastAttackTime = 0
    self.attackCooldown = monsterDef.attackCooldown
    self.patrolRadius = monsterDef.patrolRadius
    self.chaseRadius = monsterDef.chaseRadius
    self.attackRange = monsterDef.attackRange
    
    self.character = nil  -- Roblox character model
    self.alive = true
    
    return self
end

-- Set the monster's character model
function MonsterAI:SetCharacter(character)
    self.character = character
    
    -- Setup health bar
    self:SetupHealthBar()
end

-- Setup health bar above monster
function MonsterAI:SetupHealthBar()
    if not self.character then return end
    
    local humanoidRootPart = self.character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Create BillboardGui for health bar
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.new(4, 0, 0.5, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = humanoidRootPart
    billboard.Parent = self.character
    
    -- Background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    background.BorderSizePixel = 0
    background.Parent = billboard
    
    -- Health fill
    local healthFill = Instance.new("Frame")
    healthFill.Name = "HealthFill"
    healthFill.Size = UDim2.new(1, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    healthFill.BorderSizePixel = 0
    healthFill.Parent = background
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = self.name .. " Lv." .. self.level
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = background
end

-- Update health bar
function MonsterAI:UpdateHealthBar()
    if not self.character then return end
    
    local healthBar = self.character:FindFirstChild("HealthBar")
    if healthBar then
        local background = healthBar:FindFirstChild("Background")
        if background then
            local healthFill = background:FindFirstChild("HealthFill")
            if healthFill then
                local healthPercent = self.hp / self.maxHp
                healthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                
                -- Change color based on health
                if healthPercent > 0.5 then
                    healthFill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                elseif healthPercent > 0.25 then
                    healthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
                else
                    healthFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
                end
            end
        end
    end
end

-- Take damage
function MonsterAI:TakeDamage(damage, attacker)
    if not self.alive then return end
    
    -- Apply damage
    self.hp = math.max(0, self.hp - damage)
    
    -- Update health bar
    self:UpdateHealthBar()
    
    -- Set target to attacker
    if attacker then
        self.target = attacker
        self.state = MonsterState.CHASE
    end
    
    -- Check for death
    if self.hp <= 0 then
        self:Die(attacker)
    end
    
    return damage
end

-- Die
function MonsterAI:Die(killer)
    if not self.alive then return end
    
    self.alive = false
    self.state = MonsterState.DEAD
    
    print("[Monster] " .. self.name .. " defeated!")
    
    -- Award EXP and gold to killer
    if killer then
        self:DropLoot(killer)
    end
    
    -- Remove character after delay
    task.delay(3, function()
        if self.character then
            self.character:Destroy()
        end
    end)
end

-- Drop loot
function MonsterAI:DropLoot(killer)
    -- Calculate drops
    local drops = {}
    
    for _, drop in ipairs(self.drops) do
        if math.random() <= drop.chance then
            local amount = math.random(drop.min, drop.max)
            table.insert(drops, { itemId = drop.itemId, amount = amount })
        end
    end
    
    -- Award gold
    local goldAmount = math.random(math.floor(self.gold * 0.8), math.floor(self.gold * 1.2))
    
    -- Send rewards to killer
    -- This would connect to the inventory and player systems
    print("[Monster] Dropped: " .. goldAmount .. " gold")
    for _, drop in ipairs(drops) do
        print("[Monster] Dropped: " .. drop.amount .. "x " .. drop.itemId)
    end
    
    return {
        exp = self.exp,
        gold = goldAmount,
        drops = drops,
    }
end

-- Update AI
function MonsterAI:Update(deltaTime)
    if not self.alive or not self.character then return end
    
    local humanoidRootPart = self.character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local currentPosition = humanoidRootPart.Position
    
    -- State machine
    if self.state == MonsterState.IDLE then
        self:UpdateIdle(currentPosition)
    elseif self.state == MonsterState.PATROL then
        self:UpdatePatrol(currentPosition, deltaTime)
    elseif self.state == MonsterState.CHASE then
        self:UpdateChase(currentPosition, deltaTime)
    elseif self.state == MonsterState.ATTACK then
        self:UpdateAttack(currentPosition, deltaTime)
    end
end

-- Update idle state
function MonsterAI:UpdateIdle(currentPosition)
    -- Check for nearby players
    local nearestPlayer = self:FindNearestPlayer(currentPosition)
    if nearestPlayer then
        self.target = nearestPlayer
        self.state = MonsterState.CHASE
    else
        -- Start patrolling
        self.state = MonsterState.PATROL
        self.patrolTarget = self:GetRandomPatrolPoint()
    end
end

-- Update patrol state
function MonsterAI:UpdatePatrol(currentPosition, deltaTime)
    -- Move towards patrol target
    if self.patrolTarget then
        local direction = (self.patrolTarget - currentPosition).Unit
        local distance = (self.patrolTarget - currentPosition).Magnitude
        
        if distance < 2 then
            -- Reached patrol point, go idle
            self.state = MonsterState.IDLE
        else
            -- Move towards patrol point
            self:Move(direction, deltaTime)
        end
    end
    
    -- Check for nearby players
    local nearestPlayer = self:FindNearestPlayer(currentPosition)
    if nearestPlayer then
        self.target = nearestPlayer
        self.state = MonsterState.CHASE
    end
end

-- Update chase state
function MonsterAI:UpdateChase(currentPosition, deltaTime)
    if not self.target then
        self.state = MonsterState.IDLE
        return
    end
    
    local targetPosition = self.target.Character and self.target.Character:FindFirstChild("HumanoidRootPart")
    if not targetPosition then
        self.state = MonsterState.IDLE
        return
    end
    
    local targetPos = targetPosition.Position
    local distance = (targetPos - currentPosition).Magnitude
    
    -- Check if target is too far
    if distance > self.chaseRadius then
        self.target = nil
        self.state = MonsterState.PATROL
        self.patrolTarget = self:GetRandomPatrolPoint()
        return
    end
    
    -- Check if in attack range
    if distance <= self.attackRange then
        self.state = MonsterState.ATTACK
    else
        -- Move towards target
        local direction = (targetPos - currentPosition).Unit
        self:Move(direction, deltaTime)
    end
end

-- Update attack state
function MonsterAI:UpdateAttack(currentPosition, deltaTime)
    if not self.target then
        self.state = MonsterState.IDLE
        return
    end
    
    local targetPosition = self.target.Character and self.target.Character:FindFirstChild("HumanoidRootPart")
    if not targetPosition then
        self.state = MonsterState.IDLE
        return
    end
    
    local targetPos = targetPosition.Position
    local distance = (targetPos - currentPosition).Magnitude
    
    -- Check if target moved out of range
    if distance > self.attackRange then
        self.state = MonsterState.CHASE
        return
    end
    
    -- Attack cooldown
    local currentTime = tick()
    if currentTime - self.lastAttackTime >= self.attackCooldown then
        self:Attack(self.target)
        self.lastAttackTime = currentTime
    end
end

-- Attack target
function MonsterAI:Attack(target)
    if not target or not target.Character then return end
    
    local humanoid = target.Character:FindFirstChild("Humanoid")
    if humanoid then
        -- Calculate damage
        local damage = self.atk
        
        -- Apply damage
        humanoid.Health = humanoid.Health - damage
        
        print("[Monster] " .. self.name .. " attacked " .. target.Name .. " for " .. damage .. " damage")
    end
end

-- Move in direction
function MonsterAI:Move(direction, deltaTime)
    if not self.character then return end
    
    local humanoidRootPart = self.character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local speed = 10  -- Movement speed
    local movement = direction * speed * deltaTime
    
    humanoidRootPart.CFrame = humanoidRootPart.CFrame + movement
end

-- Find nearest player
function MonsterAI:FindNearestPlayer(position)
    local Players = game:GetService("Players")
    local nearestPlayer = nil
    local nearestDistance = self.chaseRadius
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestPlayer = player
                end
            end
        end
    end
    
    return nearestPlayer
end

-- Get random patrol point
function MonsterAI:GetRandomPatrolPoint()
    local angle = math.random() * math.pi * 2
    local distance = math.random() * self.patrolRadius
    
    return self.spawnPosition + Vector3.new(
        math.cos(angle) * distance,
        0,
        math.sin(angle) * distance
    )
end

-- Get monster info
function MonsterAI:GetInfo()
    return {
        name = self.name,
        level = self.level,
        hp = self.hp,
        maxHp = self.maxHp,
        state = self.state,
        isBoss = self.isBoss,
    }
end

return MonsterAI
