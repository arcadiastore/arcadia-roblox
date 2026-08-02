# Database Monster (Monster DB)

## Ringkasan

Struktur data untuk semua monster di Arcadia Online.

## Tabel Utama

### monster_base
| Field | Type | Default | Description |
|-------|------|---------|-------------|
| id | string | - | ID unik monster |
| name | string | - | Nama monster |
| type | enum | NORMAL | NORMAL, ELITE, BOSS, WORLD_BOSS |
| element | enum | NONE | NONE, FIRE, WATER, WIND, EARTH, LIGHT, DARK |
| level_min | int | 1 | Level minimum |
| level_max | int | 1 | Level maksimum |
| hp_base | float | - | HP dasar |
| atk_base | float | - | ATK dasar |
| def_base | float | - | DEF dasar |
| mdef_base | float | - | MDEF dasar |
| spd_base | float | - | SPD dasar |
| exp_reward | int | - | EXP yang diberikan |
| gold_min | int | - | Gold minimum |
| gold_max | int | - | Gold maksimum |
| behavior | enum | PASSIVE | PASSIVE, AGGRESSIVE, TERRITORIAL, FLEEING, PACK |
| detection_range | float | 10 | Jarak deteksi |
| chase_range | float | 20 | Jarak kejar |
| respawn_time | float | 60 | Waktu respawn (detik) |

### monster_skills
| Field | Type | Description |
|-------|------|-------------|
| monster_id | string | FK ke monster_base |
| skill_id | string | ID skill |
| use_chance | float | Peluang menggunakan skill (0-1) |
| hp_threshold | float | HP threshold untuk menggunakan skill |

### monster_drops
| Field | Type | Description |
|-------|------|-------------|
| monster_id | string | FK ke monster_base |
| item_id | string | ID item |
| drop_rate | float | Peluang drop (0-1) |
| min_quantity | int | Jumlah minimum |
| max_quantity | int | Jumlah maksimum |

## Contoh Data

### Slime (Normal)
```json
{
  "id": "M001",
  "name": "Slime",
  "type": "NORMAL",
  "element": "NONE",
  "level_min": 1,
  "level_max": 5,
  "hp_base": 50,
  "atk_base": 8,
  "def_base": 3,
  "exp_reward": 10,
  "gold_min": 5,
  "gold_max": 15,
  "behavior": "PASSIVE"
}
```

### Forest Wolf (Normal)
```json
{
  "id": "M010",
  "name": "Forest Wolf",
  "type": "NORMAL",
  "element": "WIND",
  "level_min": 10,
  "level_max": 15,
  "hp_base": 200,
  "atk_base": 25,
  "def_base": 15,
  "exp_reward": 50,
  "behavior": "AGGRESSIVE"
}
```

### Guardian of the Forest (Boss)
```json
{
  "id": "MB001",
  "name": "Guardian of the Forest",
  "type": "BOSS",
  "element": "EARTH",
  "level_min": 15,
  "level_max": 15,
  "hp_base": 5000,
  "atk_base": 80,
  "def_base": 50,
  "exp_reward": 1000,
  "behavior": "AGGRESSIVE"
}
```

## Monster Scaling Formula

```
HP = hp_base * (1 + (level - level_min) * 0.1)
ATK = atk_base * (1 + (level - level_min) * 0.08)
DEF = def_base * (1 + (level - level_min) * 0.05)
EXP = exp_reward * (1 + (level - level_min) * 0.1)
```
