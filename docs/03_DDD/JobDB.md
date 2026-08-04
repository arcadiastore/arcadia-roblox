# Database Job (Job DB)

> **Status**: Sesuai implementasi (3 job)

## Ringkasan

Struktur data untuk 3 job di Arcadia Online.

## Tabel Utama

### job_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik job |
| name | string | Nama job |
| description | string | Deskripsi job |
| role | string | Peran (Tank, DPS, Support) |
| weapon_types | string | Tipe senjata |
| armor_type | string | Tipe armor |

### job_stats
| Field | Type | Description |
|-------|------|-------------|
| job_id | string | FK ke job_base |
| stat_type | string | Jenis stat (hp, mp, atk, def, matk, mdef, spd, luk) |
| base_modifier | float | Modifier ke base stats player |
| growth_per_level | float | Pertumbuhan per level |

---

## Semua Job (3)

| ID | Nama | Role | Weapon | Armor |
|----|------|------|--------|-------|
| warrior | Warrior | Tank/Melee DPS | Sword, Axe, Hammer | Heavy, Medium |
| mage | Mage | Ranged Magic DPS | Staff, Wand, Orb | Cloth |
| archer | Archer | Ranged Physical DPS | Bow, Crossbow, Dagger | Light, Medium |

---

## Job Stat Modifiers

> Base player: HP=100, MP=50, ATK=10, DEF=5, MATK=5, MDEF=5, SPD=10, LUK=5

### Base Modifier (Level 1)
| Stat | Warrior | Mage | Archer |
|------|---------|------|--------|
| HP | +50 | -20 | +10 |
| MP | 0 | +50 | +10 |
| ATK | +5 | 0 | +3 |
| DEF | +8 | -3 | 0 |
| MATK | 0 | +10 | 0 |
| MDEF | +2 | +5 | +2 |
| SPD | -2 | +3 | +8 |
| LUK | 0 | +2 | +5 |

### Growth per Level
| Stat | Warrior | Mage | Archer |
|------|---------|------|--------|
| HP | +15 | +5 | +8 |
| MP | +2 | +10 | +5 |
| ATK | +3 | 0 | +3 |
| DEF | +3 | +1 | +1 |
| MATK | 0 | +4 | 0 |
| MDEF | +1 | +2 | +1 |
| SPD | 0 | +1 | +2 |
| LUK | +1 | +1 | +2 |

---

## Contoh Data (Lua)

```lua
Jobs["Warrior"] = {
    id = "Warrior",
    name = "Warrior",
    description = "Petarung jarak dekat dengan HP dan DEF tinggi.",
    role = "Tank / Melee DPS",
    stats = {
        hp = 50, mp = 0, atk = 5, def = 8,
        matk = 0, mdef = 2, spd = -2, luk = 0,
    },
    growth = {
        hp = 15, mp = 2, atk = 3, def = 3,
        matk = 0, mdef = 1, spd = 0, luk = 1,
    },
    weapons = {"Sword", "Axe", "Hammer"},
    armor = {"Heavy", "Medium"},
    color = Color3.fromRGB(220, 50, 50),
    icon = "[W]",
}
```

---

## Job Change

| Field | Value |
|-------|-------|
| Lokasi | Job Master NPC |
| Biaya | 1000 gold |
| Level | Tetap |
| Skill Points | Di-reset |
| Equipment | Tetap |

---

## Relationship

```
job_base (1) ──→ (N) job_stats
job_base (1) ──→ (N) skill_base
job_base (1) ──→ (N) player_data
```
