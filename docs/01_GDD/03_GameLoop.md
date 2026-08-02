# 03 — Game Loop

## Ringkasan

Game loop Arcadia Online terdiri dari loop utama (core loop) dan loop pendukung yang saling melengkapi untuk menciptakan pengalaman bermain yang memuaskan.

## Core Loop

```
Eksplorasi → Pertarungan → Reward → Peningkatan → Eksplorasi (ulang)
```

### Detail Core Loop

1. **Eksplorasi** — Pemain menjelajahi dunia, menemukan area baru, NPC, dan quest
2. **Pertarungan** — Menghadapi monster, boss, dan tantangan
3. **Reward** — Mendapatkan EXP, gold, item, equipment
4. **Peningkatan** — Level up, upgrade equipment, belajar skill baru
5. **Kembali ke Eksplorasi** — Dengan kekuatan baru, akses area yang sebelumnya tidak bisa dimasuki

## Loop Pendukung

### Loop Quest
```
Terima Quest → Kumpulkan/Bunuh/Explore → Laporkan → Reward → Quest Baru
```

### Loop Crafting
```
Kumpulkan Material → Crafting → Item Baru → Gunakan/Jual
```

### Loop Sosial
```
Temui NPC → Dialog → Pilihan → Konsekuensi → Hubungan Berubah
```

### Loop Ekonomi
```
Kumpulkan Gold → Beli/Jual → Ekonomi Berubah → Harga Berubah
```

## Ritme Bermain

| Sesi | Durasi | Aktivitas |
|------|--------|-----------|
| **Pendek** | 15-30 menit | Auto Hunt, cek quest, crafting |
| **Medium** | 1-2 jam | Dungeon, quest chain, eksplorasi |
| **Panjang** | 3+ jam | Boss raid, story chapter, event |

## Progresi Pemain

```
Lv 1-10:   Tutorial & Beginner Village
Lv 10-25:  Green Forest & Side Quests
Lv 25-40:  Sage Tower & Story Dungeons
Lv 40-60:  Mid-game content
Lv 60-80:  Late-game dungeons & bosses
Lv 80-100: End-game content & true endings
```
