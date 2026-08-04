# Arcadia Online - Roblox Game Design Document

## Game Overview

**Arcadia Online** adalah MMORPG yang dibangun di Roblox dengan gaya anime-style. Game ini menawarkan pengalaman bermain RPG klasik dengan sentuhan modern yang cocok untuk platform Roblox.

**Genre**: MMORPG
**Platform**: Roblox (PC, Mobile, Xbox, VR)
**Target Audience**: 10+ tahun
**Monetization**: Game Pass, Dev Products, Cosmetics

---

## Core Features

### 1. Character System
- **3 Job Classes** (Warrior, Mage, Archer) dengan stats dan skill unik
- **Level System** (Lv.1 - Lv.100)
- **Stat System** (STR, AGI, INT, VIT, DEX, LUK)
- **Equipment System** (11 slots)

### 2. Combat System
- **Real-time Action Combat**
- **Skill System** (4 skill slots)
- **Critical Hits** & **Dodge**
- **Party System** (max 4 players)

### 3. World System
- **Open World** dengan berbagai area
- **Fast Travel** (Warp Points)
- **Dynamic Events**
- **Day/Night Cycle** (optional)

### 4. Quest System
- **Main Story Quests**
- **Side Quests**
- **Daily Quests**
- **Quest Tracking**

### 5. Social System
- **Party System**
- **Guild System**
- **Trading**
- **Chat**

### 6. Economy System
- **Gold Currency**
- **Shop System**
- **Auction House** (future)
- **Crafting System** (future)

---

## World Map

### Beginner Village (Lv.1-10)
```
┌─────────────────────────────────────┐
│           [Training Ground]         │
│                  │                  │
│    [NPC] ──── [Village Center] ──── [NPC]
│                  │                  │
│           [Forest Entrance]         │
│                  │                  │
│            [Green Forest]           │
└─────────────────────────────────────┘
```

**NPCs:**
- Elder Tetua (Quest Giver)
- Blacksmith (Shop - Weapons)
- Merchant (Shop - Potions)
- Guard (Dialogue)
- Training Master (Tutorial)

**Monsters:**
- Slime (Lv.1-3)
- Wolf (Lv.5-8)
- Boar (Lv.7-10)
- Guardian Boss (Lv.10)

### Green Forest (Lv.10-25)
```
┌─────────────────────────────────────┐
│         [Forest Camp]               │
│              │                      │
│    [West] ── [Center] ── [East]     │
│              │                      │
│         [Deep Forest]               │
│              │                      │
│         [Boss Arena]                │
└─────────────────────────────────────┘
```

**Monsters:**
- Forest Slime (Lv.10-12)
- Wolf Alpha (Lv.15-18)
- Bear (Lv.20-23)
- Forest Guardian Boss (Lv.25)

### Sage Tower (Lv.25-40)
### Rebel HQ (Lv.40-55)
### Capital City (Lv.55-75)
### Dark Caverns (Lv.75-90)
### Sky Islands (Lv.90-100)

---

## Job Classes

### Warrior
- **Role**: DPS/Off-Tank
- **Stats**: High STR, Medium AGI
- **Skills**: Slash, Whirlwind, Berserk
- **Playstyle**: Aggressive melee combat

### Knight
- **Role**: Tank
- **Stats**: High VIT, High DEF
- **Skills**: Shield Bash, Provoke, Guardian
- **Playstyle**: Defensive, protect party

### Mage
- **Role**: DPS (Magic)
- **Stats**: High INT, High MP
- **Skills**: Fireball, Ice Storm, Heal
- **Playstyle**: Ranged magic damage

### Archer
- **Role**: DPS (Ranged)
- **Stats**: High DEX, High AGI
- **Skills**: Double Arrow, Rain of Arrows, Evasion
- **Playstyle**: Fast ranged attacks

### Cleric
- **Role**: Healer/Support
- **Stats**: High INT, High VIT
- **Skills**: Heal, Party Heal, Buffs
- **Playstyle**: Keep party alive

### Jester
- **Role**: DPS/Utility
- **Stats**: High AGI, High LUK
- **Skills**: Backstab, Stealth, Critical
- **Playstyle**: Stealthy, critical hits

### Craftsman
- **Role**: DPS/Crafter
- **Stats**: Balanced
- **Skills**: Craft, Gather, Special Attack
- **Playstyle**: Versatile, crafting

---

## Quest Design

### Main Quest: "Permintaan Tetua"

**Quest Chain:**
1. **Talk to Elder** → Learn about village
2. **Kill 5 Slimes** → Clear training ground
3. **Talk to Blacksmith** → Get first weapon
4. **Kill 3 Wolves** → Clear forest path
5. **Kill Guardian Boss** → Unlock Green Forest

**Rewards:**
- EXP: 1000 total
- Gold: 500 total
- Items: Iron Sword, Leather Armor

### Side Quests

**"Obat Tradisional"**
- Objective: Collect 5 Herbs
- Reward: 50 EXP, 30 Gold, HP Potion

**"Latihan Tempur"**
- Objective: Kill 10 Training Dummies
- Reward: 100 EXP, Skill Points

---

## Monster Design

### Slime (Lv.1-3)
- **HP**: 50
- **ATK**: 5
- **DEF**: 3
- **EXP**: 20
- **Drops**: Slime Gel, HP Potion (10%)

### Wolf (Lv.5-8)
- **HP**: 120
- **ATK**: 15
- **DEF**: 8
- **EXP**: 50
- **Drops**: Wolf Fang, HP Potion (15%)

### Boar (Lv.7-10)
- **HP**: 180
- **ATK**: 20
- **DEF**: 12
- **EXP**: 80
- **Drops**: Herbs

### Guardian Boss (Lv.10)
- **HP**: 500
- **ATK**: 35
- **DEF**: 20
- **EXP**: 200
- **Drops**: Iron Sword (50%), Iron Armor (30%)

---

## UI Design

### Main HUD
```
┌─────────────────────────────────────────┐
│ [HP Bar]                    [Level: 1]  │
│ [MP Bar]                    [Gold: 100] │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│                                         │
│ [Skill 1] [Skill 2] [Skill 3] [Skill 4]│
└─────────────────────────────────────────┘
```

### Quest Tracker
```
┌─────────────────┐
│ Active Quests:  │
│                 │
│ ○ Kill 5 Slime │
│   Progress: 3/5 │
│                 │
│ ○ Collect Herb  │
│   Progress: 2/5 │
└─────────────────┘
```

### Dialogue Box
```
┌─────────────────────────────────────────┐
│ [NPC Portrait]  NPC Name                │
│                                         │
│ "Dialogue text here..."                 │
│                                         │
│ [Option 1] [Option 2] [Option 3]        │
└─────────────────────────────────────────┘
```

---

## Monetization

### Game Passes
| Pass | Price | Benefit |
|------|-------|---------|
| **VIP** | 499 Robux | 2x EXP, 2x Gold, VIP area |
| **Auto-Loot** | 299 Robux | Auto collect drops |
| **Extra Inventory** | 199 Robux | +20 inventory slots |
| **Cosmetic Pack** | 399 Robux | Exclusive outfits |

### Dev Products
| Product | Price | Benefit |
|---------|-------|---------|
| **100 Gold** | 25 Robux | Instant gold |
| **EXP Boost** | 50 Robux | 2x EXP for 1 hour |
| **Revive** | 10 Robux | Instant revive |

---

## Technical Specifications

### Performance Targets
- **FPS**: 60 fps (PC), 30 fps (Mobile)
- **Players**: Max 50 per server
- **Load Time**: < 10 seconds

### Roblox Features Used
- **DataStoreService**: Save/Load
- **ReplicatedStorage**: Shared modules
- **ServerScriptService**: Server logic
- **MarketplaceService**: Monetization
- **MessagingService**: Cross-server

---

## Development Roadmap

### Phase 1: Prototype (Current)
- [x] Basic movement
- [x] Basic combat
- [x] NPC interaction
- [ ] Quest system
- [ ] Save/Load

### Phase 2: Vertical Slice
- [ ] Complete Beginner Village
- [ ] All NPCs functional
- [ ] Quest chain working
- [ ] UI polish

### Phase 3: Alpha
- [ ] Green Forest area
- [ ] More monsters
- [ ] Party system
- [ ] Shop system

### Phase 4: Beta
- [ ] All areas complete
- [ ] All quests
- [ ] Guild system
- [ ] Monetization

### Phase 5: Release
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Marketing
- [ ] Launch

---

## Art Style

### Visual Style
- **Low-poly** dengan warna cerah
- **Anime-inspired** character design
- **Stylized** environment
- **Clean** UI design

### Color Palette
- **Primary**: Biru, Hijau, Merah
- **Secondary**: Kuning, Ungu, Oranye
- **Neutral**: Putih, Abu-abu, Hitam

---

## Sound Design

### Music
- **Village Theme**: Tenang, damai
- **Battle Theme**: Energik, menegangkan
- **Boss Theme**: Epik, dramatis

### SFX
- **Combat**: Slash, hit, magic
- **UI**: Click, open, close
- **Environment**: Wind, birds, water

---

## Target Audience

### Primary
- **Age**: 10-18 tahun
- **Interest**: RPG, Anime, Multiplayer
- **Platform**: Roblox players

### Secondary
- **Age**: 18-25 tahun
- **Interest**: Casual RPG
- **Platform**: Roblox players

---

## Competitor Analysis

### Similar Games
| Game | Strength | Weakness |
|------|----------|----------|
| **Rogue Lineage** | Deep mechanics | Complex |
| **Deepwoken** | Good combat | Difficult |
| **Arcane Odyssey** | Large world | Grindy |

### Our Advantages
- **Anime style** (unique in Roblox)
- **Job system** (variety)
- **Easy to learn** (accessible)
- **Party system** (social)

---

## Conclusion

Arcadia Online menawarkan pengalaman MMORPG yang unik di Roblox dengan gaya anime, sistem job yang beragam, dan gameplay yang mudah dipelajari. Dengan fokus pada kualitas dan pengalaman pemain, game ini berpotensi menjadi salah satu MMORPG terbaik di platform Roblox.

---

**Document Version**: 1.0
**Last Updated**: 2026-08-02
**Author**: arcadiastore
