# Database Dunia (World DB)

## Ringkasan

Struktur data untuk dunia Arcadia.

## Tabel Utama

### world_areas
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik area |
| name | string | Nama area |
| type | enum | FIELD, CITY, DUNGEON, BOSS_ROOM, SPECIAL |
| level_range | string | Range level (e.g. "10-25") |
| parent_area | string | ID area parent |
| scene_name | string | Nama scene Unity |
| unlock_condition | string | Syarat unlock (JSON) |
| music | string | BGM area |

### world_waypoints
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik waypoint |
| area_id | string | FK ke world_areas |
| name | string | Nama waypoint |
| position | vector3 | Posisi |
| teleport_cost | int | Biaya teleport |

### world_spawners
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik spawner |
| area_id | string | FK ke world_areas |
| monster_id | string | FK ke monster_base |
| spawn_position | vector3 | Posisi spawn |
| spawn_radius | float | Radius spawn |
| max_count | int | Jumlah maks |
| respawn_time | float | Waktu respawn (detik) |

### world_npcs
| Field | Type | Description |
|-------|------|-------------|
| npc_id | string | FK ke npc_base |
| area_id | string | FK ke world_areas |
| spawn_position | vector3 | Posisi spawn |
| rotation | float | Rotasi (derajat) |

## Contoh Data

### Beginner Village
```json
{
  "id": "area_beginner_village",
  "name": "Desa Pemula",
  "type": "CITY",
  "level_range": "1-10",
  "scene": "scene_beginner_village",
  "unlock": null,
  "music": "bgm_village_peaceful",
  "waypoints": [
    {"id": "wp_village_center", "name": "Pusat Desa", "cost": 0},
    {"id": "wp_village_gate", "name": "Gerbang Desa", "cost": 10}
  ],
  "npcs": [
    {"id": "NPC001", "pos": [0, 0, 5]},
    {"id": "NPC002", "pos": [10, 0, -3]},
    {"id": "NPC020", "pos": [-5, 0, 8]}
  ],
  "spawners": [
    {"monster": "M001", "pos": [20, 0, 20], "radius": 10, "max": 5, "respawn": 30}
  ]
}
```

### Green Forest
```json
{
  "id": "area_green_forest",
  "name": "Hutan Hijau",
  "type": "FIELD",
  "level_range": "10-25",
  "scene": "scene_green_forest",
  "unlock": {"quest": "Q001"},
  "music": "bgm_forest_mystery",
  "waypoints": [
    {"id": "wp_forest_entrance", "name": "Pintu Masuk Hutan", "cost": 20},
    {"id": "wp_forest_deep", "name": "Hutan Dalam", "cost": 50}
  ],
  "spawners": [
    {"monster": "M010", "pos": [30, 0, 30], "radius": 15, "max": 8, "respawn": 45},
    {"monster": "M011", "pos": [50, 0, 20], "radius": 12, "max": 6, "respawn": 60}
  ]
}
```

## Area Connections

```
Beginner Village
    ├──→ Green Forest (Quest: Q001)
    │        ├──→ Forest Dungeon (Level: 15)
    │        └──→ Sage Tower (Quest: Q005)
    ├──→ Eastern Plains (Level: 5)
    │        └──→ Rebel HQ (Quest: Q010)
    └──→ Capital City (Quest: Q015)
             ├──→ Dark Caverns (Level: 70)
             └──→ Sky Islands (Level: 85)
```

## Weather Data

### weather_schedule
| Field | Type | Description |
|-------|------|-------------|
| area_id | string | FK ke world_areas |
| weather | enum | CLEAR, RAIN, SNOW, STORM, FOG |
| probability | float | Peluang cuaca (0-1) |
| duration_min | int | Durasi minimum (menit) |
| duration_max | int | Durasi maksimum (menit) |

## Day/Night Cycle

| Time | Hours | Effect |
|------|-------|--------|
| Dawn | 04:00-06:00 | Monster passive |
| Day | 06:00-18:00 | Normal |
| Dusk | 18:00-20:00 | Monster aggressive |
| Night | 20:00-04:00 | Monster +20% ATK, rare spawns |
