# Arcadia Online - Roblox MMORPG

## ⚠️ GOLDEN RULES (WAJIB IKUTI)

### 1. NO HARDCODING
**SEMUA data game harus dari `GameData` module!**

```lua
-- ✅ BENAR: Baca dari GameData
local GameData = require(ReplicatedStorage.GameData)
local slime = GameData:GetMonster("Slime")
local sword = GameData:GetItem("iron_sword")

-- ❌ SALAH: Hardcode di script
local hp = 50  -- JANGAN!
local name = "Slime"  -- JANGAN!
```

**Kenapa?**
- Mudah tambah/kurang content
- Satu sumber kebenaran
- Tidak perlu edit banyak file

### 2. ONLINE GAME (MULTIPLAYER)
**Ini adalah game ONLINE — Roblox adalah platform multiplayer!**

```lua
-- ✅ BENAR: Server authoritative
-- Semua validasi di server
local function handleAttack(player, target)
    -- Server validates everything
    local playerData = getPlayerData(player)
    if isValidTarget(target) then
        -- Process attack
    end
end

-- ❌ SALAH: Client-side validation
-- Client bisa di-hack!
```

**Arsitektur:**
- **Server**: Game logic, data validation, anti-cheat
- **Client**: UI, input, visual effects only
- **RemoteEvents**: Komunikasi client ↔ server
- **DataStore**: Simpan data player

### 3. MULTIPLAYER-FIRST DESIGN
**SEMUA keputusan harus mempertimbangkan multiplayer!**

- **Player data**: Per-player (inventory, quest, gold)
- **Shared state**: Monster, NPC, World (server-managed)
- **Concurrent access**: Handle banyak player sekaligus
- **Latency**: Design untuk network delay
- **Anti-cheat**: Jangan trust client

### 4. INFORMATIF ✨
**Player harus SELALU tahu apa yang harus dilakukan!**

- **Quest Preview**: Tampilkan detail quest SEBELUM accept
  - Nama quest, objektif, reward
  - Player bisa accept atau decline
- **Quest Tracker**: Tunjukkan progress + langkah selanjutnya
  - "✓ Kembali ke Elder untuk ambil reward!"
- **Notification**: Beritahu semua peristiwa penting
  - Quest accepted, quest complete, level up
- **Status Indicators**: ✓ (selesai), > (belum), → (arah)

**Prinsip**: Kalau player tanya "terus gimana?", UI kurang informatif!

---

## Overview
**Arcadia Online** adalah MMORPG anime-style yang dibangun di Roblox Studio. Game ini terinspirasi dari MMORPG klasik dengan sentuhan modern dan grafis stylized.

**Genre**: MMORPG (Massively Multiplayer Online Role-Playing Game)
**Platform**: Roblox (PC, Mobile, Xbox, VR)
**Target Audience**: 10+ tahun
**Monetization**: Game Pass, Dev Products, Cosmetics

---

## Game Design

### Core Features
- **Character Creation**: Pilih job class dengan stats unik
- **Open World**: Eksplorasi desa, hutan, dungeon
- **Combat System**: Real-time action combat
- **Quest System**: Main story + side quests
- **Multiplayer**: Party, trading, guild
- **Job System**: 7 job classes dengan skill unik

### Job Classes
| Job | Role | Specialty |
|-----|------|-----------|
| **Warrior** | DPS/Off-Tank | Melee damage, lifesteal |
| **Knight** | Tank | Defense, HP, invulnerability |
| **Mage** | DPS (Magic) | AoE spells, MP management |
| **Archer** | DPS (Ranged) | Critical hits, evasion |
| **Cleric** | Healer/Support | Healing, party buffs |
| **Jester** | DPS/Utility | Speed, crit, stealth |
| **Craftsman** | DPS/Crafter | Crit, crafting, gathering |

### World Map
```
Beginner Village (Lv 1-10)
  ↓
Green Forest (Lv 10-25)
  ↓
Sage Tower (Lv 25-40)
  ↓
Rebel HQ (Lv 40-55)
  ↓
Capital City (Lv 55-75)
  ↓
Dark Caverns (Lv 75-90)
  ↓
Sky Islands (Lv 90-100)
```

---

## Technical Stack

### Roblox Features Used
- **Luau Scripting**: Performant, type-safe
- **DataStoreService**: Save/Load player data
- **ReplicatedStorage**: Shared assets
- **ServerScriptService**: Server-side logic
- **MarketplaceService**: Monetization
- **MessagingService**: Cross-server communication

### Project Structure
```
src/
├── Data/                          # SEMUA game data (GameData.lua entry point)
│   ├── GameData.lua              # Single source of truth
│   ├── Monsters.lua              # Monster definitions
│   ├── Items.lua                 # Items, equipment, potions
│   ├── Quests.lua                # Quest definitions
│   ├── NPCs.lua                  # NPC definitions
│   ├── Shops.lua                 # Shop inventories
│   ├── Dialogues.lua             # Dialogue trees
│   ├── Jobs.lua                  # Job class definitions
│   ├── Skills.lua                # Skill definitions (per job)
│   └── SpawnPositions.lua        # Monster/NPC spawn locations + checkpoints
│
├── Server/                        # Server-side logic
│   ├── MainServer.lua            # Entry point (loads modules)
│   └── ServerModules/
│       ├── PlayerData.lua        # Player data management
│       ├── CombatSystem.lua      # Combat logic, attack cooldown, skills
│       ├── QuestSystem.lua       # Quest accept/complete/tracking
│       ├── ShopSystem.lua        # Buy/sell
│       ├── DialogueSystem.lua    # NPC dialogue engine
│       └── WorldBuilder.lua      # Map generation, checkpoints, monster AI
│
└── Client/                        # Client-side logic
    ├── MainClient.lua            # Entry point (loads modules)
    └── ClientModules/
        ├── HUD.lua               # Stats display (HP, MP, ATK, etc.)
        ├── QuestTracker.lua      # Active quest tracker (INFORMATIF!)
        ├── ShopUI.lua            # Shop interface
        ├── DialogueUI.lua        # Dialogue window
        ├── Notification.lua      # Notifications (quest, level up)
        ├── DamagePopup.lua       # Floating damage numbers
        ├── AutoPanel.lua         # Auto combat, skill, potion + settings
        ├── EquipmentUI.lua       # Equipment panel (11 slots)
        ├── InventoryUI.lua       # Inventory panel (3 tabs)
        └── SkillBar.lua          # Skill bar (keys 1-4, cooldown, MP cost)
```

---

## Getting Started

### Requirements
- Roblox Studio (latest version)
- Basic knowledge of Luau scripting

### Setup
1. Open Roblox Studio
2. Create new Baseplate
3. Import scripts from `src/` folder
4. Set up game structure (see `docs/SETUP.md`)

### Development
- **Server Scripts**: `ServerScriptService`
- **Client Scripts**: `StarterPlayerScripts`
- **UI Scripts**: `StarterGui`
- **Shared Modules**: `ReplicatedStorage`

---

## Documentation

- [Game Design Document](docs/GDD.md)
- [Setup Guide](docs/SETUP.md)
- [Scripting Guide](docs/SCRIPTING.md)
- [Monetization Guide](docs/MONETIZATION.md)

---

## Contributing

1. Fork repository
2. Create feature branch
3. Submit pull request

---

## License

Proprietary - All rights reserved

---

## Contact

- **Developer**: arcadiastore
- **GitHub**: https://github.com/arcadiastore/arcadia-roblox
