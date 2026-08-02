# 07 — Sistem Skill

## Ringkasan

Skill adalah kemampuan khusus yang digunakan dalam pertarungan. Setiap job memiliki skill tree unik dengan berbagai efek.

## Kategori Skill

### 1. Active Skill
- Diaktifkan manual oleh pemain
- Menghabiskan MP
- Memiliki cooldown
- Maks 8 skill yang di-equip

### 2. Passive Skill
- Aktif terus setelah dipelajari
- Tidak menghabiskan MP
- Meningkatkan stat atau memberikan efek permanen

### 3. Ultimate Skill
- Skill paling kuat per job
- Cooldown sangat panjang (60-180 detik)
- Membutuhkan kondisi khusus (HP < 30%, combo 10, dll)

## Skill Tree Format

```
[Skill Name]
├── Tier: 1-5
├── Type: Active / Passive / Ultimate
├── MP Cost: 10-100
├── Cooldown: 3-180 detik
├── Damage/Heal: Base + (MATK/ATK * multiplier)
├── Effect: Buff / Debuff / CC / AoE
├── Prerequisite: Skill lain yang harus dipelajari dulu
└── Level Requirement: 1-100
```

## Contoh Skill per Job

### Warrior
| Skill | Tier | Type | MP | CD | Efek |
|-------|------|------|----|----|------|
| Slash | 1 | Active | 5 | 3s | ATK * 1.5 damage |
| Shield Bash | 2 | Active | 15 | 8s | Stun 2s |
| War Cry | 3 | Active | 30 | 30s | Party ATK +20% 10s |
| Berserk | 5 | Ultimate | 100 | 120s | ATK +50%, DEF -30% 15s |

### Mage
| Skill | Tier | Type | MP | CD | Efek |
|-------|------|------|----|----|------|
| Fire Bolt | 1 | Active | 10 | 5s | MATK * 1.8 damage |
| Ice Wall | 2 | Active | 25 | 15s | Block + Slow |
| Meteor | 4 | Active | 80 | 60s | AoE MATK * 3.0 |
| Archmage's Fury | 5 | Ultimate | 100 | 180s | Semua skill tanpa CD 10s |

## Rune Enhancement

- Skill bisa di-enhance dengan Rune
- Rune menambah efek: element, status, range, dll
- 1 skill bisa dipasangi 1-3 Rune
- Rune bisa di-upgrade dengan material

## Skill Points

- 1 SP per level up
- SP digunakan untuk belajar skill baru atau upgrade skill existing
- Reset SP: item khusus atau Job Master (biaya gold)
