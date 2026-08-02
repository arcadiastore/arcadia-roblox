# 17 — Sistem Dungeon

## Ringkasan

Dungeon adalah area khusus yang berisi monster, puzzle, dan boss. Setiap dungeon memiliki tema, tingkat kesulitan, dan reward unik.

## Tipe Dungeon

### 1. Story Dungeon
- Terkait dengan cerita utama
- Harus diselesaikan untuk progress
- Boss di akhir
- Tidak bisa diulang

### 2. Side Dungeon
- Opsional, ditemukan melalui eksplorasi
- Bisa diulang
- Drop equipment dan material

### 3. Daily Dungeon
- Bisa diulang 1x per hari
- Reward harian
- Tantangan spesifik (time trial, survival, dll)

### 4. Secret Dungeon
- Tersembunyi, memerlukan kondisi khusus untuk masuk
- Reward sangat langka
- Puzzle kompleks

## Struktur Dungeon

```
[Dungeon Name]
├── ID: D001
├── Type: Story / Side / Daily / Secret
├── Level Range: 10-15
├── Recommended Party: 1-4
├── Floors: 3
├── Enemies: List monster per lantai
├── Boss: Boss di lantai terakhir
├── Puzzles: List puzzle
├── Rewards: List reward
└── Time Limit: (jika ada)
```

## Mekanisme Dungeon

### Save Point
- Checkpoint di setiap lantai
- Restore HP/MP
- Bisa respawn di sini jika KO

### Puzzle
- **Switch** — Tekan switch untuk membuka pintu
- **Maze** — Labirin dengan jalan buntu
- **Riddle** — Jawab teka-teki NPC
- **Platform** — Lompat platform
- **Elemental** — Gunakan elemen yang tepat

### Trap
- **Spike** — Damage saat diinjak
- **Arrow** — Panah otomatis
- **Poison** — Gas beracun
- **Fire** — Api dari dinding
- **Teleport** — Pindah ke area lain

## Dungeon Rewards

| Lantai | Reward |
|--------|--------|
| 1 | Material, Potion |
| 2 | Equipment, Rune |
| 3 (Boss) | Equipment Epic/Legendary, Key Item |

## Dungeon Completion

- Semua lantai selesai → Dungeon Clear
- Boss dikalahkan → Boss Clear
- Semua treasure ditemukan → Treasure Hunter
- Semua puzzle selesai → Puzzle Master
- Semua achievement → Dungeon Master
