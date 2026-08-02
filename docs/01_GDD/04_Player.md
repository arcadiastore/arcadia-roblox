# 04 — Pemain (Player)

## Ringkasan

Sistem pemain mencakup pembuatan karakter, progresi, dan semua atribut yang melekat pada karakter pemain.

## Pembuatan Karakter

### Pilihan Awal
- **Nama Karakter** — Bebas, maks 16 karakter
- **Job Awal** — 3 pilihan awal (Warrior, Mage, Archer)
- **Penampilan** — Preset wajah & rambut (expandable)

### Starting Stats per Job

| Stat | Warrior | Mage | Archer |
|------|---------|------|--------|
| HP | 120 | 80 | 100 |
| MP | 30 | 100 | 50 |
| ATK | 15 | 8 | 12 |
| DEF | 12 | 5 | 8 |
| MATK | 5 | 15 | 6 |
| SPD | 8 | 7 | 12 |

## Sistem Level

- **Level Cap:** 100
- **EXP Formula:** `EXP_needed = Base * (Level ^ 1.5)`
- **Stat Gain per Level:** Ditentukan oleh job
- **Job Change:** Tersedia di Lv 30 dan Lv 60

## Atribut Pemain

| Atribut | Fungsi |
|---------|--------|
| **HP** | Nyawa, habis = KO |
| **MP** | Mana untuk skill |
| **ATK** | Serangan fisik |
| **DEF** | Pertahanan fisik |
| **MATK** | Serangan magic |
| **MDEF** | Pertahanan magic |
| **SPD** | Kecepatan, menentukan urutan giliran |
| **LUK** | Keberuntungan, memengaruhi critical & drop rate |
| **STA** | Stamina untuk eksplorasi |

## Stamina

- **Max Stamina:** 100
- **Regenerasi:** 1 per menit (offline: 1 per 5 menit)
- **Penggunaan:** Sprint, climbing, swimming
- **Kosong:** Tidak bisa sprint, gerakan lambat

## Sistem Kematian

- HP mencapai 0 → **KO (Knock Out)**
- Seluruh party KO → **Game Over**
- Game Over → Kembali ke checkpoint terakhir
- Tidak ada penalty EXP
- Tidak ada drop item
