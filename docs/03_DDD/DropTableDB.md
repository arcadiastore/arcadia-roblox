# Database Drop Table (Drop Table DB)

## Ringkasan

Struktur data untuk sistem drop item dari monster.

## Tabel Utama

### drop_table
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik drop table |
| monster_id | string | FK ke monster_base |
| item_id | string | FK ke item_base |
| drop_rate | float | Peluang drop (0-1) |
| min_quantity | int | Jumlah minimum |
| max_quantity | int | Jumlah maksimum |
| condition | string | Kondisi khusus (JSON) |

### drop_table_group
| Field | Type | Description |
|-------|------|-------------|
| group_id | string | ID grup |
| monster_id | string | FK ke monster_base |
| group_type | enum | ALWAYS, COMMON, RARE, BOSS |
| guaranteed | bool | Drop pasti |

## Drop Rate Tiers

| Tier | Drop Rate | Contoh |
|------|-----------|--------|
| Guaranteed | 100% | Gold, material dasar |
| Common | 30-70% | Potion, material |
| Uncommon | 10-25% | Equipment, material langka |
| Rare | 1-9% | Equipment rare |
| Epic | 0.1-1% | Equipment epic |
| Legendary | 0.01-0.1% | Equipment legendary |

## Contoh Data

### Slime Drop Table
```json
{
  "monster_id": "M001",
  "drops": [
    {"item": "gold", "rate": 1.0, "min": 5, "max": 15},
    {"item": "slime_jelly", "rate": 0.5, "min": 1, "max": 2},
    {"item": "potion_hp_small", "rate": 0.15, "min": 1, "max": 1},
    {"item": "material_green_gem", "rate": 0.01, "min": 1, "max": 1}
  ]
}
```

### Forest Wolf Drop Table
```json
{
  "monster_id": "M010",
  "drops": [
    {"item": "gold", "rate": 1.0, "min": 20, "max": 50},
    {"item": "wolf_pelt", "rate": 0.4, "min": 1, "max": 2},
    {"item": "wolf_fang", "rate": 0.25, "min": 1, "max": 1},
    {"item": "potion_hp_medium", "rate": 0.1, "min": 1, "max": 1},
    {"item": "weapon_wolf_dagger", "rate": 0.02, "min": 1, "max": 1}
  ]
}
```

### Guardian of the Forest (Boss) Drop Table
```json
{
  "monster_id": "MB001",
  "drops": [
    {"item": "gold", "rate": 1.0, "min": 500, "max": 1000},
    {"item": "guardian_essence", "rate": 1.0, "min": 1, "max": 3},
    {"item": "material_ancient_wood", "rate": 0.8, "min": 2, "max": 5},
    {"item": "weapon_forest_sword", "rate": 0.3, "min": 1, "max": 1},
    {"item": "armor_forest_plate", "rate": 0.3, "min": 1, "max": 1},
    {"item": "helm_forest_crown", "rate": 0.2, "min": 1, "max": 1},
    {"item": "rare_forest_ring", "rate": 0.1, "min": 1, "max": 1},
    {"item": "legendary_guardian_axe", "rate": 0.02, "min": 1, "max": 1}
  ]
}
```

## Drop Rate Modifiers

| Modifier | Effect |
|----------|--------|
| LUK stat | +0.1% per LUK point |
| Lucky buff | +20% drop rate |
| Party bonus | +10% per party member |
| Daily bonus | +50% first kill per day |
| Event bonus | +100% during event |

## Formula

```
Final Drop Rate = Base Rate * (1 + LUK * 0.001) * (1 + Buff) * (1 + Party)
```

## World Drop Table

Drop yang bisa dari monster manapun:

```json
{
  "world_drops": [
    {"item": "rare_gem", "rate": 0.001, "min_level": 10},
    {"item": "epic_scroll", "rate": 0.0005, "min_level": 30},
    {"item": "legendary_key", "rate": 0.0001, "min_level": 50}
  ]
}
```
