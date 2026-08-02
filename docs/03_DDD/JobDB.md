# Database Job (Job DB)

## Ringkasan

Struktur data untuk semua job di Arcadia Online.

## Tabel Utama

### job_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik job |
| name | string | Nama job |
| tier | int | Tier job (1-3) |
| parent_job | string | ID job parent (null untuk tier 1) |
| description | string | Deskripsi job |
| role | string | Peran (Tank, DPS, Support) |
| weapon_types | string | Tipe senjata yang bisa digunakan |
| armor_type | string | Tipe armor |

### job_stats
| Field | Type | Description |
|-------|------|-------------|
| job_id | string | FK ke job_base |
| stat_type | string | Jenis stat |
| base_value | float | Nilai dasar di Lv 1 |
| growth_per_level | float | Pertumbuhan per level |

### job_advancement
| Field | Type | Description |
|-------|------|-------------|
| job_id | string | FK ke job_base |
| level_req | int | Level yang diperlukan |
| quest_id | string | ID quest advancement |
| gold_cost | int | Biaya gold |

## Semua Job

### Tier 1 (Lv 1)
| ID | Nama | Role | Weapon |
|----|------|------|--------|
| warrior | Warrior | Tank/Melee DPS | Sword, Axe, Hammer |
| mage | Mage | Ranged Magic DPS | Staff, Wand, Orb |
| archer | Archer | Ranged Physical DPS | Bow, Crossbow, Dagger |

### Tier 2 (Lv 30)
| ID | Nama | Parent | Role |
|----|------|--------|------|
| knight | Knight | Warrior | Tank |
| berserker | Berserker | Warrior | Melee DPS |
| wizard | Wizard | Mage | AoE DPS |
| cleric | Cleric | Mage | Healer |
| ranger | Ranger | Archer | Ranged DPS |
| assassin | Assassin | Archer | Burst DPS |

### Tier 3 (Lv 60)
| ID | Nama | Parent | Role |
|----|------|--------|------|
| paladin | Paladin | Knight | Tank/Support |
| dark_knight | Dark Knight | Knight | Tank/DPS |
| warlord | Warlord | Berserker | AoE DPS |
| reaver | Reaver | Berserker | Lifesteal DPS |
| archmage | Archmage | Wizard | Ultimate DPS |
| sorcerer | Sorcerer | Wizard | Debuff DPS |
| bishop | Bishop | Cleric | Pure Healer |
| inquisitor | Inquisitor | Cleric | DPS/Healer |
| sniper | Sniper | Ranger | Long Range DPS |
| beast_master | Beast Master | Ranger | Pet DPS |
| shadow | Shadow | Assassin | Stealth DPS |
| trickster | Trickster | Assassin | Evasion DPS |

## Job Stat Growth

### Warrior → Knight → Paladin
| Stat | Warrior/Lv | Knight/Lv | Paladin/Lv |
|------|-----------|----------|-----------|
| HP | 12 | 18 | 22 |
| MP | 3 | 5 | 8 |
| ATK | 1.5 | 2 | 2.5 |
| DEF | 1.2 | 2 | 2.5 |
| MATK | 0.5 | 0.8 | 1.5 |
| SPD | 0.8 | 0.7 | 0.6 |

### Mage → Wizard → Archmage
| Stat | Mage/Lv | Wizard/Lv | Archmage/Lv |
|------|---------|----------|------------|
| HP | 8 | 10 | 12 |
| MP | 10 | 15 | 20 |
| ATK | 0.8 | 1 | 1.2 |
| DEF | 0.5 | 0.6 | 0.7 |
| MATK | 1.5 | 2.5 | 3.5 |
| SPD | 0.7 | 0.8 | 0.9 |

## Job Advancement Quest

| Job | Quest | Objective |
|-----|-------|-----------|
| Knight | "Trial of the Shield" | Defeat Guardian in dungeon |
| Berserker | "Blood Oath" | Survive arena 10 rounds |
| Wizard | "Arcane Mastery" | Solve tower puzzles |
| Cleric | "Divine Light" | Heal 100 NPCs |
| Ranger | "Eagle Eye" | Hit targets from 50m |
| Assassin | "Shadow Strike" | Defeat boss undetected |
