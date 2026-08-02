# Database Item (Item DB)

## Ringkasan

Struktur data untuk semua item di Arcadia Online.

## Tabel Utama

### item_base
| Field | Type | Description |
|-------|------|-------------|
| id | string | ID unik item |
| name | string | Nama item |
| type | enum | CONSUMABLE, MATERIAL, EQUIPMENT, KEY, COSMETIC |
| rarity | enum | COMMON, UNCOMMON, RARE, EPIC, LEGENDARY |
| description | string | Deskripsi item |
| stackable | bool | Bisa di-stack |
| max_stack | int | Maksimum stack (default 99) |
| buy_price | int | Harga beli |
| sell_price | int | Harga jual (30% beli) |
| icon | string | Path icon |

### item_consumable
| Field | Type | Description |
|-------|------|-------------|
| item_id | string | FK ke item_base |
| effect_type | enum | HEAL_HP, HEAL_MP, BUFF, TELEPORT |
| effect_value | float | Nilai efek |
| duration | float | Durasi efek (detik, 0 = instant) |
| cooldown | float | Cooldown penggunaan |

### item_material
| Field | Type | Description |
|-------|------|-------------|
| item_id | string | FK ke item_base |
| material_type | enum | CRAFTING, ENHANCEMENT, QUEST, RUNE |
| craft_level | int | Level crafting yang diperlukan |

## Contoh Data

### Health Potion
```json
{
  "id": "potion_hp_small",
  "name": "Health Potion (Kecil)",
  "type": "CONSUMABLE",
  "rarity": "COMMON",
  "description": "Memulihkan 50 HP",
  "stackable": true,
  "max_stack": 99,
  "buy_price": 50,
  "sell_price": 15,
  "consumable": {
    "effect_type": "HEAL_HP",
    "effect_value": 50,
    "duration": 0,
    "cooldown": 5
  }
}
```

### Iron Ore
```json
{
  "id": "material_iron_ore",
  "name": "Bijih Besi",
  "type": "MATERIAL",
  "rarity": "COMMON",
  "description": "Bahan dasar untuk crafting equipment",
  "stackable": true,
  "max_stack": 99,
  "buy_price": 20,
  "sell_price": 6,
  "material": {
    "material_type": "CRAFTING",
    "craft_level": 1
  }
}
```

### Enhancement Stone Lv1
```json
{
  "id": "enhance_stone_1",
  "name": "Batu Enhancement Lv1",
  "type": "MATERIAL",
  "rarity": "COMMON",
  "description": "Digunakan untuk enhance equipment +1 sampai +5",
  "stackable": true,
  "max_stack": 99,
  "buy_price": 100,
  "sell_price": 30
}
```

## Rarity Table

| Rarity | Warna | Drop Rate | Price Multiplier |
|--------|-------|-----------|------------------|
| COMMON | Putih | 60% | 1x |
| UNCOMMON | Hijau | 25% | 2x |
| RARE | Biru | 10% | 5x |
| EPIC | Ungu | 4% | 15x |
| LEGENDARY | Emas | 1% | 50x |

## Item Categories

### Consumable Types
| Type | Contoh | Efek |
|------|--------|------|
| Potion | Health Potion | Heal HP |
| Elixir | Power Elixir | Buff ATK |
| Food | Bread | Buff DEF |
| Scroll | Teleport Scroll | Teleport |

### Material Types
| Type | Contoh | Penggunaan |
|------|--------|-----------|
| Crafting | Iron Ore | Membuat equipment |
| Enhancement | Enhancement Stone | Upgrade equipment |
| Quest | Ancient Reli | Quest item |
| Rune | Fire Rune | Skill enhancement |
