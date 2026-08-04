# 06 — Sistem Job

> **Status**: Sesuai implementasi (3 job awal)

## Ringkasan

Job menentukan peran karakter dalam pertarungan dan menentukan skill yang bisa dipelajari. Pemain memilih job saat membuat karakter dan bisa mengganti job di Job Master.

## 3 Job Classes

```
┌──────────────────────────────────────┐
│         ARCADIA ONLINE JOBS          │
├────────────┬────────────┬────────────┤
│  Warrior   │    Mage    │   Archer   │
│  Tank/DPS  │  Magic DPS │ Ranged DPS │
└────────────┴────────────┴────────────┘
```

---

### 1. Warrior
- **Role:** Tank / Melee DPS
- **Senjata:** Sword, Axe, Hammer
- **Armor:** Heavy, Medium
- **Keunggulan:** HP tinggi, DEF tinggi
- **Kelemahan:** SPD rendah, range pendek

**Base Stats Modifier:**
| Stat | Value |
|------|-------|
| HP | +50 |
| MP | 0 |
| ATK | +5 |
| DEF | +8 |
| MATK | 0 |
| MDEF | +2 |
| SPD | -2 |
| LUK | 0 |

**Growth per Level:**
| Stat | Growth |
|------|--------|
| HP | +15 |
| MP | +2 |
| ATK | +3 |
| DEF | +3 |
| MATK | 0 |
| MDEF | +1 |
| SPD | 0 |
| LUK | +1 |

**Skills:**
| Skill | Type | MP | CD | Effect |
|-------|------|----|-----|--------|
| Power Strike | Physical | 10 | 3s | 150% ATK damage |
| Battle Shout | Buff | 15 | 15s | +20% ATK, 10s |

---

### 2. Mage
- **Role:** Ranged Magic DPS / Support
- **Senjata:** Staff, Wand, Orb
- **Armor:** Cloth
- **Keunggulan:** MATK tinggi, AoE damage
- **Kelemahan:** HP rendah, DEF rendah

**Base Stats Modifier:**
| Stat | Value |
|------|-------|
| HP | -20 |
| MP | +50 |
| ATK | 0 |
| DEF | -3 |
| MATK | +10 |
| MDEF | +5 |
| SPD | +3 |
| LUK | +2 |

**Growth per Level:**
| Stat | Growth |
|------|--------|
| HP | +5 |
| MP | +10 |
| ATK | 0 |
| DEF | +1 |
| MATK | +4 |
| MDEF | +2 |
| SPD | +1 |
| LUK | +1 |

**Skills:**
| Skill | Type | MP | CD | Effect |
|-------|------|----|-----|--------|
| Fireball | Magic | 15 | 5s | 180% MATK damage |
| Ice Shield | Buff | 20 | 20s | Absorb 100 damage, 15s |

---

### 3. Archer
- **Role:** Ranged Physical DPS
- **Senjata:** Bow, Crossbow, Dagger
- **Armor:** Light, Medium
- **Keunggulan:** SPD tinggi, range jauh
- **Kelemahan:** HP medium, DEF medium

**Base Stats Modifier:**
| Stat | Value |
|------|-------|
| HP | +10 |
| MP | +10 |
| ATK | +3 |
| DEF | 0 |
| MATK | 0 |
| MDEF | +2 |
| SPD | +8 |
| LUK | +5 |

**Growth per Level:**
| Stat | Growth |
|------|--------|
| HP | +8 |
| MP | +5 |
| ATK | +3 |
| DEF | +1 |
| MATK | 0 |
| MDEF | +1 |
| SPD | +2 |
| LUK | +2 |

**Skills:**
| Skill | Type | MP | CD | Effect |
|-------|------|----|-----|--------|
| (basic attack) | Physical | 0 | 0s | 100% ATK damage |

> Archer belum memiliki skill khusus selain basic attack.

---

## Stat Comparison (Level 1)

| Stat | Warrior | Mage | Archer |
|------|---------|------|--------|
| HP | 150 | 80 | 110 |
| MP | 50 | 100 | 60 |
| ATK | 15 | 10 | 13 |
| DEF | 13 | 2 | 5 |
| MATK | 5 | 15 | 5 |
| MDEF | 7 | 10 | 7 |
| SPD | 8 | 13 | 18 |
| LUK | 5 | 7 | 10 |

> Base player: HP=100, MP=50, ATK=10, DEF=5, MATK=5, MDEF=5, SPD=10, LUK=5

---

## Ganti Job

- Bisa dilakukan di **Job Master** (NPC di kota)
- Biaya gold: **1000** (flat)
- Level tetap, skill points di-reset
- Equipment bisa di-share antar job
- Inventory tetap sama
