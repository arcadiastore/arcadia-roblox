# Database Quest (Quest DB)

## Ringkasan

Struktur data untuk semua quest di Arcadia Online.

## Tabel Utama

### quest_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik quest |
| name | string | Nama quest |
| type | enum | MAIN, SIDE, DAILY, REPEATABLE, HIDDEN |
| giver_id | string | ID NPC pemberi quest |
| level_req | int | Level minimum |
| prerequisite_quest | string | ID quest prasyarat |
| description | string | Deskripsi quest |
| chapter | int | Chapter cerita |

### quest_objectives
| Field | Type | Description |
|-------|------|-------------|
| quest_id | string | FK ke quest_base |
| objective_id | string | ID objective |
| type | enum | KILL, COLLECT, TALK, GO_TO, ESCORT |
| target_id | string | ID target (monster/item/NPC/lokasi) |
| quantity | int | Jumlah yang dibutuhkan |
| description | string | Deskripsi objective |

### quest_rewards
| Field | Type | Description |
|-------|------|-------------|
| quest_id | string | FK ke quest_base |
| reward_type | enum | EXP, GOLD, ITEM, REPUTATION, COMPANION |
| reward_id | string | ID reward (item/NPC) |
| quantity | int | Jumlah reward |

### quest_branches
| Field | Type | Description |
|-------|------|-------------|
| quest_id | string | FK ke quest_base |
| branch_id | string | ID branch |
| choice_text | string | Teks pilihan |
| consequence | string | Konsekuensi (JSON) |
| next_quest | string | ID quest selanjutnya |

## Contoh Data

### Quest Utama: "Permintaan Tetua"
```json
{
  "id": "Q001",
  "name": "Permintaan Tetua",
  "type": "MAIN",
  "giver_id": "NPC001",
  "level_req": 1,
  "chapter": 1,
  "objectives": [
    {"type": "TALK", "target_id": "NPC002", "quantity": 1},
    {"type": "COLLECT", "target_id": "herb_001", "quantity": 3},
    {"type": "RETURN", "target_id": "NPC001", "quantity": 1}
  ],
  "rewards": [
    {"type": "EXP", "quantity": 100},
    {"type": "GOLD", "quantity": 50},
    {"type": "ITEM", "id": "potion_hp_small", "quantity": 5}
  ]
}
```

### Quest Sampingan: "Dilema Pedagang"
```json
{
  "id": "Q010",
  "name": "Dilema Pedagang",
  "type": "SIDE",
  "giver_id": "NPC020",
  "level_req": 10,
  "branches": [
    {
      "choice": "Bantu pedagang",
      "consequence": {"merchant_rep": 10},
      "next_quest": "Q010A"
    },
    {
      "choice": "Bantu bandit",
      "consequence": {"bandit_rep": 10, "merchant_rep": -20},
      "next_quest": "Q010B"
    }
  ]
}
```

## Quest Chain

```
Q001: Permintaan Tetua
    ↓
Q002: Temukan Herbal
    ↓
Q003: Obati Penduduk
    ↓
Q004: Serang Markas Bandit
    ↓
Q005: Rahasia Bandit
```

## Quest State

| State | Description |
|-------|-------------|
| AVAILABLE | Quest tersedia tapi belum diterima |
| ACTIVE | Quest sedang aktif |
| COMPLETED | Quest selesai |
| FAILED | Quest gagal |
| TURNED_IN | Quest sudah diambil reward |

## Quest Tracker Data

```json
{
  "quest_id": "Q001",
  "state": "ACTIVE",
  "objectives": [
    {"id": "obj1", "type": "KILL", "current": 3, "required": 5},
    {"id": "obj2", "type": "COLLECT", "current": 1, "required": 3}
  ],
  "started_at": "2026-01-15T10:30:00"
}
```
