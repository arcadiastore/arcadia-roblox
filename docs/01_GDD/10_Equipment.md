# 10 — Sistem Equipment

## Ringkasan

Equipment adalah item yang dikenakan karakter untuk meningkatkan statistik. Setiap equipment memiliki slot, rarity, dan stat yang berbeda.

## Equipment Slot

| Slot | Fungsi | Contoh |
|------|--------|--------|
| **Weapon** | Senjata utama | Sword, Staff, Bow |
| **Sub Weapon** | Senjata kedua | Shield, Orb, Quiver |
| **Head** | Pelindung kepala | Helmet, Crown, Hat |
| **Body** | Pelindung tubuh | Armor, Robe, Vest |
| **Hands** | Pelindung tangan | Gauntlet, Gloves |
| **Feet** | Pelindung kaki | Boots, Sandals |
| **Accessory 1** | Aksesoris | Ring, Necklace |
| **Accessory 2** | Aksesoris | Ring, Necklace |

## Stat Equipment

Setiap equipment memiliki:
- **Base Stat** — Stat utama (ATK, DEF, dll)
- **Bonus Stat** — Stat tambahan (random 0-3)
- **Socket** — Slot untuk gem (0-3)
- **Set Bonus** — Bonus jika menggunakan set lengkap

## Enhancement System

### Level Enhancement
- +1 sampai +15
- Success rate menurun setiap level
- Gagal: level turun 1 (di atas +10: equipment hancur)
- Material: Enhancement Stone

| Level | Success Rate | Material |
|-------|-------------|----------|
| +1 to +5 | 100% | Stone Lv1 |
| +6 to +8 | 80% | Stone Lv2 |
| +9 to +10 | 60% | Stone Lv3 |
| +11 to +13 | 40% | Stone Lv4 |
| +14 to +15 | 20% | Stone Lv5 |

### Enchanting
- Menambah stat random
- Bisa mengganti stat yang tidak diinginkan
- Material: Enchant Scroll + Gold

### Gem Socketing
- Memasukkan gem ke socket
- Gem memberikan stat tambahan
- Bisa dilepas dengan tool khusus

## Equipment Set

Set terdiri dari 3-6 item. Bonus aktif saat semua item set dipakai:

```
[Dragon Slayer Set]
├── Dragon Slayer Sword (Weapon)
├── Dragon Slayer Armor (Body)
├── Dragon Slayer Helm (Head)
├── Dragon Slayer Boots (Feet)
│
├── 2 Set: ATK +10%
├── 3 Set: CR +15%
└── 4 Set: Dragon's Fury (skill bonus)
```
