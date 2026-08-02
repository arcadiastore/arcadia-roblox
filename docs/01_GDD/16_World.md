# 16 — Dunia (World)

## Ringkasan

Dunia Arcadia adalah benua luas dengan berbagai wilayah, masing-masing memiliki budaya, ekosistem, dan tantangan unik.

## Benua Arcadia

### Wilayah Utama

| Wilayah | Level | Iklim | Ciri Khas |
|---------|-------|-------|-----------|
| **Beginner Village** | 1-10 | Subtropis | Desa damai, tutorial |
| **Green Forest** | 10-25 | Hutan | Hutan lebat, beast & plant |
| **Sage Tower** | 25-40 | Pegunungan | Menara penyihir, puzzle |
| **Rebel HQ** | 40-55 | Dataran | Markas pemberontak |
| **Capital City** | 55-70 | Urban | Ibu kota kerajaan |
| **Dark Caverns** | 70-85 | Bawah tanah | Gua gelap, undead |
| **Sky Islands** | 85-100 | Aerial | Pulau terbang, dragon |

### Spesial Area

| Area | Fungsi |
|------|--------|
| **Arena** | PvP & tantangan |
| **Guild Hall** | Markas guild |
| **Secret Dungeon** | Dungeon tersembunyi |
| **World Boss Area** | Area world boss |

## Dunia yang Hidup

### Waktu
- **1 hari game** = 30 menit real-time
- **Cuaca** berubah setiap 10 menit
- **Malam** lebih berbahaya: monster lebih kuat

### Cuaca
| Cuaca | Efek |
|-------|------|
| Cerah | Normal |
| Hujan | SPD -10%, Water +20% |
| Salju | SPD -20%, Fire -10% |
| Badai | SPD -30%, Lightning +30% |
| Kabut | ACC -20%, EVA +10% |

### Musim
- **Semi** — Event bunga, monster langka muncul
- **Panas** — Event pantai, water element bonus
- **Gugur** — Event harvest, crafting bonus
- **Dingin** — Event salju, ice element bonus

## WorldState System

WorldState adalah flag yang menentukan kondisi dunia:

```
WorldState:
├── VillageDestroyed: false
├── KingAlive: true
├── DemonKingAwaken: false
├── MerchantGuildLevel: 1
├── CapitalBurned: false
└── HeroReputation: "Neutral"
```

WorldState berubah berdasarkan:
- Pilihan pemain dalam quest
- Progress cerita
- Event global

## Transportasi

| Metode | Kecepatan | Unlock |
|--------|-----------|--------|
| Jalan kaki | Normal | Default |
| Sprint | 2x | Stamina |
| Mount | 3x | Lv 20 + quest |
| Teleport | Instan | Unlock waypoint |
| Ship | 2x | Chapter 3 |
| Airship | 4x | Chapter 5 |
