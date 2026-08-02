# 09 — Sistem Item

## Ringkasan

Item adalah objek yang dikumpulkan, digunakan, atau diperdagangkan oleh pemain. Sistem item mencakup berbagai kategori dengan fungsi masing-masing.

## Kategori Item

### 1. Consumable
| Jenis | Fungsi | Contoh |
|-------|--------|--------|
| Potion | Heal HP/MP | Health Potion, Mana Potion |
| Food | Buff sementara | Steak (+ATK 10%), Bread (+DEF 5%) |
| Elixir | Buff kuat sementara | Elixir of Power (+ATK 30% 60s) |
| Scroll | Efek instan | Teleport Scroll, Resurrection Scroll |

### 2. Material
| Jenis | Fungsi | Contoh |
|-------|--------|--------|
| Crafting | Bahan crafting | Iron Ore, Magic Crystal |
| Enhancement | Upgrade equipment | Enhancement Stone, Enchant Scroll |
| Quest | Untuk quest | Ancient Relic, Dragon Scale |
| Rune | Skill enhancement | Fire Rune, Ice Rune |

### 3. Equipment
→ Lihat dokumen `10_Equipment.md`

### 4. Key Item
| Jenis | Fungsi |
|-------|--------|
| Quest Item | Item khusus quest, tidak bisa dibuang |
| Map | Membuka area baru |
| Key | Membuka pintu/chest |

### 5. Cosmetic
| Jenis | Fungsi |
|-------|--------|
| Costume | Mengubah penampilan |
| Mount Skin | Mengubah tampilan mount |
| Pet Skin | Mengubah tampilan pet |

## Inventory System

- **Slot:** 50 slot dasar, expandable sampai 200
- **Stack:** Consumable & material bisa di-stack (maks 99)
- **Equipment:** Tidak bisa di-stack
- **Sort:** Otomatis berdasarkan kategori, rarity, nama
- **Quick Slot:** 4 slot untuk consumable cepat

## Rarity System

| Rarity | Warna | Drop Rate | Power Level |
|--------|-------|-----------|-------------|
| Common | Putih | 60% | 1x |
| Uncommon | Hijau | 25% | 1.3x |
| Rare | Biru | 10% | 1.7x |
| Epic | Ungu | 4% | 2.2x |
| Legendary | Emas | 1% | 3x |

## Item Drop

- Monster drop item sesuai drop table
- Boss drop item eksklusif
- World drop: item langka dari monster manapun
- Drop rate bisa ditingkatkan dengan LUK stat
