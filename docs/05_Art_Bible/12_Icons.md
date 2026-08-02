# Ikon (Icons)

## Ringkasan

Panduan untuk desain ikon dalam game.

## Kategori Ikon

### Item Icons
| Tipe | Ukuran | Style |
|------|--------|-------|
| Weapon | 64x64 | 3/4 view, detail |
| Armor | 64x64 | Front view, detail |
| Potion | 64x64 | Bottle shape |
| Material | 64x64 | Simple, clear |
| Key Item | 64x64 | Special glow |

### Skill Icons
| Tipe | Ukuran | Style |
|------|--------|-------|
| Active | 64x64 | Skill visual |
| Passive | 64x64 | Stat icon |
| Ultimate | 64x64 | Special glow |

### UI Icons
| Tipe | Ukuran | Style |
|------|--------|-------|
| Menu | 32x32 | Simple, clear |
| Status | 16x16 | Buff/debuff |
| Currency | 32x32 | Coin, gem |
| Achievement | 64x64 | Badge style |

## Design Guidelines

### Background
| Rarity | Background |
|--------|-----------|
| Common | Grey |
| Uncommon | Green |
| Rare | Blue |
| Epic | Purple |
| Legendary | Gold |

### Border
- 2px border
- Color sesuai rarity
- Inner glow untuk epic/legendary

### Silhouette
- Harus jelas di ukuran kecil
- Tidak terlalu detail
- Kontras tinggi

## Contoh Ikon

### Potion
```
┌─────────────┐
│   ┌───┐     │
│   │   │     │
│   │ 💧│     │
│   │   │     │
│   └───┘     │
│             │
└─────────────┘
Bentuk botol, isi berwarna sesuai efek
```

### Sword
```
┌─────────────┐
│      ▲      │
│     /│\     │
│    / │ \    │
│   /  │  \   │
│      │      │
│     ═╪═     │
│      │      │
└─────────────┘
Pedang dengan detail
```

## Ikon per Elemen

| Elemen | Warna | Simbol |
|--------|-------|--------|
| Fire | Merah-Oranye | Api |
| Water | Biru-Cyan | Tetesan |
| Wind | Hijau-Putih | Spiral |
| Earth | Coklat-Kuning | Gunung |
| Light | Putih-Emas | Matahari |
| Dark | Ungu-Hitam | Bulan |

## Ikon Tools

- **Software:** Photoshop, Illustrator, Aseprite
- **Format:** PNG dengan transparency
- **Compression:** ASTC (mobile), DXT (PC)

## Ikon Naming Convention

```
[category]_[name]_[variant].png

Contoh:
item_potion_hp_small.png
skill_warrior_slash.png
ui_menu_settings.png
currency_gold.png
```
