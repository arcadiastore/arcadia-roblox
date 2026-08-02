# TDD - Luau Coding Standard

## Overview
Standar penulisan kode Luau untuk Arcadia Online.

---

## Naming Conventions

### Variables
```lua
-- camelCase untuk variables
local playerHealth = 100
local maxLevel = 100
local isActive = true

-- PascalCase untuk constants
local MAX_PLAYERS = 50
local STARTING_GOLD = 100
local DAMAGE_MULTIPLIER = 1.5
```

### Functions
```lua
-- camelCase untuk functions
local function calculateDamage(attacker, target)
    -- Implementation
end

-- PascalCase untuk methods
function CombatSystem:CalculateDamage(attacker, target)
    -- Implementation
end
```

### Classes/Modules
```lua
-- PascalCase untuk class names
local PlayerStats = {}
PlayerStats.__index = PlayerStats

function PlayerStats.new()
    local self = setmetatable({}, PlayerStats)
    return self
end
```

### Tables
```lua
-- camelCase untuk tables
local playerData = {
    name = "Player",
    level = 1,
    exp = 0,
}

-- snake_case untuk database keys
local monsterDatabase = {
    slime = { name = "Slime", hp = 50 },
    wolf = { name = "Wolf", hp = 120 },
}
```

---

## Code Structure

### Module Template
```lua
--[[
    Module Name
    
    Description of what this module does.
    
    @author arcadiastore
    @version 1.0.0
]]

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Module
local ModuleName = {}
ModuleName.__index = ModuleName

-- Constructor
function ModuleName.new()
    local self = setmetatable({}, ModuleName)
    
    -- Initialize properties
    self.property = value
    
    return self
end

-- Methods
function ModuleName:MethodName()
    -- Implementation
end

-- Return singleton or class
return ModuleName.new()
```

### Script Template
```lua
--[[
    Script Name
    
    Description of what this script does.
    
    @author arcadiastore
    @version 1.0.0
]]

-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Modules
local GameManager = require(ServerScriptService.Core.GameManager)

-- Variables
local variable = value

-- Functions
local function functionName()
    -- Implementation
end

-- Main
functionName()

-- Events
Players.PlayerAdded:Connect(function(player)
    -- Handle player join
end)
```

---

## Error Handling

### pcall Usage
```lua
-- Always wrap potentially failing code
local success, result = pcall(function()
    return DataStore:GetAsync(key)
end)

if success then
    return result
else
    warn("Error: " .. tostring(result))
    return nil
end
```

### Assert Usage
```lua
-- Validate inputs
local function processDamage(attacker, target, damage)
    assert(attacker, "Attacker is required")
    assert(target, "Target is required")
    assert(damage > 0, "Damage must be positive")
    
    -- Process damage
end
```

---

## Comments

### Single Line
```lua
-- This is a comment
local x = 5  -- Inline comment
```

### Multi-line
```lua
--[[
    This is a multi-line comment.
    Use for function documentation.
]]
```

### Function Documentation
```lua
--[[
    Calculate damage from attacker to target.
    
    @param attacker table - The attacker's stats
    @param target table - The target's stats
    @param skillData table - Optional skill data
    @return table - { damage, isCritical, damageType }
]]
function CombatSystem:CalculateDamage(attacker, target, skillData)
    -- Implementation
end
```

---

## Performance Tips

### Local Variables
```lua
-- Good: Local variables are faster
local mathFloor = math.floor
local mathRandom = math.random

local function calculateDamage()
    return mathFloor(mathRandom(10, 20))
end
```

### Table Creation
```lua
-- Good: Reuse tables when possible
local tempVector = Vector3.new()

local function updatePosition(position)
    tempVector = position * 2
    return tempVector
end

-- Bad: Creating new tables every frame
local function updatePosition(position)
    return Vector3.new(position.X * 2, position.Y * 2, position.Z * 2)
end
```

### Avoid Global Variables
```lua
-- Good: Use local
local myVariable = 5

-- Bad: Global (slower access)
myVariable = 5
```

---

## File Organization

### Import Order
```lua
-- 1. Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 2. Modules
local CombatSystem = require(script.Parent.CombatSystem)
local QuestManager = require(script.Parent.QuestManager)

-- 3. Constants
local MAX_HEALTH = 100
local DAMAGE_MULTIPLIER = 1.5

-- 4. Variables
local currentHealth = MAX_HEALTH

-- 5. Functions
local function calculateDamage()
    -- Implementation
end

-- 6. Main Logic
calculateDamage()

-- 7. Events
Players.PlayerAdded:Connect(function(player)
    -- Handle
end)
```

---

## Type Checking (Luau)

### Type Annotations
```lua
-- Function with types
local function add(a: number, b: number): number
    return a + b
end

-- Table with types
type PlayerData = {
    name: string,
    level: number,
    exp: number,
    gold: number,
}

-- Class with types
local PlayerStats = {}
PlayerStats.__index = PlayerStats

function PlayerStats.new(job: string): PlayerStats
    local self = setmetatable({}, PlayerStats)
    self.job = job
    self.level = 1
    return self
end
```

---

## Testing

### Unit Test Template
```lua
--[[
    Unit Tests for CombatSystem
    
    Run: game:GetService("TestService"):Run()
]]

local TestService = game:GetService("TestService")

local CombatSystem = require(script.Parent.CombatSystem)

-- Test: Calculate damage
local function testCalculateDamage()
    local attacker = { atk = 10, STR = 5 }
    local target = { def = 5, VIT = 3 }
    
    local result = CombatSystem:CalculateDamage(attacker, target)
    
    TestService:Check(result.damage > 0, "Damage should be positive")
    TestService:Check(result.damage == math.floor(result.damage), "Damage should be integer")
end

-- Run tests
testCalculateDamage()
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-08-02 | Initial Luau coding standard |
