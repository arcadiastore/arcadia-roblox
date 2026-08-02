# 08 — Sistem Statistik

## Ringkasan

Sistem statistik menentukan kemampuan karakter dalam pertarungan dan eksplorasi. Setiap stat memiliki fungsi spesifik dan formula perhitungan.

## Stat Primer

| Stat | Nama | Fungsi |
|------|------|--------|
| **HP** | Health Points | Nyawa karakter, habis = KO |
| **MP** | Magic Points | Energi untuk skill |
| **ATK** | Attack | Kekuatan serangan fisik |
| **DEF** | Defense | Ketahanan terhadap serangan fisik |
| **MATK** | Magic Attack | Kekuatan serangan magic |
| **MDEF** | Magic Defense | Ketahanan terhadap serangan magic |
| **SPD** | Speed | Kecepatan, menentukan urutan giliran |
| **LUK** | Luck | Keberuntungan, memengaruhi critical & drop |

## Stat Sekunder

| Stat | Fungsi | Formula |
|------|--------|---------|
| **CR** | Critical Rate | `Base + (LUK * 0.1) + Equipment` |
| **CD** | Critical Damage | `150% + (LUK * 0.05)` |
| **EVA** | Evasion Rate | `Base + (SPD * 0.05) + Equipment` |
| **ACC** | Accuracy | `Base + (SPD * 0.03) + Equipment` |
| **ASPD** | Attack Speed | `Base + (SPD * 0.1)` |

## Formula Damage

### Physical Damage
```
Damage = (ATK * Skill_Multiplier) - (Target_DEF * 0.5)
Minimum Damage = 1
```

### Magic Damage
```
Damage = (MATK * Skill_Multiplier) - (Target_MDEF * 0.5)
Minimum Damage = 1
```

### Critical Hit
```
Damage = Normal_Damage * (CD / 100)
```

## Stat Cap

| Stat | Cap |
|------|-----|
| CR | 100% |
| EVA | 75% |
| ASPD | 200% |
| Elemental Resist | 80% |

## Elemental System

| Element | Kuat Melawan | Lemah Melawan |
|---------|-------------|---------------|
| Fire | Wind | Water |
| Water | Fire | Wind |
| Wind | Water | Earth |
| Earth | Wind | Fire |
| Light | Dark | Dark |
| Dark | Light | Light |

Bonus elemental: +30% damage
