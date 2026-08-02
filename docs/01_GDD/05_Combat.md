# 05 — Sistem Pertarungan

## Ringkasan

Arcadia Online menggunakan sistem pertarungan real-time dengan Target Lock, tempo santai, dan opsi Auto Hunt untuk grinding.

## Mekanisme Dasar

### Target Lock
- Otomatis mengunci musuh terdekat saat menyerang
- Bisa ganti target dengan input
- Indikator visual pada target yang terkunci
- Target hilang jika terlalu jauh

### Serangan Dasar (Basic Attack)
- Serangan tanpa cooldown
- Damage berdasarkan ATK vs DEF musuh
- Combo: 3 serangan beruntun = bonus damage
- Tidak menghabiskan MP

### Skill
- Menghabiskan MP
- Cooldown bervariasi (3-60 detik)
- Damage berdasarkan MATK untuk magic, ATK untuk physical
- Efek: damage, heal, buff, debuff, crowd control
- Maks 8 skill yang di-equip sekaligus

## Urutan Pertarungan

```
1. Pemain mendekati musuh
2. Target Lock aktif
3. Pemain memilih aksi (Attack / Skill / Item / Flee)
4. Aksi dieksekusi
5. Musuh membalas (AI)
6. Ulangi sampai salah satu kalah
```

## Auto Hunt

### Fungsi
- Pemain bergerak otomatis mencari musuh
- Menyerang musuh secara otomatis
- Menggunakan potion otomatis jika HP < threshold
- **TIDAK** menggunakan skill otomatis (hemat MP)

### Batasan
- Hanya bisa digunakan di area grinding
- Tidak bisa digunakan di dungeon boss
- Tidak bisa digunakan saat quest story
- Berhenti jika inventory penuh

## Auto Path

### Fungsi
- Pemain bergerak otomatis ke lokasi quest
- Mengikuti jalur optimal
- Menghindari rintangan
- Berhenti jika diserang musuh

## Pertahanan

### Dodge
- I-frame 0.3 detik
- Cooldown 1 detik
- Menghindari semua damage jika timing tepat

### Block
- Mengurangi damage 50%
- Tidak ada cooldown
- Tetap menerima damage

## Pertarungan Boss

- Boss memiliki fase (Phase 1, 2, 3)
- Setiap fase: pola serangan berbeda
- Weak point yang bisa dieksploitasi
- Enrage timer (opsional): boss menguat setelah waktu tertentu
