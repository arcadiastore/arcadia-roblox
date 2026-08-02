# 23 — Sistem Pilihan (Choices)

## Ringkasan

Sistem pilihan memungkinkan pemain membuat keputusan yang memengaruhi cerita, karakter, dan dunia. Ini adalah pilar inti: "Setiap Pilihan Berarti".

## Tipe Pilihan

### 1. Moral Choice
- Pilihan baik vs jahat
- Memengaruhi ending
- Memengaruhi reputation

### 2. Strategic Choice
- Pilihan taktis dalam quest
- Memengaruhi jalur quest
- Memengaruhi reward

### 3. Relationship Choice
- Pilihan yang memengaruhi NPC
- Memengaruhi affinity
- Memengaruhi companion

### 4. Sacrifice Choice
- Pilihan sulit dengan konsekuensi besar
- Tidak ada pilihan yang "benar"
- Memengaruhi WorldState

## Konsekuensi

### Jangka Pendek
- Perubahan dialog langsung
- Perubahan reward quest
- Perubahan jalur quest

### Jangka Menengah
- Perubahan reputation
- Perubahan NPC availability
- Perubahan area yang bisa diakses

### Jangka Panjang
- Perubahan ending
- Perubahan WorldState
- Perubahan dunia secara keseluruhan

## Contoh Pilihan

### Quest: "Dilema Pedagang"
```
Situasi: Pedagang meminta bantuan, bandit mengancam

Pilihan A: Bantu pedagang
├── Pedagang selamat
├── Merchant Reputation +10
├── Bandit menjadi musuh
└── Quest lanjutan: Balas dendam bandit

Pilihan B: Bantu bandit
├── Pedagang mati
├── Bandit Reputation +10
├── Merchant Reputation -20
├── Item langka dari bandit
└── Quest lanjutan: Serang kota

Pilihan C: Negosiasi
├── Skill check: CHR > 50
├── Pedagang dan bandit damai
├── Merchant +5, Bandit +5
└── Quest lanjutan: Jalur perdamaian
```

## Choice Tracker

- Semua pilihan tercatat
- Bisa dilihat di menu "Choice History"
- Statistik pilihan: berapa % pemain memilih A vs B

## Hidden Choices

- Beberapa pilihan tidak terlihat sebagai "pilihan"
- Contoh: NPC yang kamu bantu vs abaikan
- Contoh: Area yang kamu eksplorasi vs skip
- Semua tindakan bisa memiliki konsekuensi
