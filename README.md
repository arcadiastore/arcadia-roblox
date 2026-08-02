# Arcadia Online - Roblox MMORPG

## ⚠️ GOLDEN RULE: NO HARDCODING

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
├── Core/           # Core systems (GameManager, DataManager)
├── Player/         # Player controller, stats, level
├── Combat/         # Combat system, skills, damage
├── Quest/          # Quest system, objectives
├── Inventory/      # Items, equipment
├── Shop/           # Buy/sell system
├── UI/             # User interface
├── World/          # Map, environment, spawners
├── Monster/        # Monster AI, behavior
├── NPC/            # NPC system, dialogue
├── Dialogue/       # Dialogue system
├── Save/           # Save/Load system
└── Multiplayer/    # Party, guild, trading
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
