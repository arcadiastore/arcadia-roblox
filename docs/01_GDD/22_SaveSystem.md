# 22 — Sistem Simpan (Save System)

## Ringkasan

Sistem simpan memungkinkan pemain menyimpan dan memuat progres game. Mendukung save lokal dan cloud (untuk MMORPG).

## Tipe Save

### 1. Auto Save
- Otomatis menyimpan setiap 5 menit
- Saat memasuki area baru
- Saat menyelesaikan quest
- Saat mendapatkan item penting

### 2. Manual Save
- Pemain menyimpan secara manual
- Bisa dilakukan di Save Point
- Bisa dilakukan dari menu

### 3. Quick Save
- Save cepat dengan 1 tombol
- Menimpa slot yang sama
- Cocok untuk eksplorasi

## Save Data

```
Save Data:
├── Player
│   ├── Name
│   ├── Level
│   ├── Job
│   ├── Stats
│   ├── Equipment
│   ├── Inventory
│   ├── Skills
│   └── Position (x, y, z, scene)
├── Party
│   ├── Members
│   └── Formation
├── World
│   ├── WorldState
│   ├── Quest Progress
│   ├── NPC Affinity
│   ├── Reputation
│   └── Time & Weather
├── Game
│   ├── Playtime
│   ├── Save Count
│   └── Achievements
└── System
    ├── Settings
    └── Controls
```

## Save Slot

- **Slot:** 10 slot manual + 1 auto save + 1 quick save
- **Ukuran:** ~500KB per save
- **Cloud:** 100 slot (MMORPG)

## Save Point

### Lokasi
- Setiap kota
- Setiap dungeon entrance
- Sebelum boss room
- Area strategis

### Efek
- Restore HP/MP penuh
- Save game
- Bisa fast travel ke save point lain

## Save Integrity

- **Checksum** — Mencegah save corruption
- **Backup** — Auto backup sebelum save baru
- **Version** — Save version tracking
- **Migration** — Update save format jika game update

## Save di Offline vs Online

| Fitur | Offline | Online |
|-------|---------|--------|
| Save Lokal | Ya | Ya |
| Cloud Save | Tidak | Ya |
| Cross-device | Tidak | Ya |
| Backup | Manual | Otomatis |
| Anti-cheat | Tidak | Ya |
