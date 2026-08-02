# Database Skill (Skill DB)

## Ringkasan

Struktur data untuk semua skill di Arcadia Online.

## Tabel Utama

### skill_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik skill |
| name | string | Nama skill |
| description | string | Deskripsi skill |
| type | enum | ACTIVE, PASSIVE, ULTIMATE |
| job_id | string | ID job yang bisa menggunakan |
| tier | int | Tier skill (1-5) |
| level_req | int | Level minimum |
| prerequisite_skill | string | ID skill prasyarat |
| icon | string | Path icon |

### skill_cost
| Field | Type | Description |
|-------|------|-------------|
| skill_id | string | FK ke skill_base |
| mp_cost | float | Biaya MP |
| cooldown | float | Cooldown (detik) |
| cast_time | float | Waktu casting (detik) |
| channel_time | float | Waktu channeling (detik) |

### skill_effect
| Field | Type | Description |
|-------|------|-------------|
| skill_id | string | FK ke skill_base |
| effect_type | enum | DAMAGE, HEAL, BUFF, DEBUFF, CC |
| damage_type | enum | PHYSICAL, MAGICAL, TRUE |
| base_value | float | Nilai dasar efek |
| scaling_stat | string | Stat yang menskalakan (ATK, MATK) |
| scaling_ratio | float | Rasio scaling |
| duration | float | Durasi efek (detik) |
| aoe_radius | float | Radius AoE (0 = single target) |
| max_targets | int | Maks target (0 = unlimited) |

### skill_rune_slots
| Field | Type | Description |
|-------|------|-------------|
| skill_id | string | FK ke skill_base |
| slot_count | int | Jumlah slot rune (0-3) |

## Contoh Data

### Warrior Skills
```json
[
  {
    "id": "skill_slash",
    "name": "Slash",
    "type": "ACTIVE",
    "job_id": "warrior",
    "tier": 1,
    "level_req": 1,
    "cost": {"mp": 5, "cooldown": 3},
    "effect": {
      "type": "DAMAGE",
      "damage_type": "PHYSICAL",
      "base_value": 10,
      "scaling_stat": "ATK",
      "scaling_ratio": 1.5
    }
  },
  {
    "id": "skill_shield_bash",
    "name": "Shield Bash",
    "type": "ACTIVE",
    "job_id": "warrior",
    "tier": 2,
    "level_req": 10,
    "cost": {"mp": 15, "cooldown": 8},
    "effect": {
      "type": "CC",
      "cc_type": "STUN",
      "duration": 2
    }
  },
  {
    "id": "skill_war_cry",
    "name": "War Cry",
    "type": "ACTIVE",
    "job_id": "warrior",
    "tier": 3,
    "level_req": 20,
    "cost": {"mp": 30, "cooldown": 30},
    "effect": {
      "type": "BUFF",
      "buff_stat": "ATK",
      "buff_value": 20,
      "duration": 10,
      "aoe_radius": 0,
      "target": "PARTY"
    }
  },
  {
    "id": "skill_berserk",
    "name": "Berserk",
    "type": "ULTIMATE",
    "job_id": "warrior",
    "tier": 5,
    "level_req": 60,
    "cost": {"mp": 100, "cooldown": 120},
    "effect": {
      "type": "BUFF",
      "buff_stat": "ATK",
      "buff_value": 50,
      "debuff_stat": "DEF",
      "debuff_value": -30,
      "duration": 15
    }
  }
]
```

### Mage Skills
```json
[
  {
    "id": "skill_fire_bolt",
    "name": "Fire Bolt",
    "type": "ACTIVE",
    "job_id": "mage",
    "tier": 1,
    "level_req": 1,
    "cost": {"mp": 10, "cooldown": 5},
    "effect": {
      "type": "DAMAGE",
      "damage_type": "MAGICAL",
      "base_value": 15,
      "scaling_stat": "MATK",
      "scaling_ratio": 1.8,
      "element": "FIRE"
    }
  },
  {
    "id": "skill_meteor",
    "name": "Meteor",
    "type": "ACTIVE",
    "job_id": "mage",
    "tier": 4,
    "level_req": 40,
    "cost": {"mp": 80, "cooldown": 60},
    "effect": {
      "type": "DAMAGE",
      "damage_type": "MAGICAL",
      "base_value": 100,
      "scaling_stat": "MATK",
      "scaling_ratio": 3.0,
      "element": "FIRE",
      "aoe_radius": 5,
      "max_targets": 10
    }
  }
]
```

## Skill Point Cost

| Tier | SP to Learn | SP to Max |
|------|------------|----------|
| 1 | 1 | 5 |
| 2 | 2 | 8 |
| 3 | 3 | 12 |
| 4 | 5 | 15 |
| 5 (Ultimate) | 10 | 20 |
