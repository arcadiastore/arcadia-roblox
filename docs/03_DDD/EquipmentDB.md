# Database Equipment (Equipment DB)

## Ringkasan

Struktur data untuk semua equipment di Arcadia Online.

## Tabel Utama

### equipment_base
| Field | Type | Description |
|-------|------|-------------|
| item_id | string | FK ke item_base |
| slot | enum | WEAPON, SUB_WEAPON, HEAD, BODY, HANDS, FEET, ACCESSORY |
| job_req | string | Job yang bisa menggunakan (null = semua) |
| level_req | int | Level minimum |

### equipment_stats
| Field | Type | Description |
|-------|------|-------------|
| item_id | string | FK ke equipment_base |
| stat_type | string | Jenis stat (ATK, DEF, dll) |
| base_value | float | Nilai stat |
| bonus_min | float | Bonus minimum (random) |
| bonus_max | float | Bonus maksimum (random) |

### equipment_sets
| Field | Type | Description |
|-------|------|-------------|
| set_id | string | ID set |
| set_name | string | Nama set |
| item_id | string | ID item dalam set |
| bonus_count | int | Jumlah item untuk bonus |
| bonus_stat | string | Stat bonus |
| bonus_value | float | Nilai bonus |

## Contoh Data

### Iron Sword (Weapon)
```json
{
  "item_id": "weapon_iron_sword",
  "slot": "WEAPON",
  "job_req": ["warrior", "knight", "berserker"],
  "level_req": 1,
  "stats": [
    {"stat": "ATK", "base": 10, "bonus_min": 1, "bonus_max": 5}
  ]
}
```

### Apprentice Staff (Weapon)
```json
{
  "item_id": "weapon_apprentice_staff",
  "slot": "WEAPON",
  "job_req": ["mage", "wizard", "cleric"],
  "level_req": 1,
  "stats": [
    {"stat": "MATK", "base": 12, "bonus_min": 1, "bonus_max": 4},
    {"stat": "MP", "base": 20, "bonus_min": 0, "bonus_max": 10}
  ]
}
```

### Iron Armor (Body)
```json
{
  "item_id": "armor_iron",
  "slot": "BODY",
  "job_req": ["warrior", "knight"],
  "level_req": 5,
  "stats": [
    {"stat": "DEF", "base": 15, "bonus_min": 2, "bonus_max": 8},
    {"stat": "HP", "base": 50, "bonus_min": 5, "bonus_max": 20}
  ]
}
```

### Dragon Slayer Set
```json
{
  "set_id": "set_dragon_slayer",
  "set_name": "Dragon Slayer Set",
  "items": [
    "weapon_dragon_sword",
    "armor_dragon_plate",
    "helm_dragon",
    "boots_dragon"
  ],
  "bonuses": [
    {"count": 2, "stat": "ATK", "value": 10},
    {"count": 3, "stat": "CR", "value": 15},
    {"count": 4, "stat": "SKILL_DAMAGE", "value": 25}
  ]
}
```

## Enhancement Levels

| Level | ATK/DEF Bonus | Success Rate |
|-------|---------------|-------------|
| +1 | +5% | 100% |
| +2 | +10% | 100% |
| +3 | +15% | 100% |
| +4 | +20% | 100% |
| +5 | +25% | 100% |
| +6 | +30% | 80% |
| +7 | +35% | 80% |
| +8 | +40% | 80% |
| +9 | +50% | 60% |
| +10 | +60% | 60% |
| +11 | +70% | 40% |
| +12 | +80% | 40% |
| +13 | +90% | 40% |
| +14 | +100% | 20% |
| +15 | +120% | 20% |

## Socket Slots

| Rarity | Max Sockets |
|--------|------------|
| Common | 0 |
| Uncommon | 1 |
| Rare | 2 |
| Epic | 3 |
| Legendary | 3 |
