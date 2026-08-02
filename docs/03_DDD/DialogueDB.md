# Database Dialog (Dialogue DB)

## Ringkasan

Struktur data untuk semua dialog NPC di Arcadia Online.

## Tabel Utama

### dialogue_tree
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik dialog tree |
| npc_id | string | ID NPC pemilik dialog |
| trigger | enum | INTERACT, PROXIMITY, QUEST, EVENT |
| condition | string | Kondisi untuk memicu (JSON) |
| priority | int | Prioritas (tinggi = diprioritaskan) |

### dialogue_node
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik node |
| tree_id | string | FK ke dialogue_tree |
| speaker | string | Nama pembicara |
| text | string | Teks dialog |
| portrait | string | Path portrait |
| next_node | string | ID node selanjutnya (null = end) |

### dialogue_choice
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik pilihan |
| node_id | string | FK ke dialogue_node |
| text | string | Teks pilihan |
| condition | string | Kondisi untuk menampilkan (JSON) |
| next_node | string | ID node selanjutnya |
| consequence | string | Konsekuensi (JSON) |

### dialogue_consequence
| Field | Type | Description |
|-------|------|-------------|
| choice_id | string | FK ke dialogue_choice |
| type | enum | AFFINITY, REPUTATION, WORLDSTATE, QUEST, ITEM, EXP |
| target_id | string | ID target (NPC/faction/quest/item) |
| value | int | Nilai perubahan |

## Contoh Data

### Dialog: Tetua Aldric
```json
{
  "id": "dlg_aldric_001",
  "npc_id": "NPC001",
  "trigger": "INTERACT",
  "nodes": [
    {
      "id": "n1",
      "speaker": "Tetua Aldric",
      "text": "Selamat datang, petualang muda. Desa kita sedang dalam bahaya.",
      "next_node": "n2"
    },
    {
      "id": "n2",
      "speaker": "Tetua Aldric",
      "text": "Monster dari hutan semakin agresif. Bisakah kamu membantu kami?",
      "choices": [
        {
          "id": "c1",
          "text": "Tentu, saya akan membantu.",
          "next_node": "n3_accept",
          "consequence": [
            {"type": "QUEST", "target": "Q001", "value": "accept"},
            {"type": "REPUTATION", "target": "village", "value": 5}
          ]
        },
        {
          "id": "c2",
          "text": "Maaf, saya tidak tertarik.",
          "next_node": "n3_decline",
          "consequence": [
            {"type": "REPUTATION", "target": "village", "value": -5}
          ]
        },
        {
          "id": "c3",
          "text": "[Perlu 50 ATK] Biar saya selesaikan masalah ini dengan cara saya.",
          "condition": {"stat": "ATK", "min": 50},
          "next_node": "n3_intimidate",
          "consequence": [
            {"type": "QUEST", "target": "Q001", "value": "accept"},
            {"type": "REPUTATION", "target": "village", "value": -10},
            {"type": "AFFINITY", "target": "NPC001", "value": -15}
          ]
        }
      ]
    }
  ]
}
```

## Dialogue Conditions

| Condition | Description | Contoh |
|-----------|-------------|--------|
| level | Level minimum | `{"level": 10}` |
| job | Job tertentu | `{"job": "warrior"}` |
| item | Memiliki item | `{"item": "ancient_key"}` |
| quest_done | Quest selesai | `{"quest_done": "Q001"}` |
| affinity | Affinity level | `{"affinity": {"npc": "NPC001", "min": 50}}` |
| reputation | Reputation level | `{"reputation": {"faction": "merchant", "min": "friendly"}}` |
| worldstate | WorldState flag | `{"worldstate": {"key": "village_saved", "value": true}}` |
| stat | Stat minimum | `{"stat": "ATK", "min": 50}` |

## Dialogue Triggers

| Trigger | Description |
|---------|-------------|
| INTERACT | Saat pemain berinteraksi |
| PROXIMITY | Saat pemain mendekat |
| QUEST | Saat quest dimulai/selesai |
| EVENT | Saat event tertentu |
| TIME | Saat waktu tertentu |
| FIRST_VISIT | Kunjungan pertama |
