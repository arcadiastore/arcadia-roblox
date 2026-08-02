# Arcadia Online - Data Architecture

## Struktur Folder

```
📁 Data/
   ├── 📄 GameData.lua        ← MAIN ENTRY POINT
   ├── 📄 Monsters.lua         ← Monster definitions
   ├── 📄 Items.lua            ← Item definitions
   ├── 📄 Quests.lua           ← Quest definitions
   ├── 📄 NPCs.lua             ← NPC definitions
   ├── 📄 Shops.lua            ← Shop definitions
   ├── 📄 Jobs.lua             ← Job definitions
   ├── 📄 Skills.lua           ← Skill definitions
   ├── 📄 Dialogues.lua        ← Dialogue definitions
   ├── 📄 SpawnPositions.lua   ← Spawn positions
   └── 📄 Formulas.lua         ← Game formulas
```

## Cara Pakai

### Di Roblox Studio:

1. **Tempatkan di ReplicatedStorage:**
   ```
   📁 ReplicatedStorage
      └── 📦 GameData (ModuleScript)
          ├── 📦 Monsters (ModuleScript)
          ├── 📦 Items (ModuleScript)
          ├── ... (module lainnya)
   ```

2. **Akses dari Script:**
   ```lua
   local GameData = require(ReplicatedStorage:WaitForChild("GameData"))
   
   -- Monster data
   local slime = GameData:GetMonster("Slime")
   print(slime.hp)  -- 50
   
   -- Job data
   local warrior = GameData:GetJob("Warrior")
   print(warrior.baseStats.hp)  -- 120
   
   -- Damage calculation
   local damage = GameData.Formulas.physicalDamage(15, 1.5, 3)
   print(damage)  -- 21
   ```

## Aturan Penting

### 1. NO HARDCODING
- **SEMUA data** harus dari GameData module
- Jangan hardcode di script lain
- Edit module terpisah untuk tambah/kurang content

### 2. SINGLE SOURCE OF TRUTH
- Satu data = satu tempat
- Semua system baca dari sini
- Konsistensi terjamin

### 3. MODULAR
- Setiap tipe data punya file sendiri
- Mudah di-maintain
- File tidak terlalu panjang

## GDD References

| Module | GDD Reference |
|--------|---------------|
| Monsters | 11_Monsters.md |
| Items | 09_Items.md |
| Quests | 14_Quest.md |
| NPCs | 13_NPC.md |
| Jobs | 06_Jobs.md |
| Skills | 07_Skills.md |
| Dialogues | 15_Dialogue.md |
| Formulas | 08_Stats.md |

## Helper Functions

```lua
-- Monster
GameData:GetMonster(id)
GameData:GetMonstersByArea(area)

-- Item
GameData:GetItem(id)

-- Quest
GameData:GetQuest(id)
GameData:GetAvailableQuests(level, completedQuests)

-- NPC
GameData:GetNPC(id)
GameData:GetDialogue(npcId)

-- Shop
GameData:GetShop(id)
GameData:GetShopItems(shopId)

-- Job
GameData:GetJob(id)
GameData:GetStarterJobs()
GameData:GetJobAdvancements(parentJobId)

-- Skill
GameData:GetSkill(id)
GameData:GetJobSkills(jobId)
GameData:GetPlayerSkills(jobId, level)

-- Calculation
GameData:CalculateExpForLevel(level)
GameData:CalculateStats(jobId, level)

-- Formulas
GameData.Formulas.physicalDamage(atk, multiplier, targetDef)
GameData.Formulas.magicDamage(matk, multiplier, targetMdef)
GameData.Formulas.critRate(luk, equipmentBonus)
GameData.Formulas.elementalMultiplier(atkElement, defElement)
```

## Menambah Data Baru

### Tambah Monster Baru:
1. Buka `Monsters.lua`
2. Tambah entry baru:
   ```lua
   Monsters["NewMonster"] = {
       id = "NewMonster",
       name = "New Monster",
       level = 15,
       hp = 300,
       atk = 25,
       def = 15,
       exp = 150,
       gold = 75,
       -- ... data lainnya
   }
   ```
3. Save file
4. Data otomatis tersedia di semua system!

### Tambah Item Baru:
1. Buka `Items.lua`
2. Tambah entry baru
3. Tambah ke shop di `Shops.lua` jika perlu

### Tambah Quest Baru:
1. Buka `Quests.lua`
2. Tambah entry baru
3. Tambah NPC giver di `NPCs.lua`
4. Tambah dialogue di `Dialogues.lua`

---

**INGAT: JANGAN HARDCODE! Semua data dari GameData!**
