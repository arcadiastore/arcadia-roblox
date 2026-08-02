# Arcadia Online - Roblox Setup Guide

## Overview
Panduan lengkap untuk setup project Arcadia Online di Roblox Studio.

---

## Requirements

### Software
- **Roblox Studio** (latest version)
  - Download: https://www.roblox.com/create
- **Roblox Account** (Developer)
  - Daftar: https://www.roblox.com

### Skills
- Basic Luau scripting
- Roblox Studio navigation
- Basic 3D modeling (optional)

---

## Step 1: Create New Place

1. Open **Roblox Studio**
2. Click **New** → **Baseplate**
3. Save as **"Arcadia Online"**

---

## Step 2: Setup Project Structure

### Create Folders
Di **Explorer** window, buat folder berikut:

```
game
├── ServerScriptService
│   ├── Core
│   ├── Systems
│   └── Modules
├── ReplicatedStorage
│   ├── Modules
│   ├── Events
│   └── Assets
├── StarterPlayer
│   └── StarterPlayerScripts
│       └── Client
├── StarterGui
│   └── UI
└── Workspace
    ├── Maps
    ├── NPCs
    └── Monsters
```

### Cara Buat Folder:
1. Klik kanan di **Explorer**
2. Pilih **Insert Object** → **Folder**
3. Rename sesuai nama di atas

---

## Step 3: Import Scripts

### Copy Scripts dari Repository:
1. Copy semua file `.lua` dari folder `src/`
2. Paste ke folder yang sesuai di Roblox Studio

### Script Placement:
| Script | Lokasi di Roblox |
|--------|------------------|
| `GameManager.lua` | ServerScriptService/Core |
| `PlayerStats.lua` | ServerScriptService/Modules |
| `CombatSystem.lua` | ServerScriptService/Systems |
| `QuestManager.lua` | ServerScriptService/Systems |
| `InventoryManager.lua` | ServerScriptService/Systems |
| `MonsterAI.lua` | ServerScriptService/Modules |
| `NPCSystem.lua` | ServerScriptService/Modules |

### Setup Server Script:
1. Di **ServerScriptService**, buat **Script**
2. Rename jadi **"MainServer"**
3. Copy kode berikut:

```lua
-- MainServer.lua
-- Place di: ServerScriptService

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core modules
local GameManager = require(ServerScriptService.Core.GameManager)

-- Initialize game
GameManager:Init()

print("[Server] Arcadia Online initialized!")
```

---

## Step 4: Setup World

### Create Ground:
1. Di **Workspace**, buat **Part**
2. Rename jadi **"Ground"**
3. Set properties:
   - Size: `500, 1, 500`
   - Position: `0, 0, 0`
   - Anchored: `true`
   - Material: `Grass`
   - Color: `0, 150, 0`

### Create Spawn Point:
1. Buat **Part** kecil
2. Rename jadi **"SpawnPoint"**
3. Set properties:
   - Size: `10, 1, 10`
   - Position: `0, 1, 0`
   - Anchored: `true`
   - Transparency: `1`
   - CanCollide: `false`

---

## Step 5: Create NPCs

### Create NPC Template:
1. Di **Workspace** → **NPCs**, buat **Model**
2. Rename jadi **"Elder"**
3. Tambahkan:
   - **Part** (Body) - Size: `2, 3, 1`
   - **Part** (Head) - Size: `1, 1, 1` - Position above body
   - **Humanoid** (dari menu Insert)
   - **ClickDetector** (untuk interaksi)

### Setup NPC Script:
1. Di NPC Model, buat **Script**
2. Copy kode berikut:

```lua
-- NPCInteraction.lua
-- Place di dalam NPC Model

local npc = script.Parent
local clickDetector = npc:FindFirstChild("ClickDetector")

if clickDetector then
    clickDetector.MouseClick:Connect(function(player)
        -- Trigger interaction
        print(player.Name .. " interacted with " .. npc.Name)
        
        -- Show dialogue UI
        -- Implementation depends on UI system
    end)
end
```

### Create NPCs:
Buat NPC berikut:
- **Elder** (position: 0, 0, -15)
- **Blacksmith** (position: 20, 0, 0)
- **Merchant** (position: -20, 0, 0)
- **Guard** (position: 0, 0, 20)
- **TrainingMaster** (position: 0, 0, 10)

---

## Step 6: Create Monsters

### Create Monster Template:
1. Di **Workspace** → **Monsters**, buat **Model**
2. Rename jadi **"Slime"**
3. Tambahkan:
   - **Part** (Body) - Bentuk bola, Size: `3, 3, 3`
   - **Humanoid**
   - **Script** (MonsterAI)

### Monster Spawn Script:
```lua
-- MonsterSpawner.lua
-- Place di: ServerScriptService/Systems

local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")

local MonsterAI = require(ServerScriptService.Modules.MonsterAI)

-- Spawn monsters
local function SpawnMonster(monsterType, position, parent)
    -- Create monster model
    local monster = Instance.new("Model")
    monster.Name = monsterType
    
    -- Create body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(3, 3, 3)
    body.Position = position
    body.Anchored = false
    body.Parent = monster
    
    -- Add humanoid
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = monster
    
    -- Set parent
    monster.Parent = parent
    
    -- Initialize AI
    local ai = MonsterAI.new(monsterType, position)
    ai:SetCharacter(monster)
    
    return monster, ai
end

-- Spawn training dummies
SpawnMonster("Slime", Vector3.new(0, 2, 10), Workspace.Monsters)
SpawnMonster("Slime", Vector3.new(5, 2, 12), Workspace.Monsters)
SpawnMonster("Slime", Vector3.new(-5, 2, 12), Workspace.Monsters)

print("[Spawner] Monsters spawned!")
```

---

## Step 7: Create UI

### Setup Player GUI:
1. Di **StarterGui**, buat **ScreenGui**
2. Rename jadi **"GameUI"**
3. Tambahkan:
   - **Frame** (HP Bar)
   - **Frame** (MP Bar)
   - **TextLabel** (Level)
   - **TextLabel** (Gold)

### HP Bar Script:
```lua
-- HealthBar.lua
-- Place di: StarterGui/GameUI

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local healthBar = script.Parent:WaitForChild("HealthBar")
local fill = healthBar:WaitForChild("Fill")

-- Update health bar
humanoid.HealthChanged:Connect(function(health)
    local healthPercent = health / humanoid.MaxHealth
    fill.Size = UDim2.new(healthPercent, 0, 1, 0)
    
    -- Change color based on health
    if healthPercent > 0.5 then
        fill.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    elseif healthPercent > 0.25 then
        fill.BackgroundColor3 = Color3.fromRGB(255, 255, 50)
    else
        fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)
```

---

## Step 8: Testing

### Test Checklist:
- [ ] Player spawns at correct position
- [ ] NPC interaction works
- [ ] Monster AI works (patrol, chase, attack)
- [ ] Combat deals damage
- [ ] Quest system works
- [ ] UI updates correctly

### How to Test:
1. Click **Play** (F5)
2. Test each system
3. Check **Output** window for errors

---

## Common Issues

### Issue: Scripts not running
**Solution:**
- Make sure scripts are in correct locations
- Check Output window for errors
- Verify script is enabled

### Issue: NPC not interactive
**Solution:**
- Make sure ClickDetector is added
- Check script is inside NPC model
- Verify player is close enough

### Issue: Monster not moving
**Solution:**
- Make sure Humanoid is added
- Check MonsterAI script is running
- Verify spawn position is valid

---

## Next Steps

1. **Add More Monsters**: Create Wolf, Boar, Boss
2. **Create Quest System**: Implement quest UI
3. **Add Shop System**: Create shop UI
4. **Create Minimap**: Add minimap UI
5. **Add Sound Effects**: Import audio
6. **Polish UI**: Improve visual design

---

## Resources

- **Roblox Developer Hub**: https://developer.roblox.com
- **Luau Documentation**: https://luau-lang.org
- **Roblox API Reference**: https://developer.roblox.com/en-us/api-reference

---

## Support

Jika ada masalah, cek:
1. Output window untuk error
2. Script properties
3. Folder structure

---

**Selamat mengembangkan Arcadia Online!** 🚀
