# 21 — Sistem Auto Hunt

## Ringkasan

Auto Hunt memungkinkan pemain untuk secara otomatis mencari dan menyerang monster tanpa interaksi manual. Sistem ini dirancang untuk grinding yang santai.

## Cara Kerja

```
1. Pemain mengaktifkan Auto Hunt
2. Karakter bergerak mencari monster terdekat
3. Menyerang monster secara otomatis
4. Setelah monster mati → cari monster berikutnya
5. Berhenti jika kondisi terpenuhi (HP rendah, inventory penuh, dll)
```

## Konfigurasi Auto Hunt

### Target Filter
- **Level Range** — Monster level tertentu
- **Element** — Monster elemen tertentu
- **Type** — Normal / Elite / Boss
- **Area** — Radius pencarian

### Kondisi Berhenti
- **HP < 30%** — Gunakan potion atau berhenti
- **MP < 20%** — Berhenti menggunakan skill
- **Inventory Penuh** — Berhenti hunting
- **Stamina Habis** — Berhenti hunting
- **Waktu Habis** — Timer habis

### Aksi Otomatis
- **Auto Attack** — Serangan dasar otomatis
- **Auto Potion** — Gunakan potion jika HP/MP rendah
- **Auto Loot** — Ambil drop otomatis
- **Auto Skill** — **TIDAK AKTIF** (hemat MP)

## Batasan Auto Hunt

| Bisa | Tidak Bisa |
|------|------------|
| Area grinding | Dungeon boss |
| Monster normal | Quest story |
| Field area | PvP area |
| Daily dungeon | Secret dungeon |

## Auto Path

### Fungsi
- Bergerak otomatis ke lokasi quest/marker
- Mengikuti jalur optimal
- Menghindari rintangan
- Berhenti jika diserang

### Cara Mengaktifkan
1. Buka quest tracker
2. Klik "Auto Path" pada quest
3. Karakter bergerak ke lokasi

## Anti-AFK

- Pemain harus konfirmasi setiap 30 menit
- Jika tidak konfirmasi → Auto Hunt berhenti
- Mencegah AFK farming

## Reward Auto Hunt

- EXP: 80% dari normal (penalti 20%)
- Gold: 100% (tidak ada penalti)
- Drop: 100% (tidak ada penalti)
- Quest progress: 100% (tidak ada penalti)
