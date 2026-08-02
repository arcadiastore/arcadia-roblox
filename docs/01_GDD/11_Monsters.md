# 11 — Sistem Monster

## Ringkasan

Monster adalah musuh utama yang dihadapi pemain dalam pertarungan. Setiap monster memiliki elemen, perilaku, dan drop table unik.

## Kategori Monster

### 1. Normal Monster
- Ditemukan di field dan dungeon
- Mudah dikalahkan
- Drop material dan potion

### 2. Elite Monster
- Lebih kuat dari normal
- Spawn terbatas
- Drop equipment dan material langka

### 3. Boss Monster
- Ditemukan di akhir dungeon
- Memiliki fase pertarungan
- Drop equipment epic/legendary

### 4. World Boss
- Muncul di area terbuka
- Membutuhkan banyak pemain (MMORPG)
- Drop item eksklusif

## Monster Data Format

```
[Monster Name]
├── ID: M001
├── Type: Normal / Elite / Boss
├── Element: Fire / Water / Wind / Earth / Light / Dark / None
├── Level: 1-100
├── HP: Base HP
├── ATK: Base Attack
├── DEF: Base Defense
├── SPD: Base Speed
├── EXP: Experience given
├── Gold: Gold dropped
├── Drop Table: List of items with drop rates
├── Behavior: Aggressive / Passive / Territorial
└── Skill: Monster skills
```

## Behavior

| Behavior | Deskripsi |
|----------|-----------|
| **Passive** | Tidak menyerang kecuali diserang |
| **Aggressive** | Menyerang saat melihat pemain |
| **Territorial** | Menyerang jika pemain masuk area |
| **Fleeing** | Kabur saat HP rendah |
| **Pack** | Memanggil teman jika diserang |

## Spawn System

- **Respawn Time:** 30-300 detik (tergantung monster)
- **Spawn Area:** Ditentukan per zone
- **Max Population:** Jumlah maks monster per zone
- **Elite Spawn:** 5% chance setelah normal monster mati

## Drop Table

| Item | Drop Rate | Kondisi |
|------|-----------|---------|
| Material | 30-70% | Selalu |
| Consumable | 10-30% | Selalu |
| Equipment | 1-10% | Tergantung rarity |
| Key Item | Quest only | Saat quest aktif |
