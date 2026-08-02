# 13 — Sistem NPC

## Ringkasan

NPC (Non-Player Character) adalah karakter yang dikendalikan oleh game. Mereka berfungsi sebagai pedagang, pemberi quest, companion, dan elemen dunia yang hidup.

## Kategori NPC

### 1. Merchant (Pedagang)
- Menjual dan membeli item
- Stok berfluktuasi berdasarkan ekonomi
- Lokasi tetap di kota

### 2. Quest Giver
- Memberikan quest kepada pemain
- Dialog berubah berdasarkan progress
- Beberapa hanya muncul setelah kondisi tertentu

### 3. Companion
- Bergabung dengan party pemain
- Memiliki skill dan personality sendiri
- Bisa dirombak dan ditingkatkan

### 4. Lore NPC
- Memberikan informasi dunia
- Tidak memberikan quest
- Menambah immersion

### 5. Enemy NPC
- Musuh humanoid dalam cerita
- Memiliki AI khusus
- Bisa menjadi ally setelah pilihan tertentu

## Companion System

### Rekrutmen
- Companion bisa direkrut melalui quest
- Beberapa memerlukan kondisi khusus (reputation, item, pilihan)
- Maks 5 companion yang bisa direkrut (party 6 termasuk pemain)

### Hubungan (Affinity)
- **Level:** 0-100
- **Meningkat:** Dialog, gift, quest bersama
- **Menurun:** Pilihan yang bertentangan, lama tidak di-visit
- **Unlock:** Skill, dialog, dan ending berdasarkan level

### Companion Data
```
[Companion Name]
├── ID: C001
├── Job: Warrior
├── Personality: Brave, Loyal
├── Likes: Training, Honesty
├── Dislikes: Cowardice, Lying
├── Affinity Dialogue: 5 level
├── Personal Quest: 1 quest chain
└── Ultimate Skill: 1 ultimate skill
```

## NPC Schedule

NPC memiliki rutinitas harian:
```
06:00 - Bangun, sarapan
08:00 - Mulai kerja (toko/area)
12:00 - Istirahat makan siang
14:00 - Kerja lagi
18:00 - Pulang
20:00 - Di rumah/tavern
22:00 - Tidur
```

## NPC Dialogue

→ Lihat dokumen `15_Dialogue.md`
