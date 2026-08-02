# 29 — Progresi Peta

## Ringkasan

Progresi peta menentukan kapan dan bagaimana pemain membuka area baru di dunia Arcadia. Sistem ini memastikan pemain tidak kewalahan dengan konten yang terlalu sulit.

## Membuka Area

### Syarat Pembukaan
| Metode | Contoh |
|--------|--------|
| Level | Level 20+ untuk Green Forest |
| Quest | Selesaikan quest "Jalan ke Hutan" |
| Item | Punya "Forest Key" |
| WorldState | KingAlive = true |
| Auto | Setelah area sebelumnya selesai |

### Progresi Linear
```
Beginner Village (Lv 1-10)
    ↓ Quest: "Permintaan Tetua"
Green Forest (Lv 10-25)
    ↓ Quest: "Temukan Herbal"
Sage Tower (Lv 25-40)
    ↓ Quest: "Rahasia Menara"
Rebel HQ (Lv 40-55)
    ↓ Quest: "Serangan ke Ibukota"
Capital City (Lv 55-70)
    ↓ Quest: "Masuk Istana"
Dark Caverns (Lv 70-85)
    ↓ Quest: "Turun ke Kegelapan"
Sky Islands (Lv 85-100)
```

## Area Unlock System

### Gate System
- Area baru terkunci sampai syarat terpenuhi
- Gate visual di batas area
- Notifikasi saat area terbuka

### Fast Travel
- Unlock waypoint di setiap area
- Bisa fast travel ke waypoint yang sudah di-unlock
- Biaya gold: 10-100

## Level Scaling

### Enemy Scaling
- Monster di area sesuai level area
- Tidak ada scaling otomatis
- Pemain harus level yang cukup

### Content Scaling
- Quest reward sesuai level
- Drop rate tetap
- EXP menyesuaikan level monster

## Hidden Areas

| Area | Lokasi | Unlock |
|------|--------|--------|
| Secret Garden | Green Forest | Hidden quest |
| Ancient Library | Sage Tower | Puzzle |
| Underground City | Capital City | Key item |
| Dragon Nest | Sky Islands | Boss drop |

## Area Completion

Setiap area memiliki completion tracker:
- **Monster** — Bunuh semua tipe monster
- **Quest** — Selesaikan semua quest
- **Treasure** — Temukan semua treasure
- **NPC** — Bicara dengan semua NPC
- **Secret** — Temukan semua rahasia

Completion 100% → Achievement + Reward
