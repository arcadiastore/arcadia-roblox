# TDD - Roblox Architecture

## Overview
Dokumen ini menjelaskan arsitektur teknis untuk Arcadia Online di platform Roblox.

---

## Roblox Game Structure

### Folder Hierarchy
```
game
├── ServerScriptService          # Server-side scripts
│   ├── Core/                    # Core systems
│   │   ├── GameManager.lua
│   │   └── DataManager.lua
│   ├── Systems/                 # Game systems
│   │   ├── CombatSystem.lua
│   │   ├── QuestManager.lua
│   │   └── InventoryManager.lua
│   └── Modules/                 # Shared modules
│       ├── PlayerStats.lua
│       ├── MonsterAI.lua
│       └── NPCSystem.lua
│
├── ReplicatedStorage            # Shared between client/server
│   ├── Modules/                 # Client-side modules
│   ├── Events/                  # RemoteEvents
│   │   ├── CombatEvent.lua
│   │   ├── QuestEvent.lua
│   │   └── UIEvent.lua
│   └── Assets/                  # Shared assets
│
├── StarterPlayer
│   └── StarterPlayerScripts     # Client-side scripts
│       ├── Client/
│       │   ├── InputHandler.lua
│       │   ├── UIManager.lua
│       │   └── CameraController.lua
│       └── Modules/
│
├── StarterGui                   # UI scripts
│   └── UI/
│       ├── HUD.lua
│       ├── QuestUI.lua
│       └── InventoryUI.lua
│
└── Workspace                    # 3D world
    ├── Maps/
    │   ├── BeginnerVillage/
    │   ├── GreenForest/
    │   └── SageTower/
    ├── NPCs/
    │   ├── Elder/
    │   ├── Blacksmith/
    │   └── Merchant/
    └── Monsters/
        ├── Slime/
        ├── Wolf/
        └── Boar/
```

---

## Client-Server Architecture

### Communication Pattern
```
Client (Local Script)
    ↓
RemoteEvent / RemoteFunction
    ↓
Server Script
    ↓
Process & Validate
    ↓
Update State
    ↓
Replicate to Client
```

### RemoteEvents (Client → Server)
| Event | Purpose |
|-------|---------|
| `CombatEvent` | Player attacks, skill usage |
| `QuestEvent` | Accept/complete quests |
| `InventoryEvent` | Use/equip items |
| `ShopEvent` | Buy/sell items |
| `NPCEvent` | NPC interaction |

### RemoteEvents (Server → Client)
| Event | Purpose |
|-------|---------|
| `UIUpdateEvent` | Update UI elements |
| `DamageEvent` | Show damage numbers |
| `QuestUpdateEvent` | Quest progress |
| `NotificationEvent` | Show notifications |

---

## Data Flow

### Player Join
```
1. PlayerAdded event
2. Load data from DataStore
3. Create player state
4. Send data to client
5. Setup character
```

### Combat Flow
```
1. Client: Player clicks enemy
2. Client: Send CombatEvent to server
3. Server: Validate attack (range, cooldown)
4. Server: Calculate damage
5. Server: Apply damage to monster
6. Server: Send DamageEvent to client
7. Client: Show damage number
8. Server: Check monster death
9. Server: Award EXP/loot
```

---

## Module System

### Server Modules (ServerScriptService)
```lua
-- Require modules
local GameManager = require(ServerScriptService.Core.GameManager)
local CombatSystem = require(ServerScriptService.Systems.CombatSystem)

-- Singleton pattern
local QuestManager = {}
QuestManager.__index = QuestManager

function QuestManager.new()
    local self = setmetatable({}, QuestManager)
    -- Initialize
    return self
end

return QuestManager.new()
```

### Client Modules (ReplicatedStorage)
```lua
-- Client-side modules
local UIManager = require(ReplicatedStorage.Modules.UIManager)

-- Usage
UIManager:UpdateHealthBar(health, maxHealth)
```

---

## DataStore Strategy

### Save Structure
```lua
local playerData = {
    -- Player info
    userId = 123456789,
    username = "PlayerName",
    
    -- Progress
    level = 10,
    exp = 5000,
    gold = 1000,
    job = "Warrior",
    
    -- Stats
    stats = {
        STR = 15,
        AGI = 10,
        INT = 5,
        VIT = 12,
        DEX = 8,
        LUK = 6,
    },
    
    -- Inventory
    inventory = {
        items = {
            { itemId = "sword_iron", amount = 1 },
            { itemId = "potion_hp", amount = 5 },
        },
        equipment = {
            MainHand = "sword_iron",
            Body = "armor_leather",
        },
    },
    
    -- Quests
    quests = {
        active = {},
        completed = {},
    },
    
    -- Position
    position = { x = 0, y = 5, z = 0 },
}
```

### Auto-Save
```lua
-- Auto-save every 5 minutes
task.spawn(function()
    while true do
        task.wait(300) -- 5 minutes
        for _, player in ipairs(Players:GetPlayers()) do
            SavePlayerData(player)
        end
    end
end)
```

---

## Performance Optimization

### Object Pooling
```lua
-- Pool for monsters
local MonsterPool = {}

function MonsterPool:GetMonster(monsterType)
    if #self.pool[monsterType] > 0 then
        return table.remove(self.pool[monsterType])
    else
        return self:CreateMonster(monsterType)
    end
end

function MonsterPool:ReturnMonster(monster)
    monster.Character.Parent = nil
    table.insert(self.pool[monster.type], monster)
end
```

### Chunk Loading
```lua
-- Load/unload chunks based on player position
local function UpdateChunks(player)
    local position = player.Character.HumanoidRootPart.Position
    
    for chunkPos, chunk in pairs(chunks) do
        local distance = (chunkPos - position).Magnitude
        
        if distance < LOAD_DISTANCE then
            chunk:Load()
        elseif distance > UNLOAD_DISTANCE then
            chunk:Unload()
        end
    end
end
```

---

## Security

### Server-Side Validation
```lua
-- Always validate on server
local function OnCombatEvent(player, targetId)
    -- Validate player exists
    local character = player.Character
    if not character then return end
    
    -- Validate target exists
    local target = Workspace:FindFirstChild(targetId)
    if not target then return end
    
    -- Validate range
    local distance = (character.HumanoidRootPart.Position - target.Position).Magnitude
    if distance > MAX_ATTACK_RANGE then return end
    
    -- Validate cooldown
    if not CanAttack(player) then return end
    
    -- Process attack
    ProcessAttack(player, target)
end
```

---

## Error Handling

### pcall for DataStore
```lua
local success, data = pcall(function()
    return DataStore:GetAsync(key)
end)

if success then
    -- Use data
else
    warn("Failed to load data: " .. tostring(data))
    -- Use default data
end
```

---

## Monitoring

### Performance Metrics
```lua
-- Track FPS
local fps = 0
local lastUpdate = tick()

game:GetService("RunService").Heartbeat:Connect(function()
    fps = fps + 1
    if tick() - lastUpdate >= 1 then
        -- Log FPS
        fps = 0
        lastUpdate = tick()
    end
end)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-08-02 | Initial Roblox architecture |
