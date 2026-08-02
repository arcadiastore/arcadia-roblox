# Database NPC (NPC DB)

## Ringkasan

Struktur data untuk semua NPC di Arcadia Online.

## Tabel Utama

### npc_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik NPC |
| name | string | Nama NPC |
| type | enum | MERCHANT, QUEST_GIVER, COMPANION, LORE, ENEMY |
| title | string | Gelar/jabatan |
| location | string | Lokasi default |
| job | string | Job NPC (untuk companion) |
| personality | string | Tipe personality |
| likes | string | Hal yang disukai |
| dislikes | string | Hal yang tidak disukai |

### npc_schedule
| Field | Type | Description |
|-------|------|-------------|
| npc_id | string | FK ke npc_base |
| hour | int | Jam (0-23) |
| location | string | Lokasi pada jam tersebut |
| activity | string | Aktivitas pada jam tersebut |

### npc_dialogues
| Field | Type | Description |
|-------|------|-------------|
| npc_id | string | FK ke npc_base |
| dialogue_id | string | ID dialog |
| condition | string | Kondisi untuk memicu dialog |
| priority | int | Prioritas dialog |

### npc_affinity
| Field | Type | Description |
|-------|------|-------------|
| npc_id | string | FK ke npc_base |
| player_id | string | FK ke player_base |
| affinity | int | Level afinitas (0-100) |
| last_interaction | datetime | Waktu interaksi terakhir |

## Contoh Data

### Tetua Desa (Quest Giver)
```json
{
  "id": "NPC001",
  "name": "Tetua Aldric",
  "type": "QUEST_GIVER",
  "title": "Kepala Desa",
  "location": "beginner_village",
  "personality": "Bijaksana, Peduli"
}
```

### Lyra (Companion - Mage)
```json
{
  "id": "NPC010",
  "name": "Lyra",
  "type": "COMPANION",
  "title": "Penyihir Muda",
  "location": "sage_tower",
  "job": "mage",
  "personality": "Cerdas, Pemalu",
  "likes": "Membaca, Eksperimen",
  "dislikes": "Kekerasan, Kebodohan"
}
```

### Blacksmith Tom (Merchant)
```json
{
  "id": "NPC020",
  "name": "Tom",
  "type": "MERCHANT",
  "title": "Pandai Besi",
  "location": "beginner_village",
  "personality": "Ramah, Jujur"
}
```

## Companion Data

### companion_stats
| Field | Type | Description |
|-------|------|-------------|
| companion_id | string | FK ke npc_base |
| level | int | Level companion |
| hp | float | HP saat ini |
| mp | float | MP saat ini |
| skills | string | JSON list skill |
| equipped_items | string | JSON list equipment |

### companion_dialogues
| Field | Type | Description |
|-------|------|-------------|
| companion_id | string | FK ke npc_base |
| affinity_level | int | Level afinitas yang diperlukan |
| dialogue | string | Teks dialog |

## Merchant Data

### merchant_inventory
| Field | Type | Description |
|-------|------|-------------|
| merchant_id | string | FK ke npc_base |
| item_id | string | ID item |
| stock | int | Jumlah stok (-1 = unlimited) |
| price_multiplier | float | Multiplier harga |
| restock_time | float | Waktu restock (jam) |
