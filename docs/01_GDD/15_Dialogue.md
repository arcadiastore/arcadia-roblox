# 15 — Sistem Dialog

## Ringkasan

Sistem dialog memungkinkan pemain berinteraksi dengan NPC melalui percakapan dengan pilihan yang memengaruhi cerita dan hubungan.

## Format Dialog

```
[NPC Name] → "Percakapan NPC"
├── Pilihan 1: "Respons pemain A"
│   └── → Konsekuensi A
├── Pilihan 2: "Respons pemain B"
│   └── → Konsekuensi B
└── [Kondisional] Pilihan 3: "Respons khusus"
    └── → Muncul hanya jika kondisi terpenuhi
```

## Tipe Dialog

### 1. Linear Dialog
- Tidak ada pilihan
- NPC berbicara, pemain membaca
- Untuk lore dan informasi

### 2. Choice Dialog
- Pemain memilih respons
- Pilihan memengaruhi:
  - Hubungan NPC (Affinity)
  - Reputasi faction
  - Jalur cerita
  - WorldState

### 3. Skill Check Dialog
- Pilihan memerlukan level skill/stat tertentu
- Contoh: "[Intimidate] Kamu yakin?" (memerlukan ATK > 50)
- Memberikan hasil yang berbeda

### 4. Timed Dialog
- Pilihan harus dipilih dalam waktu tertentu
- Waktu habis = pilihan default (biasanya yang terburuk)
- Untuk momen dramatis

## Konsekuensi Dialog

### Affinity
```
Pilihan positif → Affinity +5
Pilihan negatif → Affinity -10
Pilihan netral → Affinity +0
```

### Reputation
```
Bantu pedagang → Merchant Reputation +10
Bantu bandit → Bandit Reputation +10, Merchant -5
```

### WorldState
```
Selamatkan desa → WorldState: VillageSaved = true
Biarkan desa hancur → WorldState: VillageDestroyed = true
```

## Dialog Conditions

Pilihan bisa muncul/syarat berdasarkan:
- Level pemain
- Job pemain
- Item yang dimiliki
- Quest yang sudah selesai
- Reputation level
- Affinity level
- WorldState
- Waktu dalam game
