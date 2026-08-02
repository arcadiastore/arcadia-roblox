# 14 — Sistem Quest

## Ringkasan

Quest adalah misi yang diberikan oleh NPC atau ditemukan secara eksplorasi. Quest menggerakkan cerita utama dan memberikan reward kepada pemain.

## Tipe Quest

### 1. Main Quest (Quest Utama)
- Menggerakkan cerita utama
- Linear, harus diselesaikan berurutan
- Reward besar: EXP, gold, equipment, story progress
- Tidak bisa diulang

### 2. Side Quest (Quest Sampingan)
- Cerita tambahan yang berkualitas
- Bisa diselesaikan kapan saja
- Reward: EXP, gold, item, companion, reputation
- Tidak bisa diulang

### 3. Daily Quest
- Quest harian yang bisa diulang
- Reset setiap hari
- Reward: gold, material, EXP kecil

### 4. Repeatable Quest
- Bisa diulang tanpa batas
- Reward menurun setelah setiap pengulangan
- Cocok untuk grinding

### 5. Hidden Quest
- Tidak ada marker di map
- Ditemukan melalui eksplorasi atau dialog khusus
- Reward unik dan langka

## Quest Structure

```
[Quest Name]
├── ID: Q001
├── Type: Main / Side / Daily / Repeatable / Hidden
├── Giver: NPC Name
├── Level Requirement: 1-100
├── Prerequisite: Quest lain yang harus selesai dulu
├── Objectives:
│   ├── 1. Pergi ke lokasi X
│   ├── 2. Bunuh Y monster
│   └── 3. Kumpulkan Z item
├── Rewards:
│   ├── EXP: 1000
│   ├── Gold: 500
│   └── Item: Rare Sword
├── Failure Condition: (jika ada)
└── Branching: Pilihan yang memengaruhi hasil
```

## Quest Tracker

- Maks 5 quest aktif sekaligus
- Quest marker di map dan minimap
- Objective tracker di HUD
- Auto Path ke lokasi quest

## Quest Chain

Quest yang saling berhubungan membentuk chain:

```
Q001: "Permintaan Tetua" → 
Q002: "Temukan Herbal" → 
Q003: "Obati Penduduk" → 
Q004: "Serang Markas Bandit"
```

## Branching Quest

Bequest memiliki pilihan yang memengaruhi hasil:

```
Q010: "Dilema Pedagang"
├── Pilihan A: Bantu pedagang → Reward: Gold + Reputation Merchant
├── Pilihan B: Bantu bandit → Reward: Item langka + Reputation Bandit
└── Pilihan C: Selesaikan damai → Reward: Both (lebih sulit)
```
